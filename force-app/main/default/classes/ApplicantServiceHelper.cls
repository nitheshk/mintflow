/**
 * Copyright (c) 2021 Digital Align
 * @group Helper
 * @author Digital Align Team
 * @reference
 * @description Application service helper
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class ApplicantServiceHelper extends AbstractService {
  @TestVisible
  private static ApplicantServiceHelper serviceInstance;

  public ApplicantServiceHelper() {
    super(ApplicantServiceHelper.class);
  }

  /**
   * @description Provides a singleton instance of ApplicantServiceHelper from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  global static ApplicantServiceHelper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicantServiceHelper) getInstance(
        ApplicantServiceHelper.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description  Send Email to reference person on family connect
   * @author Digital Align Team | 11-09-2021
   **/
  global virtual void notifyFamilyConnectReference() {
    log?.debug('inside notifyFamilyConnectReference');
    try {
      List<Applicant__c> applicants = ApplicantRepository.readApplicantsByApplicationId(
        ApexRequest.getApplicationId()
      );
      CustomerEmailService.getInstance().notifyFamilyMember(applicants);
    } catch (exception ex) {
      log?.error(ex);
    }
  }

  /**
   * @description Create Individual Account and Contact in salesforce
   * @author Digital Align Team | 12-10-2021
   * @param Applicant__c applicant
   * @return Contact
   **/
  //#removeFSC
  /*
  global virtual Contact createAccount(Applicant__c applicant) {
    Account individualAccount = new Account();
    individualAccount.Name = applicant.ApplicantName__c;
    individualAccount.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
      Account.SObjectType,
      'IndustriesIndividual'
    );
    // #info
    // Added for customer community user license only
    // Work for Cusotmer Community plus user without owner assingment
    //individualAccount.OwnerId = UserUtils.getCurrentUser().CreatedById;
    individualAccount.UserAccountType__c = 'IndividualCustomer';
    ApplicantRepository.upsertRecord(individualAccount);
    // Return Individual Contact created by Salesforce , when account is created
    return ApplicantRepository.fetchContactByAccountId(individualAccount.Id);
  } */

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
    memberContact.UserContactType__c = 'IndividualCustomer';
    memberContact.Email = applicant.Email__c;
    memberContact.Phone = applicant.Phone__c;
    memberContact.FinServ__EmailVerified__c = applicant.IsEmailVerified__c;
    memberContact.FinServ__HomePhoneVerified__c = applicant.IsPhoneNumberVerified__c;
    memberContact.FinServ__LastFourDigitSSN__c = applicant.SSN__c.right(4);
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
    memberContact.IncomeVerificationStatus__c = applicant.IncomeVerificationStatus__c;
    memberContact.KYCStatus__c = applicant.KYCStatus__c;
    memberContact.SentiLinkFraudScore__c = applicant.SentiLinkFraudScore__c;
    memberContact.SentiLinkStatus__c = applicant.SentiLinkStatus__c;
    memberContact.MiddleName__c = applicant.MiddleName__c;
    return memberContact;
  }
}
