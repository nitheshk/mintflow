/**
 * Copyright (c) 2021 Digital Align
 * @group Helper
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicationServiceHelper extends AbstractService {
  @TestVisible
  private static ApplicationServiceHelper serviceInstance;

  public ApplicationServiceHelper() {
    super(ApplicationServiceHelper.class);
  }

  /**
   * @description Provides a singleton instance of ApplicationServiceHelper from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static ApplicationServiceHelper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicationServiceHelper) getInstance(
        ApplicationServiceHelper.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description get current ipaddress
   * @author Digital Align Team | 10-11-2021
   * @return String
   **/
  global virtual String getIpAddress() {
    String ipAddress;
    //System.auth.SessionManagement.getCurrentSession().get('SourceIp');

    if (ApexPages.currentPage() != null && String.isBlank(ipAddress)) {
      ipAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
      // X-Salesforce-SIP has the value when no caching integration or via secure URL.
      if (String.isBlank(ipAddress)) {
        ipAddress = ApexPages.currentPage()
          .getHeaders()
          .get('X-Salesforce-SIP');
      }
      // get IP address when no caching (sandbox, dev, secure urls)
      if (String.isBlank(ipAddress)) {
        ipAddress = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
      }
    }
    log?.info('getIpAddress -> IP address -> ' + ipAddress);
    return ipAddress;
  }

  /**
   * @description resolve branch location
   * @author Digital Align Team | 12-03-2021
   * @param Account application
   * @return Account
   **/
  global virtual Account resolveBranchLocation(Account application) {
    application.FinServ__BranchCode__c = '0001';
    application.FinServ__BranchName__c = 'Main Branch';
    return application;
  }

  /**
   * @description resolve application field before saving
   * @author Digital Align Team | 10-25-2021
   * @param Account application
   * @return Account
   **/
  global virtual Account resolveApplicationFields(Account application) {
    // update and add application related fields based on the values..

    return application;
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
   * @return virtual
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
        log?.debug('Applicant Kyc : ' + applicantKyc);
        Applicant__c applicant = applicantMap.get(applicantKyc.ApplicantId);
        applicant.CustomerNumber__c = applicantKyc.CustomerNumber;
        applicant.OverallDebitBureauResult__c = applicantKyc.OverallDebitBureauResult;
        applicant.CreditScore__c = applicantKyc.CreditScore;
        applicant.QualifiedScore__c = applicantKyc.QualifiedScore;
        applicant.CustomerScore__c = applicantKyc.CustomerScore;
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
              applicant.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
            }
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
        application.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
      }
      when 'Fraud' {
        application.FinServ__Status__c = ApplicationConstant.REJECTED;
      }
      when else {
        application.FinServ__Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
      }
    }
    FinancialAccountRepository.upsertRecords(application.Applicants__r);
    FinancialAccountRepository.upsertRecord(application);
    return application;
  }
}
