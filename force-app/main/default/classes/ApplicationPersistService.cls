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
    if (!CollectionUtils.isListEmpty(application.Applicants__r)) {
      List<Applicant__c> applicants = ApplicantService.getInstance()
        .saveApplicants(application.Applicants__r, application.Id);
      constructor.setChildObjects('mflow__Applicants__r', applicants);
    }

    //save financial accounts
    if (!CollectionUtils.isListEmpty(application.mflow__FinancialAccounts__r)) {
      List<FinServ__FinancialAccount__c> financialAccounts = saveFinancialAccounts(
        application.mflow__FinancialAccounts__r,
        application.Id
      );
      constructor.setChildObjects(
        'mflow__FinancialAccounts__r',
        financialAccounts
      );
    }

    //Save survey
    if (!CollectionUtils.isListEmpty(application.Surveys__r)) {
      List<Survey__c> surveys = saveSurveys(application.Surveys__r, null);
      constructor.setChildObjects('mflow__Surveys__r', surveys);
    }

    //Save Disclosure
    if (!CollectionUtils.isListEmpty(application.ApplicationConsents__r)) {
      List<Consent__c> consents = saveConsents(
        application.ApplicationConsents__r,
        null
      );
      constructor.setChildObjects('mflow__ApplicationConsents__r', consents);
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

    // if (ApexRequest.getParams().containsKey('ApexSkipApplicants')) {
    //   return applicants;
    // }
    //update value for applicant here
    for (Applicant__c applicant : applicants) {
      applicant = saveApplicant(applicant, applicationId);
    }
    ApplicantRepository.upsertRecords(applicants);

    // if (ApexRequest.getParams().containsKey('ApexSkipApplicantsChild')) {
    //   return applicants;
    // }
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

    if (String.isNotBlank(ApexRequest.getFlowType())) {
      applicant.FlowType__c = ApexRequest.getFlowType();
    }

    //Set Applicant Record Type
    String recordTypeName = this.obtainApplicantRecordTypeName(applicant);
    applicant.RecordTypeId = SObjectUtils.recordTypeIdByName(
      Applicant__c.SObjectType,
      recordTypeName
    );
    // Full Name
    applicant.ApplicantName__c = String.isBlank(applicant.FirstName__c)
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

    // When Save Applicant called from UI, THat stand for Application is progress
    // To make sure after Saved Application, if they process further , status if application need to changed to in progress
    // if (String.isNotBlank(ApexRequest.getToken())) {
    //   applicant.Status__c = ApplicationConstant.IN_PROGRESS;
    // }

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

    //Save Disclosure
    if (!CollectionUtils.isListEmpty(applicant?.ApplicantConsents__r)) {
      this.saveConsents(applicant.ApplicantConsents__r, applicant.Id);
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
      } // updating state = state full name in trigger(before insert before update)
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
   * @description Save consent details
   * @author Digital Align Team | 12-27-2021
   * @param List<Consent__c> consents
   * @param Id applicantId
   * @return List<Consent__c>
   **/
  global virtual List<Consent__c> saveConsents(
    List<Consent__c> consents,
    Id applicantId
  ) {
    for (Consent__c consent : consents) {
      if (String.isNotBlank(applicantId)) {
        consent.Applicant__c = applicantId;
      }
      consent.Application__c = ApexRequest.getApplicationId();
    }
    ConsentRepository.upsertRecords(consents);
    return consents;
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
   * @description  Save Financial Accounts
   * @author Digital Align Team | 01-10-2022
   * @param List<FinServ__FinancialAccount__c> financialAccounts
   * @param String applicationId
   * @return List<FinServ__FinancialAccount__c>
   **/
  global virtual List<FinServ__FinancialAccount__c> saveFinancialAccounts(
    List<FinServ__FinancialAccount__c> financialAccounts,
    String applicationId
  ) {
    log?.fine('Inside save financialAccounts');
    if (CollectionUtils.isListEmpty(financialAccounts)) {
      return financialAccounts;
    }

    //update value for financialAccount here
    for (FinServ__FinancialAccount__c financialAccount : financialAccounts) {
      financialAccount = this.saveFinancialAccount(
        financialAccount,
        applicationId
      );
    }
    FinancialAccountRepository.upsertRecords(financialAccounts);

    //save child of FinancialAccounts
    for (FinServ__FinancialAccount__c financialAccount : financialAccounts) {
      financialAccount = this.saveFinancialAccountChild(financialAccount);
    }
    log?.fine('Finish save FinancialAccounts');
    return financialAccounts;
  }

  /**
   * @description  save financial account
   * @author Digital Align Team | 01-10-2022
   * @param FinServ__FinancialAccount__c financialAccount
   * @param String applicationId
   * @return FinServ__FinancialAccount__c
   **/
  global virtual FinServ__FinancialAccount__c saveFinancialAccount(
    FinServ__FinancialAccount__c financialAccount,
    String applicationId
  ) {
    if (String.isNotBlank(applicationId)) {
      //Set Application ID
      financialAccount.FinServ__Household__c = applicationId;
      financialAccount.Application__c = applicationId;
    }
    // #pending financialAccount record type mapping pending
    return financialAccount;
  }

  /**
   * @description Save Financial Account Child
   * @author Digital Align Team | 01-10-2022
   * @param FinServ__FinancialAccount__c financialAccount
   * @return FinServ__FinancialAccount__c
   **/
  global virtual FinServ__FinancialAccount__c saveFinancialAccountChild(
    FinServ__FinancialAccount__c financialAccount
  ) {
    if (
      !collectionUtils.isListEmpty(
        financialAccount?.FinServ__FinancialAccountTranslations__r
      )
    ) {
      this.saveFinancialAccountTransactions(
        financialAccount.FinServ__FinancialAccountTranslations__r,
        financialAccount.Id
      );
    }
    return financialAccount;
  }

  /**
   * @description save financial transaction history
   * @author Digital Align Team | 01-10-2022
   * @param List<FinServ__FinancialAccountTransaction__c> financialAccountTransactions
   * @param Id applicationId
   * @return  List<FinServ__FinancialAccountTransaction__c>
   **/
  global virtual List<FinServ__FinancialAccountTransaction__c> saveFinancialAccountTransactions(
    List<FinServ__FinancialAccountTransaction__c> financialAccountTransactions,
    Id applicationId
  ) {
    for (
      FinServ__FinancialAccountTransaction__c financialAccountTransaction : financialAccountTransactions
    ) {
      if (String.isNotBlank(applicationId)) {
        financialAccountTransaction.FinServ__FinancialAccount__c = applicationId;
      }

      if (
        String.isBlank(
          financialAccountTransaction.FinServ__TransactionStatus__c
        )
      ) {
        financialAccountTransaction.FinServ__TransactionStatus__c = 'Pending';
      }
    }
    ApplicantRepository.upsertRecords(financialAccountTransactions);
    return financialAccountTransactions;
  }
}
