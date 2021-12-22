/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier,PMD.CognitiveComplexity')
global with sharing class ApplicationPersistService extends AbstractService {
  @TestVisible
  private static ApplicationPersistService serviceInstance;

  public ApplicationPersistService() {
    super(ApplicationPersistService.class);
  }

  /**
   * @description Provides a singleton instance of ApplicationPersistService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static ApplicationPersistService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicationPersistService) getInstance(
        ApplicationPersistService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align Team | 10-25-2021
   * @param Account application
   * @return virtual
   **/
  global virtual Account saveApplication(Account application) {
    //Process Application Mapping
    {
      if (String.isBlank(application.Id)) {
        application.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
          Account.SObjectType,
          ApplicationConstant.ACCOUNT_APPLICATION_RECORDTYPE
        );
      }
      ApplicationRepository.upsertRecord(application);
      ApexRequest.setApplicationId(application.Id);
    }

    SObjectConstructor constructor = SObjectConstructor.getInstance(
      application
    );
    //save applicants
    if (application.Applicants__r?.size() > 0) {
      List<Applicant__c> applicants = ApplicantService.getInstance()
        .saveApplicants(application.Applicants__r, application.Id);
      constructor.setChildObjects('mflow__Applicants__r', applicants);
    }

    //save financial accounts
    if (application.mflow__FinancialAccounts__r?.size() > 0) {
      List<FinServ__FinancialAccount__c> financialAccounts = saveFinancialAccount(
        application.mflow__FinancialAccounts__r
      );
      constructor.setChildObjects(
        'mflow__FinancialAccounts__r',
        financialAccounts
      );
    }

    //Save survey
    if (application.Surveys__r?.size() > 0) {
      List<Survey__c> surveys = saveSurveys(application.Surveys__r, null);
      constructor.setChildObjects('mflow__Surveys__r', surveys);
    }

    application = (Account) constructor.build();

    return application;
  }

  /**
   * @description Save applicants
   * @author Digital Align Team | 10-25-2021
   * @param String applicationId
   * @param List<Applicant__c> applicants
   * @return virtual
   **/
  global virtual List<Applicant__c> saveApplicants(
    List<Applicant__c> applicants,
    String applicationId
  ) {
    log?.fine('Inside save applicants');
    if (CollectionUtils.isListEmpty(applicants)) {
      return applicants;
    }

    if (ApexRequest.getParams().containsKey('ApexSkipApplicants')) {
      return applicants;
    }
    //update value for applicant here
    for (Applicant__c applicant : applicants) {
      applicant = saveApplicant(applicant, applicationId);
    }
    ApplicantRepository.upsertRecords(applicants);

    if (ApexRequest.getParams().containsKey('ApexSkipApplicantsChild')) {
      return applicants;
    }
    //save child of applicants
    for (Applicant__c applicant : applicants) {
      applicant = saveApplicantChild(applicant);
    }
    log?.fine('Finish save applicants');
    return applicants;
  }

  /**
   * @description
   * @author Digital Align Team | 10-27-2021
   * @param Applicant__c applicant
   * @param String applicationId
   * @return Applicant__c
   **/
  global virtual Applicant__c saveApplicant(
    Applicant__c applicant,
    String applicationId
  ) {
    if (String.isNotBlank(applicationId)) {
      //Set Application ID
      applicant.Application__c = applicationId;
    }

    //Set Applicant Record Type
    String recordTypeName = this.obtainApplicantRecordTypeName(applicant);
    applicant.RecordTypeId = SObjectUtils.recordTypeIdByName(
      Applicant__c.SObjectType,
      recordTypeName
    );
    // Full Name
    applicant.Name = String.isBlank(applicant.FirstName__c)
      ? applicant.LastName__c
      : applicant.FirstName__c + ' ' + applicant.LastName__c;

    //Initially set joint flow state
    if (String.isBlank(applicant.Id)) {
      if (recordTypeName == ApplicationConstant.APPLICANT_JOINT_RECORDTYPE) {
        applicant.FlowState__c = ApplicationConstant.JOINT_WELCOME;
        applicant.Status__c = ApplicationConstant.DRAFT;
      } else if (
        recordTypeName == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
      ) {
        applicant.Status__c = ApplicationConstant.IN_PROGRESS;
      }
    }

    return applicant;
  }

  /**
   * @description Obtain applicant record Type Name
   * @author Digital Align Team | 12-21-2021
   * @param Applicant__c applicant
   * @return String
   **/
  private String obtainApplicantRecordTypeName(Applicant__c applicant) {
    String recordTypeName;
    if (String.isBlank(applicant.ApplicantType__c)) {
      recordTypeName = ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE;
      applicant.ApplicantType__c = ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE;
    } else {
      switch on applicant.ApplicantType__c {
        when 'Primary',
          'Joint',
          'Beneficiary',
          'Family Member',
          'Emergency Contact' {
          recordTypeName = applicant.ApplicantType__c;
        }
        when else {
          Set<String> applicantTypes = new Set<String>(
            applicant.ApplicantType__c.split(';')
          );
          recordTypeName = applicantTypes.contains('Joint')
            ? 'Joint'
            : (applicantTypes.contains('Beneficiary')
                ? 'Beneficiary'
                : (applicantTypes.contains('Emergency Contact')
                    ? 'Emergency Contact'
                    : recordTypeName));
        }
      }
    }
    log?.debug('recordTypeName : ' + recordTypeName);
    return recordTypeName;
  }

  /**
   * @description
   * @author Digital Align Team | 10-26-2021
   * @param Applicant__c applicant
   * @return Applicant__c
   **/
  global virtual Applicant__c saveApplicantChild(Applicant__c applicant) {
    //Do upsert in one short
    //List<SObject> listToUpdate = new List<SObject>();

    // upsert Identification document
    if (!CollectionUtils.isListEmpty(applicant?.IdentificationDocuments__r)) {
      saveIdentificationDocuments(
        applicant?.IdentificationDocuments__r,
        applicant.Id
      );
    }

    // upsert contact point address
    if (!CollectionUtils.isListEmpty(applicant?.ContactPointAddresses__r)) {
      saveContactPointAddresses(
        applicant?.ContactPointAddresses__r,
        applicant.Id
      );
    }

    // upsert employment
    if (!CollectionUtils.isListEmpty(applicant?.Employments__r)) {
      this.saveEmployments(applicant?.Employments__r, applicant.Id);
    }

    if (!CollectionUtils.isListEmpty(applicant?.Surveys__r)) {
      this.saveSurveys(applicant?.Surveys__r, applicant.Id);
    }

    // upsert Asset And Liabilities
    // Not in this phase
    /*
    if (!CollectionUtils.isListEmpty(applicant?.AssetsAndLiabilities__r)) {
      saveAssetsAndLiabilities(
        applicant?.AssetsAndLiabilities__r,
        applicant.Id
      );
    }*/

    // upsert revenues
    // Not in this phase
    /*
    if (!CollectionUtils.isListEmpty(applicant?.Revenues__r)) {
      saveRevenues(applicant?.Revenues__r, applicant.Id);
    }*/
    return applicant;
  }

  /**
   * @description Save Identification Documents
   * @author Digital Align Team | 11-09-2021
   * @param List<FinServ__IdentificationDocument__c> identityDocuments
   * @param Id applicantId
   * @return List<FinServ__IdentificationDocument__c>
   **/
  global virtual List<FinServ__IdentificationDocument__c> saveIdentificationDocuments(
    List<FinServ__IdentificationDocument__c> identityDocuments,
    Id applicantId
  ) {
    for (FinServ__IdentificationDocument__c identityDoc : identityDocuments) {
      if (String.isNotBlank(applicantId)) {
        identityDoc.Applicant__c = applicantId;
      }
    }
    ApplicantRepository.upsertRecords(identityDocuments);
    return identityDocuments;
  }

  /**
   * @description save Contact Point Addresses
   * @author Digital Align Team | 11-09-2021
   * @param List<ContactPointAddress> addresses
   * @param Id applicantId
   * @return List<ContactPointAddress>
   **/
  global virtual List<ContactPointAddress> saveContactPointAddresses(
    List<ContactPointAddress> addresses,
    Id applicantId
  ) {
    for (ContactPointAddress cpa : addresses) {
      if (String.isNotBlank(applicantId)) {
        cpa.Applicant__c = applicantId;
      }
      cpa.Name = String.isNotBlank(cpa.Street) ? cpa.Street?.left(255) : 'N/A';
    }
    ApplicantRepository.upsertRecords(addresses);
    return addresses;
  }

  /**
   * @description Save employment detail of applicant
   * @author Digital Align Team | 11-09-2021
   * @param List<FinServ__Employment__c> employments
   * @param Id applicantId
   * @return List<FinServ__Employment__c>
   **/
  global virtual List<FinServ__Employment__c> saveEmployments(
    List<FinServ__Employment__c> employments,
    Id applicantId
  ) {
    for (FinServ__Employment__c employment : employments) {
      if (String.isNotBlank(applicantId)) {
        employment.Applicant__c = applicantId;
      }
    }
    ApplicantRepository.upsertRecords(employments);
    return employments;
  }

  /**
   * @description Save Survey detail of applicant
   * @author Digital Align Team | 11-09-2021
   * @param List<FinServ__Employment__c> employments
   * @param Id applicantId
   * @return List<FinServ__Employment__c>
   **/
  global virtual List<Survey__c> saveSurveys(
    List<Survey__c> surveys,
    Id applicantId
  ) {
    for (Survey__c survey : surveys) {
      if (String.isNotBlank(applicantId)) {
        survey.Applicant__c = applicantId;
      }
      survey.Application__c = ApexRequest.getApplicationId();
    }
    ApplicantRepository.upsertRecords(surveys);
    return surveys;
  }

  /**
   * @description  Save Assets And Liabilities
   * @author Digital Align Team | 11-09-2021
   * @param List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilities
   * @param Id applicantId
   * @return List<FinServ__AssetsAndLiabilities__c>
   **/
  /*
  global virtual List<FinServ__AssetsAndLiabilities__c> saveAssetsAndLiabilities(
    List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilities,
    Id applicantId
  ) {
    for (
      FinServ__AssetsAndLiabilities__c assetAndLiability : assetsAndLiabilities
    ) {
      if (String.isNotBlank(applicantId)) {
        assetAndLiability.Applicant__c = applicantId;
      }
    }
    ApplicantRepository.upsertRecords(assetsAndLiabilities);
    return assetsAndLiabilities;
  } */

  /**
   * @description Save Revenues
   * @author Digital Align Team | 11-09-2021
   * @param List<FinServ__Revenue__c> revenues
   * @param Id applicantId
   * @return List<FinServ__Revenue__c>
   **/
  /*
  global virtual List<FinServ__Revenue__c> saveRevenues(
    List<FinServ__Revenue__c> revenues,
    Id applicantId
  ) {
    for (FinServ__Revenue__c revenue : revenues) {
      if (String.isNotBlank(applicantId)) {
        revenue.Applicant__c = applicantId;
      }
      if (String.isBlank(revenue.FinServ__Account__c)) {
        revenue.FinServ__Account__c = ApexRequest.getApplicationId();
      }
    }
    ApplicantRepository.upsertRecords(revenues);
    return revenues;
  }
  */

  /**
   * @description  delete object by Id
   * @author Digital Align Team | 11-10-2021
   * @param Id recordId
   * @return Boolean
   **/
  global virtual Boolean deleteEntity(Id recordId) {
    log?.fine('Inside Delete Record');
    switch on SObjectUtils.getObjectName(recordId) {
      when 'Account' {
        List<SObject> recordsToDelete = new List<SObject>();
        Account application = ApplicationRepository.readApplicationWithChild(
          recordId
        );
        if (!application.Applicants__r.isEmpty()) {
          this.deleteApplicants(
            new Map<Id, SObject>(application.Applicants__r).keySet()
          );
        }
        if (!application.mflow__FinancialAccounts__r.isEmpty()) {
          recordsToDelete.addAll(application.mflow__FinancialAccounts__r);
        }
        recordsToDelete.add(application);
        ApplicationRepository.deleteRecords(recordsToDelete);
      }
      when 'FinServ__FinancialAccount__c' {
        ApplicationRepository.deleteRecord(recordId, true);
      }
      when 'mflow__Applicant__c' {
        this.deleteApplicants(new Set<Id>{ recordId });
      }
      when 'FinServ__IdentificationDocument__c' {
        FileService.getInstance().deleteContentVersionByEntityId(recordId);
        ApplicationRepository.deleteRecord(recordId, true);
      }
      when 'FinServ__Employment__c' {
        ApplicationRepository.deleteRecord(recordId, true);
      }
      when 'ContactPointAddress' {
        ApplicationRepository.deleteRecord(recordId, true);
      }
      when 'FinServ__AssetsAndLiabilities__c' {
        ApplicationRepository.deleteRecord(recordId, true);
      }
      when 'FinServ__Revenue__c' {
        ApplicationRepository.deleteRecord(recordId, true);
      }
    }
    log?.fine('Complete Delete Record');
    return true;
  }

  /**
   * @description list of applicantIds to delete
   * @author Digital Align Team | 10-28-2021
   * @param Set<Id> applicantIds
   * @return Boolean
   **/
  global virtual Boolean deleteApplicants(Set<Id> applicantIds) {
    List<SObject> recordsToDelete = new List<SObject>();
    for (
      Applicant__c applicant : ApplicantRepository.readApplicantsWithChild(
        applicantIds
      )
    ) {
      if (!applicant.IdentificationDocuments__r.isEmpty()) {
        recordsToDelete.addAll(applicant.IdentificationDocuments__r);
      }
      if (!applicant.ContactPointAddresses__r.isEmpty()) {
        recordsToDelete.addAll(applicant.ContactPointAddresses__r);
      }
      if (!applicant.Employments__r.isEmpty()) {
        recordsToDelete.addAll(applicant.Employments__r);
      }
      if (!applicant.AssetsAndLiabilities__r.isEmpty()) {
        recordsToDelete.addAll(applicant.AssetsAndLiabilities__r);
      }
      if (!applicant.Revenues__r.isEmpty()) {
        recordsToDelete.addAll(applicant.Revenues__r);
      }
      recordsToDelete.add(applicant);
    }
    ApplicationRepository.deleteRecords(recordsToDelete);
    return true;
  }

  /**
   * @description Save financial account and children
   * @author Digital Align Team | 10-25-2021
   * @param List<FinServ__FinancialAccount__c> financialAccounts
   * @return List<FinServ__FinancialAccount__c>
   **/
  global virtual List<FinServ__FinancialAccount__c> saveFinancialAccount(
    List<FinServ__FinancialAccount__c> financialAccounts
  ) {
    if (financialAccounts?.size() > 0) {
      FinancialAccountRepository.upsertRecords(financialAccounts);
    }
    return financialAccounts;
  }
}
