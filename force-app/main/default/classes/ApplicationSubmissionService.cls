/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicationSubmissionService extends AbstractService {
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
      serviceInstance = (ApplicationSubmissionService) getInstance(
        ApplicationSubmissionService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description final application submit
   * @author Digital Align Team | 01-25-2022
   * @param String data
   * @return Account
   **/
  global virtual Account submitApplication(String data) {
    log?.debug('Inside submitApplication');
    Account application = SubmissionRepository.readApplicationWithApplicants(
      ApexRequest.getApplicationId()
    );
    HttpBuilder.Response response = RpaProcessService.getInstance()
      .scheduleApplication(application);
    if (response.statusCode == 400) {
      application.FinServ__Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
      application.Stage__c = 'Exception';
      application.mflow__FlowState__c = '';
    } else {
      application.FinServ__Status__c = ApplicationConstant.SUBMITTED;
      application.Stage__c = 'Submitted';
    }

    for (Applicant__c applicant : application.Applicants__r) {
      if (
        applicant.RecordType.Name ==
        ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
      ) {
        applicant.mflow__Status__c = application.FinServ__Status__c;
        break;
      }
    }
    SubmissionRepository.upsertRecord(application);
    SubmissionRepository.upsertRecords(application.Applicants__r);
    log?.debug('Completed submitApplication');
    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 12-02-2021
   * @param String resultJson
   * @return Account
   **/
  global virtual Account processFundingSubmission(String resultJson) {
    FundingSubmissionResponse.FundingResult fundingResult = (FundingSubmissionResponse.FundingResult) JSON.deserialize(
      resultJson,
      FundingSubmissionResponse.FundingResult.class
    );

    // When result is null
    if (fundingResult == null) {
      throw new CustomException('Unable to process the empty request');
    }

    Account application = SubmissionRepository.readApplicationWithApplicants(
      fundingResult.Application
    );
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicationName(application.ApplicationNumber__c);

    if (application.FinServ__Status__c == ApplicationConstant.COMPLETED) {
      throw new CustomException('Application has already processed');
    }

    //chatter post on record level
    NotificationBuilder.chatterMessagePost(
      application.Id,
      'Funding Response from meridian link  : ' + resultJson
    );

    // roll back whole transaction on failure
    Savepoint sp = Database.setSavepoint();
    try {
      application = this.updateFundingDetail(application, fundingResult);

      if (application.FinServ__Status__c == ApplicationConstant.COMPLETED) {
        //Send Funding Email Link to primary
        // CustomerEmailService.getInstance()
        //   .fundingLinkOnKycApproval(application);
        // NotificationService.getInstance()
        //   .dispatchKycNotification(
        //     'onSuccessKycProcess',
        //     application.Id,
        //     application.Name,
        //     null
        //   );
      } else {
        // NotificationService.getInstance()
        //   .dispatchKycNotification(
        //     'onReviewKycProcess',
        //     application.Id,
        //     application.Name,
        //     null
        //   );
      }
      return application;
    } catch (Exception ex) {
      // NotificationService.getInstance()
      //   .dispatchKycNotification(
      //     'onExceptionKycProcess',
      //     ApexRequest.getApplicantId(),
      //     ApexRequest.getApplicationName(),
      //     ex.getStackTraceString()
      //   );
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
  }

  /**
   * @description
   * @author Digital Align Team | 01-27-2022
   * @param Account application
   * @param FundingSubmissionResponse.FundingResult fundingResult
   * @return Account
   **/
  global virtual Account updateFundingDetail(
    Account application,
    FundingSubmissionResponse.FundingResult fundingResult
  ) {
    switch on fundingResult.ExternalApplicationStatus {
      when 'Accept', 'Passed', 'Approved' {
        application.FinServ__Status__c = ApplicationConstant.COMPLETED;
        application.AccountNumber = fundingResult.MemberNumber;
        for (Applicant__c applicant : application.Applicants__r) {
          if (
            applicant.RecordType.Name ==
            ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
          ) {
            applicant.mflow__CustomerNumber__c = fundingResult.MemberNumber;
            applicant.mflow__Status__c = ApplicationConstant.COMPLETED;
            break;
          }
        }
      }
      when else {
        application.FinServ__Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
        application.AccountNumber = fundingResult.MemberNumber;
      }
    }

    if (
      fundingResult?.FinancialAccount != null &&
      fundingResult.FinancialAccount.size() > 0
    ) {
      FundingSubmissionResponse.FinancialAccountResult financialAccountResult = fundingResult.FinancialAccount[0];
      if (String.isNotBlank(financialAccountResult.FinancialAccountId)) {
        FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c(
          Id = financialAccountResult.FinancialAccountId,
          FinServ__FinancialAccountNumber__c = financialAccountResult.AccountNumber
        );
        if (application.FinServ__Status__c == ApplicationConstant.COMPLETED) {
          fa.FinServ__Status__c = 'Paid out';
        }
        SubmissionRepository.upsertRecord(fa);
      }

      if (
        financialAccountResult?.FinancialApplicationTransaction != null &&
        financialAccountResult
          ?.FinancialApplicationTransaction
          ?.FinancialAccountTransactionId != null
      ) {
        FinServ__FinancialAccountTransaction__c fat = new FinServ__FinancialAccountTransaction__c(
          Id = financialAccountResult.FinancialApplicationTransaction.FinancialAccountTransactionId,
          FinServ__TransactionStatus__c = 'Posted'
        );
        SubmissionRepository.upsertRecord(fat);
      }
    }

    SubmissionRepository.upsertRecord(application);
    SubmissionRepository.upsertRecords(application.Applicants__r);
    return application;
  }
}
