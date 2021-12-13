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
  global virtual Account createMemberAccount(String resultJson) {
    ApplicationResponseMapper.KYCResult kycResult = (ApplicationResponseMapper.KYCResult) JSON.deserialize(
      resultJson,
      ApplicationResponseMapper.KYCResult.class
    );

    // When result is null
    if (kycResult == null) {
      throw new CustomException('Unable to process the empty request');
    }

    Account application = FinancialAccountRepository.readApplicationWithChild(
      kycResult.ApplicationId
    );

    // Primary is Existing Customer
    if (kycResult.IsExistingCustomer == true) {
      return processExistingMember(application, kycResult);
    }

    // Primary Kyc is Approved/Failed and Joint KYC is Approved/Failed
    // update Applicant detail accordingly
    application = updateApplicationKycDetails(application, kycResult);

    // if Application kyc status is approved, then proceed with creating Account & Contact for primary
    // And Open Membership Financial Account and relation with applicant
    if (application.FinServ__Status__c == ApplicationConstant.APPROVED) {
      createMembershipAccount(application);
    }

    return application;
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

  /**
   * @description
   * @author Digital Align Team | 12-10-2021
   * @param Account application
   * @return Account
   **/
  global virtual Account createMembershipAccount(Account application) {
    String filter = '';
    Map<Id, Applicant__c> applicantToProcess = new Map<Id, Applicant__c>();

    for (Applicant__c applicant : application.Applicants__r) {
      if (
        applicant.RecordType.Name ==
        ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
      ) {
        applicantToProcess.put(applicant.Id, applicant);
        if (String.isNotBlank(filter)) {
          filter += ' OR ';
        }
        filter += 'FinServ__TaxId__c=\'' + applicant.SSN__c + '\' AND ';
        filter += 'LastName=\'' + applicant.LastName__c + '\'';
        break;
      }
    }
    log?.debug('filter : ' + filter);
    // #Attribute
    List<Contact> existingContacts = FinancialAccountRepository.fetchExistingContacts(
      filter
    );
    log?.debug('Existing Contacts : ' + existingContacts);
    // #Attribute
    Map<String, Contact> ssnVsContact = new Map<String, Contact>();
    for (Contact con : existingContacts) {
      ssnVsContact.put(con.FinServ__TaxId__c, con);
    }

    List<Contact> contactToUpsert = new List<Contact>();
    for (Applicant__c applicant : applicantToProcess.values()) {
      if (ssnVsContact.containsKey(applicant.SSN__c)) {
        Contact memberContact = mapApplicantWithContact(
          applicant,
          ssnVsContact.get(applicant.SSN__c),
          true
        );
        applicant.Contact__c = memberContact.Id;
        contactToUpsert.add(memberContact);
      } else {
        Contact memberContact = createAccount(applicant);
        applicant.Contact__c = memberContact.Id;
        memberContact = mapApplicantWithContact(
          applicant,
          memberContact,
          false
        );
        contactToUpsert.add(memberContact);
      }
    }

    FinancialAccountRepository.upsertRecords(contactToUpsert);
    FinancialAccountRepository.upsertRecords(application.Applicants__r);
    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 12-10-2021
   * @param Applicant__c applicant
   * @return virtual
   **/
  global virtual Contact createAccount(Applicant__c applicant) {
    Account individualAccount = new Account();
    individualAccount.Name = applicant.Name;
    individualAccount.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
      Account.SObjectType,
      'IndustriesIndividual'
    );
    FinancialAccountRepository.upsertRecord(individualAccount);
    // Return Individual Contact created by Salesforce , when account is created
    return FinancialAccountRepository.fetchContactByAccountId(
      individualAccount.Id
    );
  }

  /**
   * @description map applicant data with contact data
   * @author Digital Align Team | 12-10-2021
   * @param Applicant__c applicant
   * @param Contact memberContact
   * @param Boolean isExistingContact
   * @return Contact
   **/
  global virtual Contact mapApplicantWithContact(
    Applicant__c applicant,
    Contact memberContact,
    Boolean isExistingContact
  ) {
    if (!isExistingContact) {
      memberContact.FirstName = applicant.FirstName__c;
      memberContact.LastName = applicant.LastName__c;
      memberContact.FinServ__TaxId__c = applicant.SSN__c;
    }
    memberContact.Email = applicant.Email__c;
    memberContact.Phone = applicant.Phone__c;
    memberContact.FinServ__EmailVerified__c = applicant.IsEmailVerified__c;
    memberContact.FinServ__HomePhoneVerified__c = applicant.IsPhoneNumberVerified__c;
    memberContact.FinServ__LastFourDigitSSN__c = applicant.SSN__c.right(4);
    memberContact.RunWithKIQ__c = applicant.RunWithKIQ__c;
    memberContact.RunwithoutKIQ__c = applicant.RunWithoutKIQ__c;
    memberContact.IdentityVerificationStatus__c = applicant.IdentityVerificationStatus__c;
    memberContact.Birthdate = applicant.Birthdate__c;
    memberContact.SSNValidation__c = applicant.SSNValidation__c;
    memberContact.CreditScore__c = applicant.CreditScore__c;
    memberContact.CustomerScore__c = applicant.CustomerScore__c;
    memberContact.HighRiskConsumer__c = applicant.HighRiskConsumer__c;
    memberContact.OFAC__c = applicant.OFAC__c;
    memberContact.OverallDebitBureauResult__c = applicant.OverallDebitBureauResult__c;
    memberContact.QualifiedDecision__c = applicant.QualifiedDecision__c;
    memberContact.QualifiedScore__c = applicant.QualifiedScore__c;
    // #Pending Missing Fields in Contact
    //applicant.FraudStatus__c
    //applicant.IncomeVerificationStatus__c
    //applicant.KYCStatus__c
    //applicant.MiddleName__c
    //applicant.SentiLinkFraudScore__c
    //applicant.SentiLinkStatus__c
    return memberContact;
  }
}
