/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class ApplicationSubmissionService extends AbstractService {
  @TestVisible
  private static ApplicationSubmissionService serviceInstance;

  public ApplicationSubmissionService() {
    super(ApplicationSubmissionService.class);
  }

  /**
   * @description Provides a singleton instance of ApplicationSubmissionService from which all other class methods can be accessed.
   * @author Digital Align Team | 01/25/2022
   * @return Object  singleton
   **/
  public static ApplicationSubmissionService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicationSubmissionService) getInstance(ApplicationSubmissionService.class);
    }
    return serviceInstance;
  }

  /**
   * @description final application submit
   * @author Digital Align Team | 01-25-2022
   * @param String data
   * @return Application__c
   **/
  global virtual Application__c submitApplication(String data) {
    log?.debug('Inside submitApplication');
    Application__c application = SubmissionRepository.readApplicationWithApplicants(ApexRequest.getApplicationId());
    HttpBuilder.Response response = RpaProcessService.getInstance().scheduleApplication(application);
    if (response.statusCode == 400) {
      application.Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
      application.Stage__c = 'Exception';
      application.mflow__FlowState__c = '';
    } else {
      application.Status__c = ApplicationConstant.SUBMITTED;
      application.Stage__c = ApplicationConstant.SUBMITTED;
    }

    for (Applicant__c applicant : application.Applicants__r) {
      if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        applicant.mflow__Status__c = application.Status__c;
        break;
      }
    }
    application.SubmittedDate__c = Datetime.now();
    application.SubmittedBy__c = UserInfo.getUserId();
    SubmissionRepository.upsertRecord(application);
    SubmissionRepository.upsertRecords(application.Applicants__r);
    log?.debug('Completed submitApplication');
    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 12-02-2021
   * @param String resultJson
   * @return Application__c
   **/
  global virtual Application__c processFundingSubmission(String resultJson) {
    FundingSubmissionResponse.FundingResult fundingResult = (FundingSubmissionResponse.FundingResult) JSON.deserialize(
      resultJson,
      FundingSubmissionResponse.FundingResult.class
    );

    // When result is null
    if (fundingResult == null) {
      throw new CustomException('Unable to process the empty request');
    }

    Application__c application = SubmissionRepository.readApplicationForFundingProcess(fundingResult.Application);
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicationName(application.Name);

    //chatter post on record level
    NotificationBuilder.chatterMessagePost(application.Id, 'Funding Response from meridian link  : ' + resultJson);

    if (application.Status__c == ApplicationConstant.COMPLETED) {
      throw new CustomException('Application has already processed');
    }

    // roll back whole transaction on failure
    Savepoint sp = Database.setSavepoint();
    try {
      application = this.updateFundingDetail(application, fundingResult);

      if (application.Status__c == ApplicationConstant.COMPLETED) {
        //Send Funding Email Link to primary
        CustomerEmailService.getInstance().accountOpened(application);
        NotificationService.getInstance()
          .dispatchSubmitNotification(
            'onApplicationCompleted',
            ApexRequest.getApplicationId(),
            ApexRequest.getApplicationName(),
            null
          );
        // Send Customer Interest to Primary Applicant
        ApplicationSubmissionService.notifyProductInterestAsync(ApexRequest.getApplicationId());
      } else {
        NotificationService.getInstance()
          .dispatchSubmitNotification(
            'onApplicationFailed',
            ApexRequest.getApplicationId(),
            ApexRequest.getApplicationName(),
            null
          );
      }
      return application;
    } catch (Exception ex) {
      NotificationService.getInstance()
        .generalExceptionNotification(ApexRequest.getApplicationId(), ApexRequest.getApplicationName(), ex);
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
  }

  /**
   * @description
   * @author Digital Align Team | 01-27-2022
   * @param Application__c application
   * @param FundingSubmissionResponse.FundingResult fundingResult
   * @return Application__c
   **/
  global virtual Application__c updateFundingDetail(
    Application__c application,
    FundingSubmissionResponse.FundingResult fundingResult
  ) {
    switch on fundingResult.ExternalApplicationStatus {
      when 'Accept', 'Passed', 'Approved' {
        application.Status__c = ApplicationConstant.COMPLETED;
        application.MemberNumber__c = fundingResult.MemberNumber;
        for (Applicant__c applicant : application.Applicants__r) {
          if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
            applicant.mflow__CustomerNumber__c = fundingResult.MemberNumber;
            applicant.mflow__Status__c = ApplicationConstant.COMPLETED;
            break;
          }
        }
      }
      when else {
        application.Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
        application.MemberNumber__c = fundingResult.MemberNumber;
      }
    }

    if (fundingResult?.FinancialAccount != null && fundingResult.FinancialAccount.size() > 0) {
      FundingSubmissionResponse.FinancialAccountResult financialAccountResult = fundingResult.FinancialAccount[0];
      if (String.isNotBlank(financialAccountResult.FinancialAccountId)) {
        FinancialAccount__c fa = new FinancialAccount__c(
          Id = financialAccountResult.FinancialAccountId,
          AccountNumber__c = financialAccountResult.AccountNumber
        );
        if (application.Status__c == ApplicationConstant.COMPLETED) {
          fa.Status__c = ApplicationConstant.COMPLETED;
        }
        SubmissionRepository.upsertRecord(fa);
      }

      if (
        financialAccountResult?.FinancialApplicationTransaction != null &&
        financialAccountResult?.FinancialApplicationTransaction?.FinancialAccountTransactionId != null
      ) {
        //READY FOR FUNDING
        //FUNDED
        FinancialAccountTransaction__c fat = new FinancialAccountTransaction__c(
          Id = financialAccountResult.FinancialApplicationTransaction.FinancialAccountTransactionId,
          TransactionStatus__c = 'Posted'
        );
        SubmissionRepository.upsertRecord(fat);
      }
    }

    SubmissionRepository.upsertRecord(application);
    SubmissionRepository.upsertRecords(application.Applicants__r);
    return application;
  }

  /**
   * @description Notify Product Interest Async
   * @author Digital Align Team | 03-15-2022
   * @param Id applicationId
   **/
  @future
  global static void notifyProductInterestAsync(Id applicationId) {
    ApplicationSubmissionService.getInstance().notifyProductInterest(applicationId);
  }

  /**
   * @description  Notify Product Interest
   * @author Digital Align Team | 03-15-2022
   * @param applicationId ;
   * @return Application__c
   **/
  global virtual Application__c notifyProductInterest(Id applicationId) {
    Application__c application = SubmissionRepository.readApplicationForProductInterest(applicationId);

    return application;
  }
}
