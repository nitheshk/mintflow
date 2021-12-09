/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Financial Account Service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FinancialAccountService extends AbstractService {
  @TestVisible
  private static FinancialAccountService serviceInstance;

  public FinancialAccountService() {
    super(FinancialAccountService.class);
  }

  /**
   * @description Provides a singleton instance of FinancialAccountService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static FinancialAccountService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (FinancialAccountService) getInstance(
        FinancialAccountService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description Read Financial Account with child record
   * @author Digital Align Team | 10-26-2021
   * @param List<FinServ__FinancialAccount__c> financialAccounts
   * @return List<FinServ__FinancialAccount__c>
   **/
  global virtual List<FinServ__FinancialAccount__c> readFinancialAccountsWithChild(
    List<FinServ__FinancialAccount__c> financialAccounts
  ) {
    return readFinancialAccountsWithChild(
      (new Map<Id, SObject>(financialAccounts)).keySet()
    );
  }

  /**
   * @description  Read Financial Account with child record by ids
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> applicationIds
   * @return List<FinServ__FinancialAccount__c>
   **/
  global virtual List<FinServ__FinancialAccount__c> readFinancialAccountsWithChild(
    Set<Id> applicationIds
  ) {
    return FinancialAccountRepository.readFinancialAccountsWithChild(
      applicationIds
    );
  }

  /**
   * @description Create Financial MemberShip account and Primary Account
   * @author Digital Align Team | 12-02-2021
   * @param Map<String Object> params
   * @return Object
   **/
  global virtual Object createMemberAccount(String resultJson) {
    ApplicationResponseMapper.KYCResult kycResult = (ApplicationResponseMapper.KYCResult) JSON.deserialize(
      resultJson,
      ApplicationResponseMapper.KYCResult.class
    );

    Account application = FinancialAccountRepository.readApplicationWithChild(
      kycResult.ApplicationId
    );

    // Primary is Existing Customer
    if (kycResult.ExistingCustomer == true) {
      return processExistingMember(application, kycResult);
    }

    // Primary Kyc is Approved/Failed and Joint KYC is Approved/Failed
    // update Applicant detail accordingly
    application = updateApplicationKycDetails(application, kycResult);

    // if Application kyc status is approved, then proceed with creating Account & Contact for primary
    // And Open Membership Financial Account and relation with applicant
    createMembershipAccount();

    return null;
  }

  /**
   * @description  Primary is Existing Customer
   * @author Digital Align Team | 12-07-2021
   * @param Account application
   * @param ApplicationResponseMapper.KYCResult kycResult
   * @return Account
   **/
  global virtual Account processExistingMember(
    Account application,
    ApplicationResponseMapper.KYCResult kycResult
  ) {
    application.isMemberFlow__c = false;
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
    FinancialAccountRepository.upsertRecord(application);
    FinancialAccountRepository.upsertRecords(application.Applicants__r);
    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 12-08-2021
   * @param Account application
   * @param ApplicationResponseMapper.KYCResult kycResult
   * @return virtual
   **/
  global virtual Account updateApplicationKycDetails(
    Account application,
    ApplicationResponseMapper.KYCResult kycResult
  ) {
    Map<id, Applicant__c> applicantMap = new Map<Id, Applicant__c>(
      application.Applicants__r
    );

    if (kycResult?.applicants != null) {
      for (
        ApplicationResponseMapper.KYCApplicantResult applicantKyc : kycResult.applicants
      ) {
        Applicant__c applicant = applicantMap.get(applicantKyc.ApplicantId);
        applicant.CustomerNumber__c = applicantKyc.CustomerNumber;
        applicant.OverallDebitBureauResult__c = applicantKyc.OverallDebitBureauResult;
        applicant.CreditScore__c = applicantKyc.CreditScore;
        applicant.QualifiedScore__c = String.valueOf(
          applicantKyc.QualifiedScore
        );
        applicant.CustomScore__c = String.valueOf(applicantKyc.CustomScore);
        applicant.HighRiskConsumer__c = applicantKyc.HighRiskConsumer;
        applicant.QualifiedDecision__c = applicantKyc.QualifiedDecision;
        applicant.IdentityVerificationStatus__c = applicantKyc.IdentityVerificationStatus;
        applicant.OFAC__c = applicantKyc.OFAC;
        applicant.SSNValidation__c = applicantKyc.SSNValidation;
        applicant.RunWithoutKIQ__c = applicantKyc.RunWithoutKIQ;
        applicant.RunWithKIQ__c = applicantKyc.RunWithKIQ;

        //Update Applicant Status based on RunWithKIQ__c Field
        switch on applicant.RunWithKIQ__c {
          when 'Accept', 'Passed' {
            applicant.Status__c = ApplicationConstant.APPROVED;
            if (
              applicant.RecordType.Name ==
              ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
            ) {
              applicant.FlowState__c = 'funding-welcome';
            } else if (
              applicant.RecordType.Name ==
              ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
            ) {
            }
          }
          when 'Failed' {
            applicant.Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
          }
          when else {
            applicant.Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
          }
        }
      }
    }

    application.ExternalApplicationNumber__c = kycResult.ExternalApplicationNumber;
    switch on kycResult.ExternalApplicationStatus {
      when 'Accept', 'Passed' {
        application.FinServ__Status__c = ApplicationConstant.APPROVED;
        application.FlowState__c = 'Funding-Welcome';
      }
      when 'Fraud' {
        application.FinServ__Status__c = ApplicationConstant.REJECTED;
      }
      when else {
        application.FinServ__Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
      }
    }

    return null;
  }

  /**
   * @description
   * @author Digital Align Team | 12-02-2021
   * @return virtual
   **/
  global virtual object createMembershipAccount() {
    return null;
  }
}
