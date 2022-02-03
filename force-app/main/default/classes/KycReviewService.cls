/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class KycReviewService extends AbstractService {
  @TestVisible
  private static KycReviewService serviceInstance;

  public KycReviewService() {
    super(KycReviewService.class);
  }

  /**
   * @description Provides a singleton instance of KycReviewService from which all other class methods can be accessed.
   * @author Digital Align Team | 01/17/2022
   * @return Object  singleton
   **/
  public static KycReviewService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (KycReviewService) getInstance(KycReviewService.class);
    }
    return serviceInstance;
  }

  //getStatusMapping
  global virtual String getStatusMapping(String fieldName, String value) {
    return (new Map<String, String>{
        'Passed' => 'Passed',
        'Failed' => 'Failed',
        'Accept' => 'Accept'
      })
      .get(value);
  }

  /**
   * @description Create Financial MemberShip account and Primary Account
   * @author Digital Align Team | 12-02-2021
   * @param String resultJson
   * @return Account
   **/
  global virtual Account processMembershipKYC(String resultJson) {
    ApplicationSubmissionResponse.KYCResult kycResult = (ApplicationSubmissionResponse.KYCResult) JSON.deserialize(
      resultJson,
      ApplicationSubmissionResponse.KYCResult.class
    );
    // When result is null
    if (kycResult == null) {
      throw new CustomException('Unable to process the empty request');
    }
    Account application = ApplicationRepository.readApplicationForKYC(
      kycResult.ApplicationId
    );
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicationName(application.ApplicationNumber__c);

    if (application.FinServ__KYCStatus__c == ApplicationConstant.KYC_PASSED) {
      throw new CustomException('Kyc has already passed for the application ');
    }

    //chatter post on record level
    NotificationBuilder.chatterMessagePost(
      application.Id,
      'Kyc Result : ' + resultJson
    );

    // roll back whole transaction on failure
    Savepoint sp = Database.setSavepoint();
    try {
      // Primary is Existing Customer
      if (kycResult.IsExistingCustomer == true) {
        return KycReviewService.getInstance()
          .processExistingMember(application, kycResult);
      }

      // Primary Kyc is Approved/Failed and Joint KYC is Approved/Failed
      // update Applicant detail accordingly
      application = KycReviewService.getInstance()
        .updateApplicationKycDetails(application, kycResult);

      // if Application kyc status is approved, then proceed with creating Account & Contact for primary
      // And Open Membership Financial Account and relation with applicant

      if (application.FinServ__KYCStatus__c == ApplicationConstant.KYC_PASSED) {
        ApplicantService.getInstance().createMemberAccount(application);

        application = FinancialAccountService.getInstance()
          .createMembershipFinancialAccount(application);

        //Send Funding Email Link to primary
        CustomerEmailService.getInstance()
          .fundingLinkOnKycApproval(application);
        NotificationService.getInstance()
          .dispatchKycNotification(
            'onSuccessKycProcess',
            application.Id,
            application.Name,
            null
          );
      } else {
        NotificationService.getInstance()
          .dispatchKycNotification(
            'onReviewKycProcess',
            application.Id,
            application.Name,
            null
          );
      }
      return application;
    } catch (Exception ex) {
      NotificationService.getInstance()
        .dispatchKycNotification(
          'onExceptionKycProcess',
          ApexRequest.getApplicantId(),
          ApexRequest.getApplicationName(),
          ex.getStackTraceString()
        );
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
  }

  /**
   * @description  Primary is Existing Customer
   * Used when kyc result is return from Server
   * @author Digital Align Team | 12-07-2021
   * @param Account application
   * @param ApplicationSubmissionResponse.KYCResult kycResult
   * @return Account
   **/
  global virtual Account processExistingMember(
    Account application,
    ApplicationSubmissionResponse.KYCResult kycResult
  ) {
    log?.debug('Inside processExistingMember');
    application.isMemberFlow__c = false;
    application.ExternalApplicationNumber__c = kycResult.ExternalApplicationNumber;
    application.ExternalApplicationStatus__c = kycResult.ExternalApplicationStatus;
    application.FinServ__Status__c = ApplicationConstant.CANCELLED;
    application.mflow__Stage__c = ApplicationConstant.STAGE_EXISTING_CUSTOMER;
    application.mflow__FlowState__c = ApplicationConstant.FINAL_CONFIRMATION;
    for (Applicant__c applicant : application.Applicants__r) {
      if (
        applicant.RecordType.Name ==
        ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
      ) {
        applicant.mflow__Status__c = ApplicationConstant.CANCELLED;
        applicant.mflow__FlowState__c = ApplicationConstant.FINAL_CONFIRMATION;
      } else {
        // #pending Joint also need to mark has cancelled
        applicant.mflow__Status__c = ApplicationConstant.CANCELLED;
        applicant.mflow__FlowState__c = ApplicationConstant.FINAL_CONFIRMATION;
      }
    }
    FinancialAccountRepository.upsertRecords(application.Applicants__r);
    FinancialAccountRepository.upsertRecord(application);
    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 12-08-2021
   * @param Account application
   * @param ApplicationSubmissionResponse.KYCResult kycResult
   * @return Account
   **/
  global virtual Account updateApplicationKycDetails(
    Account application,
    ApplicationSubmissionResponse.KYCResult kycResult
  ) {
    Map<Id, Applicant__c> applicantMap = new Map<Id, Applicant__c>(
      application.Applicants__r
    );

    Boolean kycSuccessForApplicants = true;
    if (kycResult?.applicants != null) {
      for (
        ApplicationSubmissionResponse.KYCApplicantResult applicantKyc : kycResult.applicants
      ) {
        Applicant__c applicant = applicantMap.get(applicantKyc.ApplicantId);
        if (applicant == null) {
          continue;
        }
        applicant.CustomerNumber__c = applicantKyc.CustomerNumber;
        applicant.OverallDebitBureauResult__c = this.getStatusMapping(
          null,
          applicantKyc.OverallDebitBureauResult
        );
        applicant.CreditScore__c = applicantKyc.CreditScore;
        applicant.QualifiedScore__c = applicantKyc.QualifiedScore;
        applicant.CustomerScore__c = applicantKyc.CustomerScore;
        applicant.HighRiskConsumer__c = this.getStatusMapping(
          null,
          applicantKyc.HighRiskConsumer
        );
        applicant.QualifiedDecision__c = this.getStatusMapping(
          null,
          applicantKyc.QualifiedDecision
        );
        applicant.IdentityVerificationStatus__c = this.getStatusMapping(
          null,
          applicantKyc.IdentityVerificationStatus
        );
        applicant.OFAC__c = this.getStatusMapping(null, applicantKyc.OFAC);
        applicant.SSNValidation__c = applicantKyc.SSNValidation;
        applicant.RunWithoutKIQ__c = this.getStatusMapping(
          null,
          applicantKyc.RunWithoutKIQ
        );
        applicant.RunWithKIQ__c = this.getStatusMapping(
          null,
          applicantKyc.RunWithKIQ
        );

        //Update Applicant Status based on RunWithKIQ__c Field
        switch on applicant.RunWithKIQ__c {
          when 'Accept', 'Passed' {
            if (
              applicant.RecordType.Name ==
              ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
            ) {
              applicant.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
            }
            applicant.mflow__Status__c = ApplicationConstant.IN_PROGRESS;
            applicant.mflow__KYCStatus__c = ApplicationConstant.KYC_PASSED;
          }
          when 'Failed' {
            applicant.mflow__Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
            applicant.mflow__KYCStatus__c = ApplicationConstant.KYC_FAILED;
            kycSuccessForApplicants = false;
          }
          when else {
            applicant.Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
            applicant.mflow__KYCStatus__c = ApplicationConstant.KYC_UNDER_REVIEW;
            kycSuccessForApplicants = false;
          }
        }
      }
    }

    application.ExternalApplicationNumber__c = kycResult.ExternalApplicationNumber;
    application.ExternalApplicationStatus__c = kycResult.ExternalApplicationStatus;
    application.Stage__c = null;

    switch on kycResult.ExternalApplicationStatus {
      // when 'Accept', 'Passed', 'Approved' {
      //   application.FinServ__Status__c = ApplicationConstant.IN_PROGRESS;
      //   application.FinServ__KYCStatus__c = ApplicationConstant.KYC_PASSED;
      //   application.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
      // }
      when 'Fraud' {
        application.FinServ__Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
        application.FinServ__KYCStatus__c = ApplicationConstant.KYC_FAILED;
      }
      when else {
        if (kycSuccessForApplicants) {
          application.FinServ__Status__c = ApplicationConstant.IN_PROGRESS;
          application.FinServ__KYCStatus__c = ApplicationConstant.KYC_PASSED;
          application.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
        } else {
          application.FinServ__Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
          application.FinServ__KYCStatus__c = ApplicationConstant.KYC_UNDER_REVIEW;
        }
      }
    }
    FinancialAccountRepository.upsertRecords(application.Applicants__r);
    FinancialAccountRepository.upsertRecord(application);
    return application;
  }
}
