/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class KycReviewService extends AbstractService {
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
    return (new Map<String, String>{ 'Passed' => 'Passed', 'Failed' => 'Failed', 'Accept' => 'Accept' }).get(value);
  }

  /**
   * @description Create Financial MemberShip account and Primary Account
   * @author Digital Align Team | 12-02-2021
   * @param String resultJson
   * @return Application__c
   **/
  global virtual Application__c processMembershipKYC(String resultJson) {
    log?.info('Inside processMembershipKYC');
    ApplicationSubmissionResponse.KYCResult kycResult = (ApplicationSubmissionResponse.KYCResult) JSON.deserialize(
      resultJson,
      ApplicationSubmissionResponse.KYCResult.class
    );
    // When result is null
    if (kycResult == null) {
      throw new CustomException('Unable to process the empty request');
    }
    Application__c application = KycReviewRepository.readApplicationForKYC(kycResult.ApplicationId);
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicationName(application.Name);

    if (application.KYCStatus__c == ApplicationConstant.KYC_PASSED) {
      throw new CustomException('Kyc has already passed for the application ');
    }

    //chatter post on record level
    NotificationBuilder.chatterMessagePost(application.Id, 'Kyc Result : ' + resultJson);

    // roll back whole transaction on failure
    Savepoint sp = Database.setSavepoint();
    try {
      // Primary is Existing Customer
      if (kycResult.IsExistingCustomer == true) {
        return this.processExistingMember(application, kycResult);
      }

      // Primary Kyc is Approved/Failed and Joint KYC is Approved/Failed
      // update Applicant detail accordingly
      application = this.updateApplicationKycDetails(application, kycResult);

      // if Application kyc status is approved, then proceed with creating Account & Contact for primary/Joint

      if (application.KYCStatus__c == ApplicationConstant.KYC_PASSED) {
        // account and contact
        this.createMemberAccount(application);
        //update financial Account details
        application = this.updateFinancialAccount(application, kycResult);

        //Send Funding Email Link to primary
        CustomerEmailService.getInstance().fundingLinkOnKycApproval(application);
        NotificationService.getInstance()
          .dispatchKycNotification('onSuccessKycProcess', application.Id, application.Name, null);
      } else {
        NotificationService.getInstance()
          .dispatchKycNotification('onReviewKycProcess', application.Id, application.Name, null);
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
    } finally {
      log?.info('Completed processMembershipKYC');
    }
  }

  /**
   * @description  Primary is Existing Customer
   * Used when kyc result is return from Server
   * @author Digital Align Team | 12-07-2021
   * @param Application__c application
   * @param ApplicationSubmissionResponse.KYCResult kycResult
   * @return Application__c
   **/
  global virtual Application__c processExistingMember(
    Application__c application,
    ApplicationSubmissionResponse.KYCResult kycResult
  ) {
    log?.info('Inside processExistingMember');
    application.isMemberFlow__c = false;
    application.Status__c = ApplicationConstant.CANCELLED;
    application.mflow__Stage__c = ApplicationConstant.STAGE_EXISTING_CUSTOMER;
    application.mflow__FlowState__c = ApplicationConstant.FINAL_CONFIRMATION;
    for (Applicant__c applicant : application.Applicants__r) {
      if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        applicant.IsExistingCustomer__c = true;
      }
      applicant.mflow__Status__c = ApplicationConstant.CANCELLED;
      applicant.mflow__FlowState__c = ApplicationConstant.FINAL_CONFIRMATION;
    }
    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      financialAccount.ExternalApplicationNumber__c = kycResult.ExternalApplicationNumber;
      financialAccount.ExternalApplicationStatus__c = kycResult.ExternalApplicationStatus;
    }

    NotificationBuilder.chatterMessagePost(
      application.Id,
      'Application has been cancelled because, Primary member already linked with membership account'
    );
    KycReviewRepository.upsertRecords(application.Applicants__r);
    KycReviewRepository.upsertRecords(application.FinancialAccounts__r);
    KycReviewRepository.upsertRecord(application);
    log?.info('Completed processExistingMember');
    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 12-08-2021
   * @param Application__c application
   * @param ApplicationSubmissionResponse.KYCResult kycResult
   * @return Application__c
   **/
  global virtual Application__c updateApplicationKycDetails(
    Application__c application,
    ApplicationSubmissionResponse.KYCResult kycResult
  ) {
    Map<Id, Applicant__c> applicantMap = new Map<Id, Applicant__c>(application.Applicants__r);

    Boolean kycSuccessForApplicants = true;

    for (ApplicationSubmissionResponse.KYCApplicantResult applicantKyc : kycResult.applicants) {
      Applicant__c applicant = applicantMap.get(applicantKyc.ApplicantId);
      if (applicant == null) {
        continue;
      }
      applicant.CustomerNumber__c = applicantKyc.CustomerNumber;
      applicant.OverallDebitBureauResult__c = this.getStatusMapping(null, applicantKyc.OverallDebitBureauResult);
      // Credit Report is not generated if CreditScore =NA
      applicant.CreditScore__c = applicantKyc.CreditScore == 'NA' ? null : integer.valueof(applicantKyc.CreditScore);
      applicant.mflow__CreditScoreStatus__c = applicantKyc.CreditScore == 'NA' ? 'Reorder' : 'Verified';
      applicant.QualifiedScore__c = applicantKyc.QualifiedScore;
      applicant.CustomerScore__c = applicantKyc.CustomerScore;
      applicant.HighRiskConsumer__c = this.getStatusMapping(null, applicantKyc.HighRiskConsumer);
      applicant.QualifiedDecision__c = this.getStatusMapping(null, applicantKyc.QualifiedDecision);
      applicant.IdentityVerificationStatus__c = this.getStatusMapping(null, applicantKyc.IdentityVerificationStatus);
      applicant.OFAC__c = this.getStatusMapping(null, applicantKyc.OFAC);
      applicant.SSNValidation__c = applicantKyc.SSNValidation;
      applicant.RunWithoutKIQ__c = this.getStatusMapping(null, applicantKyc.RunWithoutKIQ);
      applicant.RunWithKIQ__c = this.getStatusMapping(null, applicantKyc.RunWithKIQ);

      //Update Applicant Status based on RunWithKIQ__c Field
      switch on applicant.RunWithKIQ__c {
        when 'Accept', 'Passed' {
          if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
            applicant.FlowState__c = ApplicationConstant.FUNDING_FUNDING;
          }
          applicant.mflow__Status__c = ApplicationConstant.FUNDING_IN_PROGRESS;
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

    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      financialAccount.ExternalApplicationNumber__c = kycResult.ExternalApplicationNumber;
      financialAccount.ExternalApplicationStatus__c = kycResult.ExternalApplicationStatus;
    }
    application.Stage__c = null;

    switch on kycResult.ExternalApplicationStatus {
      // when 'Accept', 'Passed', 'Approved' {
      //   application.Status__c = ApplicationConstant.IN_PROGRESS;
      //   application.KYCStatus__c = ApplicationConstant.KYC_PASSED;
      //   application.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
      // }
      when 'Fraud' {
        application.Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
        application.KYCStatus__c = ApplicationConstant.KYC_FAILED;
      }
      when else {
        if (kycSuccessForApplicants) {
          application.Status__c = ApplicationConstant.FUNDING_IN_PROGRESS;
          application.KYCStatus__c = ApplicationConstant.KYC_PASSED;
          application.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
        } else {
          application.Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
          application.KYCStatus__c = ApplicationConstant.KYC_UNDER_REVIEW;
        }
      }
    }
    KycReviewRepository.upsertRecords(application.Applicants__r);
    KycReviewRepository.upsertRecords(application.FinancialAccounts__r);
    KycReviewRepository.upsertRecord(application);
    return application;
  }

  /**
   * @description create Membership Account
   * Create Contact and Account in system if contact is not already present
   * @author Digital Align Team | 12-10-2021
   * @param Application__c application
   * @return Application__c
   **/
  global virtual Application__c createMemberAccount(Application__c application) {
    String filter = '';
    Map<Id, Applicant__c> applicantToProcess = new Map<Id, Applicant__c>();

    for (Applicant__c applicant : application.Applicants__r) {
      applicantToProcess.put(applicant.Id, applicant);
      if (String.isNotBlank(filter)) {
        filter += ' OR ';
      }
      filter += '(mflow__SSN__c=\'' + applicant.SSN__c?.trim() + '\' AND ';
      filter += 'LastName=\'' + applicant.LastName__c?.trim() + '\')';
    }

    // #Attribute
    List<Contact> existingContacts = KycReviewRepository.fetchExistingContacts(filter);
    // #Attribute
    Map<String, Contact> ssnVsContact = new Map<String, Contact>();
    for (Contact con : existingContacts) {
      ssnVsContact.put(con.SSN__c, con);
    }

    List<Contact> contactToUpsert = new List<Contact>();
    for (Applicant__c applicant : applicantToProcess.values()) {
      if (ssnVsContact.containsKey(applicant.SSN__c)) {
        Contact memberContact = this.mapApplicantWithContact(applicant, ssnVsContact.get(applicant.SSN__c));
        applicant.Contact__c = memberContact.Id;
        applicant.Contact__r = memberContact;
        contactToUpsert.add(memberContact);
      } else {
        Account memberAccount = this.createAccount(applicant);
        Contact memberContact = new Contact(AccountId = memberAccount.Id);
        memberContact = this.mapApplicantWithContact(applicant, memberContact);
        KycReviewRepository.upsertRecord(memberContact);
        applicant.Contact__c = memberContact.Id;
        applicant.Contact__r = memberContact;
        contactToUpsert.add(memberContact);
      }
    }

    KycReviewRepository.upsertRecords(contactToUpsert);
    KycReviewRepository.upsertRecords(application.Applicants__r);
    return application;
  }

  /**
   * @description Create Individual Account and Contact in salesforce
   * @author Digital Align Team | 12-10-2021
   * @param Applicant__c applicant
   * @return Account
   **/
  global virtual Account createAccount(Applicant__c applicant) {
    Account individualAccount = new Account();
    individualAccount.Name = applicant.ApplicantName__c;
    // #info
    // Added for customer community user license only
    // Work for Cusotmer Community plus user without owner assingment
    //individualAccount.OwnerId = UserUtils.getCurrentUser().CreatedById;
    individualAccount.UserAccountType__c = 'IndividualCustomer';
    KycReviewRepository.upsertRecord(individualAccount);
    return individualAccount;
  }

  /**
   * @description map applicant data with contact data
   * @author Digital Align Team | 12-10-2021
   * @param Applicant__c applicant
   * @param Contact memberContact
   * @return Contact
   **/
  global virtual Contact mapApplicantWithContact(Applicant__c applicant, Contact memberContact) {
    //Not existing Contact then map new names
    if (String.isBlank(memberContact.Id)) {
      memberContact.FirstName = applicant.FirstName__c;
      memberContact.LastName = applicant.LastName__c;
      memberContact.SSN__c = applicant.SSN__c;
    }
    memberContact.UserContactType__c = 'IndividualCustomer';
    memberContact.Email = applicant.Email__c;
    memberContact.Phone = applicant.Phone__c;
    memberContact.IsEmailVerified__c = applicant.IsEmailVerified__c;
    memberContact.IsPhoneNumberVerified__c = applicant.IsPhoneNumberVerified__c;
    memberContact.RunWithKIQ__c = applicant.RunWithKIQ__c;
    memberContact.RunWithoutKIQ__c = applicant.RunWithoutKIQ__c;
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
    memberContact.FraudStatus__c = applicant.FraudStatus__c;
    memberContact.KYCStatus__c = applicant.KYCStatus__c;
    memberContact.SentiLinkFraudScore__c = applicant.SentiLinkFraudScore__c;
    memberContact.SentiLinkStatus__c = applicant.SentiLinkStatus__c;
    memberContact.MiddleName__c = applicant.MiddleName__c;
    return memberContact;
  }

  /**
   * @description  Create financial membership account record
   * @author Digital Align Team | 03-09-2022
   * @param Application__c application
   * @param ApplicationSubmissionResponse.KYCResult kycResult
   * @return Application__c
   **/
  global virtual Application__c updateFinancialAccount(
    Application__c application,
    ApplicationSubmissionResponse.KYCResult kycResult
  ) {
    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      financialAccount.Status__c = ApplicationConstant.FUNDING_IN_PROGRESS;
    }
    KycReviewRepository.upsertRecords(application.FinancialAccounts__r);

    return application;
  }
}
