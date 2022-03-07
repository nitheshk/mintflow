/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class ApplicantService extends AbstractService {
  @TestVisible
  private static ApplicantService serviceInstance;
  private ApplicantServiceHelper helper = ApplicantServiceHelper.getInstance();

  public ApplicantService() {
    super(ApplicantService.class);
  }

  /**
   * @description Provides a singleton instance of ApplicantService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static ApplicantService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicantService) getInstance(ApplicantService.class);
    }
    return serviceInstance;
  }

  /**
   * @description Read all applicant by applicant records
   * @author Digital Align Team | 10-26-2021
   * @param List<Applicant__c> applicants
   **/
  global virtual List<Applicant__c> readApplicantsWithChild(
    List<Applicant__c> applicants
  ) {
    return readApplicantsWithChild(new Map<Id, SObject>(applicants).keySet());
  }

  /**
   * @description Read all applicant by applicant Ids
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> applicantIds
   **/
  global virtual List<Applicant__c> readApplicantsWithChild(
    Set<Id> applicantIds
  ) {
    return ApplicantRepository.readApplicantsWithChild(applicantIds);
  }

  /**
   * @description Read applicant by applicant Id
   * @author Digital Align Team | 10-26-2021
   * @param String applicantId
   **/
  global virtual Applicant__c readApplicantWithChild(Id applicantId) {
    return ApplicantRepository.readApplicantWithChild(applicantId);
  }

  /**
   * @description before saving Applicants
   * @author Digital Align Team | 11-09-2021
   * @param List<Applicant__c> applicants
   * @return List<Applicant__c>
   **/
  global virtual List<Applicant__c> beforeSaveApplicants(
    List<Applicant__c> applicants
  ) {
    return applicants;
  }

  /**
   * @description Save applicants with child record
   * @author Digital Align Team | 10-25-2021
   * @param String applicationId
   * @param List<Applicant__c> applicants
   * @return virtual
   **/
  global virtual List<Applicant__c> saveApplicants(
    List<Applicant__c> applicants,
    String applicationId
  ) {
    //#pending applicationId never used
    //before saving applicants
    applicants = ApplicantService.getInstance()
      .beforeSaveApplicants(applicants);
    //save point count against DML operation
    Savepoint sp = Database.setSavepoint();
    try {
      applicants = ApplicationPersistService.getInstance()
        .saveApplicants(applicants, ApexRequest.getApplicationId());
    } catch (Exception ex) {
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
    //after saving appliants and child records
    return ApplicantService.getInstance().afterSaveApplicants(applicants);
  }
  /**
   * @description after saving applicants
   * @author Digital Align Team | 11-09-2021
   * @param List<Applicant__c> applicants
   * @return virtual
   **/
  global virtual List<Applicant__c> afterSaveApplicants(
    List<Applicant__c> applicants
  ) {
    String currentPage = ApexRequest.getRequest().currentPage;
    switch on currentPage {
      when 'personal-info' {
        helper.notifyFamilyConnectReference();
      }
    }
    return applicants;
  }

  /**
   * @description before saving Applicant
   * @author Digital Align Team | 11-09-2021
   * @param Applicant__c applicant
   * @return virtual
   **/
  global virtual Applicant__c beforeSaveApplicant(Applicant__c applicant) {
    return applicant;
  }

  /**
   * @description save applicant with child record
   * @author Digital Align Team | 10-27-2021
   * @param Applicant__c applicant
   * @param String applicationId
   * @return Applicant__c
   **/
  global virtual Applicant__c saveApplicant(
    Applicant__c applicant,
    String applicationId
  ) {
    applicant = beforeSaveApplicant(applicant);
    Savepoint sp = Database.setSavepoint();
    try {
      applicant = ApplicationPersistService.getInstance()
        .saveApplicant(applicant, applicationId);
      ApplicantRepository.upsertRecord(applicant);

      if (!ApexRequest.getParams().containsKey('ApexSkipApplicantChild')) {
        applicant = ApplicationPersistService.getInstance()
          .saveApplicantChild(applicant);
      }
    } catch (Exception ex) {
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
    return afterSaveApplicant(applicant);
  }
  /**
   * @description  after saving applicant
   * @author Digital Align Team | 11-09-2021
   * @param Applicant__c applicant
   * @return virtual
   **/
  global virtual Applicant__c afterSaveApplicant(Applicant__c applicant) {
    String currentPage = ApexRequest.getRequest().currentPage;
    switch on currentPage {
      when 'personal-info' {
        helper.notifyFamilyConnectReference();
      }
    }
    return applicant;
  }

  /**
   * @description create Membership Account
   * Create Contact and Account in system if contact is not already present
   * @author Digital Align Team | 12-10-2021
   * @param Application__c application
   * @return Application__c
   **/
  global virtual Application__c createMemberAccount(
    Application__c application
  ) {
    String filter = '';
    Map<Id, Applicant__c> applicantToProcess = new Map<Id, Applicant__c>();

    for (Applicant__c applicant : application.Applicants__r) {
      applicantToProcess.put(applicant.Id, applicant);
      if (String.isNotBlank(filter)) {
        filter += ' OR ';
      }
      filter += '(mflow__SSN__c=\'' + applicant.SSN__c + '\' AND ';
      filter += 'LastName=\'' + applicant.LastName__c + '\')';
    }

    // #Attribute
    List<Contact> existingContacts = ApplicantRepository.fetchExistingContacts(
      filter
    );
    // #Attribute
    Map<String, Contact> ssnVsContact = new Map<String, Contact>();
    for (Contact con : existingContacts) {
      ssnVsContact.put(con.SSN__c, con);
    }

    List<Contact> contactToUpsert = new List<Contact>();
    for (Applicant__c applicant : applicantToProcess.values()) {
      if (ssnVsContact.containsKey(applicant.SSN__c)) {
        Contact memberContact = helper.mapApplicantWithContact(
          applicant,
          ssnVsContact.get(applicant.SSN__c)
        );
        applicant.Contact__c = memberContact.Id;
        applicant.Contact__r = memberContact;
        contactToUpsert.add(memberContact);
      } else {
        Account memberAccount = helper.createAccount(applicant);
        Contact memberContact = new Contact(AccountId = memberAccount.Id);
        memberContact = helper.mapApplicantWithContact(
          applicant,
          memberContact
        );
        ApplicantRepository.upsertRecord(memberContact);
        applicant.Contact__c = memberContact.Id;
        applicant.Contact__r = memberContact;
        contactToUpsert.add(memberContact);
      }
    }

    ApplicantRepository.upsertRecords(contactToUpsert);
    ApplicantRepository.upsertRecords(application.Applicants__r);
    return application;
  }
}
