/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier,PMD.CognitiveComplexity')
global virtual with sharing class ApplicationPersistService extends AbstractService {
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
      serviceInstance = (ApplicationPersistService) getInstance(ApplicationPersistService.class);
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align Team | 10-25-2021
   * @param Application__c application
   * @return Application__c
   **/
  global virtual Application__c saveApplication(Application__c application) {
    //Process Application Mapping
    {
      ApplicationRepository.upsertRecord(application);
      ApexRequest.setApplicationId(application.Id);
    }

    SObjectConstructor constructor = SObjectConstructor.getInstance(application);
    //save applicants
    if (!CollectionUtils.isListEmpty(application.Applicants__r)) {
      List<Applicant__c> applicants = ApplicantService.getInstance()
        .saveApplicants(application.Applicants__r, application.Id);
      constructor.setChildObjects('mflow__Applicants__r', applicants);
    }

    //save financial accounts
    if (!CollectionUtils.isListEmpty(application.FinancialAccounts__r)) {
      List<FinancialAccount__c> financialAccounts = saveFinancialAccounts(
        application.FinancialAccounts__r,
        application.Id
      );
      constructor.setChildObjects('mflow__FinancialAccounts__r', financialAccounts);
    }

    //Save survey
    if (!CollectionUtils.isListEmpty(application.Surveys__r)) {
      List<Survey__c> surveys = saveSurveys(application.Surveys__r, null);
      constructor.setChildObjects('mflow__Surveys__r', surveys);
    }

    //Save Disclosure
    if (!CollectionUtils.isListEmpty(application.ApplicationConsents__r)) {
      List<Consent__c> consents = saveConsents(application.ApplicationConsents__r, null);
      constructor.setChildObjects('mflow__ApplicationConsents__r', consents);
    }

    //Save referral products
    if (!CollectionUtils.isListEmpty(application.CustomerInterests__r)) {
      List<CustomerInterest__c> customerInterests = saveCustomerInterest(
        application.CustomerInterests__r,
        application.Id
      );
      constructor.setChildObjects('mflow__CustomerInterests__r', customerInterests);
    }

    application = (Application__c) constructor.build();

    return application;
  }

  /**
   * @description Save applicants
   * @author Digital Align Team | 10-25-2021
   * @param String applicationId
   * @param List<Applicant__c> applicants
   * @return virtual
   **/
  global virtual List<Applicant__c> saveApplicants(List<Applicant__c> applicants, String applicationId) {
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
    ApplicationRepository.upsertRecords(applicants);

    // if (ApexRequest.getParams().containsKey('ApexSkipApplicantsChild')) {
    //   return applicants;
    // }
    //save applicants childs
    applicants = saveApplicantChilds(applicants);

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
  global virtual Applicant__c saveApplicant(Applicant__c applicant, String applicationId) {
    //Set Application ID
    if (String.isNotBlank(applicationId)) {
      applicant.Application__c = applicationId;
    }

    if (String.isNotBlank(ApexRequest.getFlowType())) {
      applicant.FlowType__c = ApexRequest.getFlowType();
    }
    //Set Applicant Record Type
    String recordTypeName = this.obtainApplicantRecordTypeName(applicant);
    applicant.RecordTypeId = SObjectUtils.recordTypeIdByName(Applicant__c.SObjectType, recordTypeName);
    // Full Name
    applicant.ApplicantName__c = String.isBlank(applicant.FirstName__c)
      ? applicant.LastName__c
      : applicant.FirstName__c + ' ' + applicant.LastName__c;

    //Initially set joint flow state
    if (String.isBlank(applicant.Id)) {
      if (recordTypeName == ApplicationConstant.APPLICANT_JOINT_RECORDTYPE) {
        applicant.FlowState__c = ApplicationConstant.PERSONAL_INFO;
        applicant.Status__c = ApplicationConstant.DRAFT;
      } else if (recordTypeName == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
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
        when 'Primary', 'Joint', 'Beneficiary', 'Family Member', 'Emergency Contact' {
          recordTypeName = applicant.ApplicantType__c;
        }
        when else {
          Set<String> applicantTypes = new Set<String>(applicant.ApplicantType__c.split(';'));
          recordTypeName = applicantTypes.contains('Joint')
            ? 'Joint'
            : (applicantTypes.contains('Beneficiary')
                ? 'Beneficiary'
                : (applicantTypes.contains('Emergency Contact') ? 'Emergency Contact' : recordTypeName));
        }
      }
    }
    return recordTypeName;
  }

  /**
   * @description save applicants childs
   * @author Digital Align Team | 10-26-2021
   * @param List<Applicant__c>  applicants
   * @return List<Applicant__c>
   **/
  global virtual List<Applicant__c> saveApplicantChilds(List<Applicant__c> applicants) {
    //Do upsert in one short
    List<SObject> listToUpdate = new List<SObject>();
    for (Applicant__c applicant : applicants) {
      // upsert Identification document
      if (!CollectionUtils.isListEmpty(applicant?.IdentificationDocuments__r)) {
        listToUpdate.addAll(saveIdentificationDocuments(applicant?.IdentificationDocuments__r, applicant.Id));
      }
      // upsert contact point address
      if (!CollectionUtils.isListEmpty(applicant?.ContactPointAddresses__r)) {
        listToUpdate.addAll(saveContactPointAddresses(applicant?.ContactPointAddresses__r, applicant.Id));
      }
      // upsert employment
      if (!CollectionUtils.isListEmpty(applicant?.Employments__r)) {
        listToUpdate.addAll(this.saveEmployments(applicant?.Employments__r, applicant.Id));
      }
      // upsert Surveys
      if (!CollectionUtils.isListEmpty(applicant?.Surveys__r)) {
        listToUpdate.addAll(this.saveSurveys(applicant?.Surveys__r, applicant.Id));
      }
      //Save Disclosure
      if (!CollectionUtils.isListEmpty(applicant?.ApplicantConsents__r)) {
        listToUpdate.addAll(this.saveConsents(applicant.ApplicantConsents__r, applicant.Id));
      }
      // upsert AssetAndLiabilities
      if (!CollectionUtils.isListEmpty(applicant?.AssetAndLiabilities__r)) {
        this.saveAssetAndLiabilities(applicant.AssetAndLiabilities__r, applicant.Id);
      }
    }
    ApplicationRepository.upsertRecords(listToUpdate);
    return applicants;
  }

  /**
   * @description Save Identification Documents
   * @author Digital Align Team | 11-09-2021
   * @param List<IdentificationDocument__c> identityDocuments
   * @param Id applicantId
   * @return List<IdentificationDocument__c>
   **/
  global virtual List<IdentificationDocument__c> saveIdentificationDocuments(
    List<IdentificationDocument__c> identityDocuments,
    Id applicantId
  ) {
    for (IdentificationDocument__c identityDoc : identityDocuments) {
      if (String.isNotBlank(applicantId)) {
        identityDoc.Applicant__c = applicantId;
      }
    }
    // ApplicationRepository.upsertRecords(identityDocuments);
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
    //ApplicationRepository.upsertRecords(addresses);
    return addresses;
  }

  /**
   * @description Save employment detail of applicant
   * @author Digital Align Team | 11-09-2021
   * @param List<Employment__c> employments
   * @param Id applicantId
   * @return List<Employment__c>
   **/
  global virtual List<Employment__c> saveEmployments(List<Employment__c> employments, Id applicantId) {
    for (Employment__c employment : employments) {
      if (String.isNotBlank(applicantId)) {
        employment.Applicant__c = applicantId;
      }
    }
    //ApplicationRepository.upsertRecords(employments);
    return employments;
  }

  /**
   * @description Save Survey detail of applicant
   * @author Digital Align Team | 11-09-2021
   * @param List<Employment__c> employments
   * @param Id applicantId
   * @return List<Employment__c>
   **/
  global virtual List<Survey__c> saveSurveys(List<Survey__c> surveys, Id applicantId) {
    for (Survey__c survey : surveys) {
      if (String.isNotBlank(applicantId)) {
        survey.Applicant__c = applicantId;
      }
      survey.Application__c = ApexRequest.getApplicationId();
    }
    //ApplicationRepository.upsertRecords(surveys);
    return surveys;
  }

  /**
   * @description Save consent details
   * @author Digital Align Team | 12-27-2021
   * @param List<Consent__c> consents
   * @param Id applicantId
   * @return List<Consent__c>
   **/
  global virtual List<Consent__c> saveConsents(List<Consent__c> consents, Id applicantId) {
    for (Consent__c consent : consents) {
      if (String.isNotBlank(applicantId)) {
        consent.Applicant__c = applicantId;
      }
      consent.Application__c = ApexRequest.getApplicationId();
    }
    //ApplicationRepository.upsertRecords(consents);
    return consents;
  }

  /**
   * @description
   * @author Digital Align Team | 07-25-2022
   * @param List<AssetAndLiability__c> consents
   * @param Id applicantId
   * @return List<AssetAndLiability__c>
   **/
  global virtual List<AssetAndLiability__c> saveAssetAndLiabilities(
    List<AssetAndLiability__c> assetAndLiabilities,
    Id applicantId
  ) {
    //properties
    List<Property__c> properties = new List<Property__c>();
    for (AssetAndLiability__c assetAndLiability : assetAndLiabilities) {
      if (assetAndLiability?.Property__r != null) {
        properties.add(assetAndLiability.Property__r);
      }
    }
    ApplicationRepository.upsertRecords(properties);

    //Asset and liabilities
    for (AssetAndLiability__c assetAndLiability : assetAndLiabilities) {
      if (String.isNotBlank(applicantId)) {
        AssetAndLiability.Applicant__c = applicantId;
      }
      if (assetAndLiability?.Property__r != null) {
        assetAndLiability.Property__c = assetAndLiability?.Property__r.Id;
      }
    }
    ApplicationRepository.upsertRecords(assetAndLiabilities);

    //liabilities and  property belongs to asset
    List<AssetAndLiability__c> liabilities = new List<AssetAndLiability__c>();
    for (AssetAndLiability__c assetAndLiability : assetAndLiabilities) {
      if (!CollectionUtils.isListEmpty(assetAndLiability?.Liabilities__r)) {
        for (AssetAndLiability__c liability : assetAndLiability.Liabilities__r) {
          liability.Asset__c = assetAndLiability.Id;
          liabilities.add(liability);
        }
      }
    }
    ApplicationRepository.upsertRecords(liabilities);

    return assetAndLiabilities;
  }
  /**
   * @description  delete object by Id
   * @author Digital Align Team | 11-10-2021
   * @param Id recordId
   * @return Boolean
   **/
  global virtual Boolean deleteEntity(Id recordId) {
    log?.fine('Inside Delete Record');
    switch on SObjectUtils.getObjectName(recordId) {
      when 'mflow__Application__c' {
        List<SObject> recordsToDelete = new List<SObject>();
        Application__c application = ApplicationRepository.readApplicationWithChild(recordId);
        if (!application.Applicants__r.isEmpty()) {
          this.deleteApplicants(new Map<Id, SObject>(application.Applicants__r).keySet());
        }
        if (!application.FinancialAccounts__r.isEmpty()) {
          recordsToDelete.addAll(application.FinancialAccounts__r);
        }
        recordsToDelete.add(application);
        ApplicationRepository.deleteRecords(recordsToDelete);
      }
      when 'mflow__FinancialAccount__c' {
        ApplicationRepository.deleteRecord(recordId, true);
      }
      when 'mflow__Applicant__c' {
        this.deleteApplicants(new Set<Id>{ recordId });
      }
      when 'IdentificationDocument__c' {
        FileService.getInstance().deleteContentVersionByEntityId(recordId);
        ApplicationRepository.deleteRecord(recordId, true);
      }
      when 'mflow__Employment__c' {
        ApplicationRepository.deleteRecord(recordId, true);
      }
      when 'ContactPointAddress' {
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
    for (Applicant__c applicant : ApplicantRepository.readApplicantsWithChild(applicantIds)) {
      if (!applicant.IdentificationDocuments__r.isEmpty()) {
        recordsToDelete.addAll(applicant.IdentificationDocuments__r);
      }
      if (!applicant.ContactPointAddresses__r.isEmpty()) {
        recordsToDelete.addAll(applicant.ContactPointAddresses__r);
      }
      if (!applicant.Employments__r.isEmpty()) {
        recordsToDelete.addAll(applicant.Employments__r);
      }
      recordsToDelete.add(applicant);
    }
    ApplicationRepository.deleteRecords(recordsToDelete);
    return true;
  }

  /**
   * @description  Save Financial Accounts
   * @author Digital Align Team | 01-10-2022
   * @param List<FinancialAccount__c> financialAccounts
   * @param String applicationId
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> saveFinancialAccounts(
    List<FinancialAccount__c> financialAccounts,
    String applicationId
  ) {
    log?.fine('Inside save financialAccounts');
    if (CollectionUtils.isListEmpty(financialAccounts)) {
      return financialAccounts;
    }

    //update value for financialAccount here
    for (FinancialAccount__c financialAccount : financialAccounts) {
      if (String.isNotBlank(applicationId)) {
        //Set Application ID
        financialAccount.Application__c = applicationId;
      }
    }
    FinancialAccountRepository.upsertRecords(financialAccounts);

    //save child of FinancialAccounts
    financialAccounts = this.saveFinancialAccountChilds(financialAccounts);

    log?.fine('Finish save FinancialAccounts');
    return financialAccounts;
  }

  /**
   * @description Save Financial Account Children
   * @author Digital Align Team | 07-26-2022
   * @param List<FinancialAccount__c> financialAccounts
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> saveFinancialAccountChilds(List<FinancialAccount__c> financialAccounts) {
    List<SObject> listToUpdate = new List<SObject>();
    Set<Property__c> propertywithLiabilities = new Set<Property__c>();

    for (FinancialAccount__c financialAccount : financialAccounts) {
      // save financial transaction history
      if (!collectionUtils.isListEmpty(financialAccount?.FinancialAccountTransactions__r)) {
        List<FinancialAccountTransaction__c> financialAccountTransactions = new List<FinancialAccountTransaction__c>();
        for (
          FinancialAccountTransaction__c financialAccountTransaction : financialAccount.FinancialAccountTransactions__r
        ) {
          financialAccountTransaction.FinancialAccount__c = financialAccount.Id;
          if (String.isBlank(financialAccountTransaction.TransactionStatus__c)) {
            financialAccountTransaction.TransactionStatus__c = 'Pending';
          }
          financialAccountTransactions.add(financialAccountTransaction);
        }
        //ApplicationRepository.upsertRecords(financialAccountTransactions);
        listToUpdate.addAll(financialAccountTransactions);
      }

      // Save ProductServices
      if (!collectionUtils.isListEmpty(financialAccount?.FinancialAccountServices__r)) {
        List<FinancialAccountService__c> financialAccountServices = new List<FinancialAccountService__c>();
        for (FinancialAccountService__c financialAccountService : financialAccount.FinancialAccountServices__r) {
          financialAccountService.FinancialAccount__c = financialAccount.Id;
          financialAccountServices.add(financialAccountService);
        }
        //ApplicationRepository.upsertRecords(financialAccountServices);
        listToUpdate.addAll(financialAccountServices);
      }

      // Save properties
      if (!collectionUtils.isListEmpty(financialAccount?.Properties__r)) {
        List<Property__c> properties = new List<Property__c>();
        for (Property__c property : financialAccount.Properties__r) {
          property.FinancialAccount__c = financialAccount.Id;
          properties.add(property);

          //property has liablities associated
          if (!collectionUtils.isListEmpty(property?.AssetAndLiabilities__r)) {
            propertywithLiabilities.add(property);
          }
        }
        //ApplicationRepository.upsertRecords(properties);
        listToUpdate.addAll(properties);
      }
    }
    ApplicationRepository.upsertRecords(listToUpdate);

    // Save Property liability
    listToUpdate = new List<SObject>();
    for (Property__c property : propertywithLiabilities) {
      for (AssetAndLiability__c liability : property?.AssetAndLiabilities__r) {
        liability.Property__c = property.Id;
        listToUpdate.add(liability);
      }
    }
    ApplicationRepository.upsertRecords(listToUpdate);
    return financialAccounts;
  }

  /**
   * @description Save Customer Interest
   * @author Digital Align Team | 04-03-2022
   * @param List<CustomerInterest__c> customerInterests
   * @param Id applicantId
   * @return List<CustomerInterest__c>
   **/
  global virtual List<CustomerInterest__c> saveCustomerInterest(
    List<CustomerInterest__c> customerInterests,
    Id applicationId
  ) {
    for (CustomerInterest__c customerInterest : customerInterests) {
      if (String.isNotBlank(applicationId) && String.isBlank(customerInterest.Application__c)) {
        customerInterest.Application__c = applicationId;
      }
    }
    ApplicationRepository.upsertRecords(customerInterests);
    return customerInterests;
  }
}
