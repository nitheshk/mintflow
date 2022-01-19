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
   * @description  Primary is Existing Customer
   * Used when kyc result is return from Server
   * @author Digital Align Team | 12-07-2021
   * @param Account application
   * @param ApplicationResponseMapper.KYCResult kycResult
   * @return Account
   **/
  global virtual Account processExistingMember(
    Account application,
    ApplicationResponseMapper.KYCResult kycResult
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
   * @param ApplicationResponseMapper.KYCResult kycResult
   * @return Account
   **/
  global virtual Account updateApplicationKycDetails(
    Account application,
    ApplicationResponseMapper.KYCResult kycResult
  ) {
    Map<Id, Applicant__c> applicantMap = new Map<Id, Applicant__c>(
      application.Applicants__r
    );

    if (kycResult?.applicants != null) {
      for (
        ApplicationResponseMapper.KYCApplicantResult applicantKyc : kycResult.applicants
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
          }
          when else {
            applicant.Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
            applicant.mflow__KYCStatus__c = ApplicationConstant.KYC_UNDER_REVIEW;
          }
        }
      }
    }

    application.ExternalApplicationNumber__c = kycResult.ExternalApplicationNumber;
    application.ExternalApplicationStatus__c = kycResult.ExternalApplicationStatus;
    application.Stage__c = null;
    switch on kycResult.ExternalApplicationStatus {
      when 'Accept', 'Passed', 'Approved' {
        application.FinServ__Status__c = ApplicationConstant.IN_PROGRESS;
        application.FinServ__KYCStatus__c = ApplicationConstant.KYC_PASSED;
        application.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
      }
      when 'Fraud' {
        application.FinServ__Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
        application.FinServ__KYCStatus__c = ApplicationConstant.KYC_FAILED;
      }
      when else {
        application.FinServ__Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
        application.FinServ__KYCStatus__c = ApplicationConstant.KYC_UNDER_REVIEW;
      }
    }
    FinancialAccountRepository.upsertRecords(application.Applicants__r);
    FinancialAccountRepository.upsertRecord(application);
    return application;
  }
}
