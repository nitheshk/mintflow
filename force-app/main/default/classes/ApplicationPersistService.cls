/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
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
    ApplicationRepository.upsertRecord(application);

    dau01.SObjectConstructor constructor = dau01.SObjectConstructor.getInstance(
      application
    );
    //save applicants
    if (application.Applicants__r?.size() > 0) {
      List<dau01__Applicant__c> applicants = saveApplicants(
        application.Id,
        application.Applicants__r
      );
      constructor.setChildObjects('dau01__Applicants__r', applicants);
    }

    //save financial accounts
    if (application.FinServ__HouseholdFinancialAccounts__r?.size() > 0) {
      List<FinServ__FinancialAccount__c> financialAccounts = saveFinancialAccount(
        application.FinServ__HouseholdFinancialAccounts__r
      );
      constructor.setChildObjects(
        'FinServ__HouseholdFinancialAccounts__r',
        financialAccounts
      );
    }
    application = (Account) constructor.build();

    return application;
  }

  /**
   * @description Save applicants
   * @author Digital Align Team | 10-25-2021
   * @param String applicationId
   * @param List<dau01__Applicant__c> applicants
   * @return virtual
   **/
  global virtual List<dau01__Applicant__c> saveApplicants(
    String applicationId,
    List<dau01__Applicant__c> applicants
  ) {
    log?.fine('Inside save applicants');

    if (CollectionUtils.isListEmpty(applicants)) {
      return applicants;
    }

    //update value for applicant here
    for (Applicant__c applicant : applicants) {
      saveApplicant(applicationId, applicant);
    }
    ApplicantRepository.upsertRecords(applicants);

    for (Applicant__c applicant : applicants) {
      applicant = saveApplicantChild(applicant);
    }

    log?.fine('Finish save applicants');
    return applicants;
  }

  /**
   * @description
   * @author Digital Align Team | 10-27-2021
   * @param String applicationId
   * @param Applicant__c applicant
   * @return Applicant__c
   **/
  global virtual Applicant__c saveApplicant(
    String applicationId,
    Applicant__c applicant
  ) {
    if (String.isBlank(applicant.Id)) {
      /*  new applicant */
      //set record type
      applicant.dau01__Application__c = applicationId;
    }

    if (String.isBlank(applicant.ApplicantType__c)) {
      applicant.recordTypeId = Sobjectutils.recordTypeIdByName(
        Applicant__c.SObjectType,
        'Primary'
      );
    } else {
      applicant.recordTypeId = Sobjectutils.recordTypeIdByName(
        Applicant__c.SObjectType,
        applicant.ApplicantType__c
      );
    }

    applicant.Name = String.isBlank(applicant.FirstName__c)
      ? applicant.LastName__c
      : applicant.FirstName__c + ' ' + applicant.LastName__c;

    return applicant;
  }

  /**
   * @description
   * @author Digital Align Team | 10-26-2021
   * @param Applicant__c applicant
   * @return Applicant__c
   **/
  global virtual Applicant__c saveApplicantChild(Applicant__c applicant) {
    //Do upsert in one short
    List<SObject> listToUpdate = new List<SObject>();

    // upsert Identitifcation document
    if (!CollectionUtils.isListEmpty(applicant?.IdentificationDocuments__r)) {
      saveIdentificationDocuments(
        applicant,
        applicant?.IdentificationDocuments__r
      );
    }

    // upsert contact point address
    if (!CollectionUtils.isListEmpty(applicant?.ContactPointAddresses__r)) {
      saveContactPointAddresses(applicant, applicant?.ContactPointAddresses__r);
    }

    // upsert employement
    if (!CollectionUtils.isListEmpty(applicant?.Employments__r)) {
      saveEmployments(applicant, applicant?.Employments__r);
    }

    // upsert Asset And Liabilities
    if (!CollectionUtils.isListEmpty(applicant?.AssetsAndLiabilities__r)) {
      saveAssetsAndLiabilities(applicant, applicant?.AssetsAndLiabilities__r);
    }

    // upsert revenues
    if (!CollectionUtils.isListEmpty(applicant?.Revenues__r)) {
      saveRevenues(applicant, applicant?.Revenues__r);
    }

    return applicant;
  }

  /**
   * @description
   * @author Digital Align Team | 10-27-2021
   * @param Applicant__c applicant
   * @param List<FinServ__IdentificationDocument__c> identityDocuments
   * @return  List<FinServ__IdentificationDocument__c>
   **/
  global virtual List<FinServ__IdentificationDocument__c> saveIdentificationDocuments(
    Applicant__c applicant,
    List<FinServ__IdentificationDocument__c> identityDocuments
  ) {
    for (FinServ__IdentificationDocument__c identityDoc : identityDocuments) {
      if (String.isBlank(identityDoc.id)) {
        identityDoc.Applicant__c = applicant.Id;
      }
    }
    ApplicantRepository.upsertRecords(identityDocuments);
    return identityDocuments;
  }

  /**
   * @description
   * @author Digital Align Team | 10-27-2021
   * @param Applicant__c applicant
   * @param List<ContactPointAddress> addresses
   * @return List<ContactPointAddress>
   **/
  global virtual List<ContactPointAddress> saveContactPointAddresses(
    Applicant__c applicant,
    List<ContactPointAddress> addresses
  ) {
    for (ContactPointAddress cpa : addresses) {
      if (String.isBlank(cpa.id)) {
        cpa.Applicant__c = applicant.Id;
      }
    }
    ApplicantRepository.upsertRecords(addresses);
    return addresses;
  }

  /**
   * @description
   * @author Digital Align Team | 10-27-2021
   * @param Applicant__c applicant
   * @param List<FinServ__Employment__c> employments
   * @return List<FinServ__Employment__c>
   **/
  global virtual List<FinServ__Employment__c> saveEmployments(
    Applicant__c applicant,
    List<FinServ__Employment__c> employments
  ) {
    for (FinServ__Employment__c employment : employments) {
      if (String.isBlank(employment.id)) {
        employment.Applicant__c = applicant.Id;
      }
    }
    ApplicantRepository.upsertRecords(employments);
    return employments;
  }

  /**
   * @description
   * @author Digital Align Team | 10-27-2021
   * @param Applicant__c applicant
   * @param List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilities
   * @return List<FinServ__AssetsAndLiabilities__c>
   **/
  global virtual List<FinServ__AssetsAndLiabilities__c> saveAssetsAndLiabilities(
    Applicant__c applicant,
    List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilities
  ) {
    for (
      FinServ__AssetsAndLiabilities__c assetAndLiability : assetsAndLiabilities
    ) {
      if (String.isBlank(assetAndLiability.id)) {
        assetAndLiability.Applicant__c = applicant.Id;
      }
    }
    ApplicantRepository.upsertRecords(assetsAndLiabilities);
    return assetsAndLiabilities;
  }

  /**
   * @description
   * @author Digital Align Team | 10-27-2021
   * @param Applicant__c applicant
   * @param List<FinServ__Revenue__c> revenues
   * @return List<FinServ__Revenue__c>
   **/
  global virtual List<FinServ__Revenue__c> saveRevenues(
    Applicant__c applicant,
    List<FinServ__Revenue__c> revenues
  ) {
    for (FinServ__Revenue__c revenue : revenues) {
      if (String.isBlank(revenue.id)) {
        revenue.Applicant__c = applicant.Id;
      }
    }
    ApplicantRepository.upsertRecords(revenues);
    return revenues;
  }

  /**
   * @description
   * @author Digital Align Team | 10-25-2021
   * @param List<dau01__Applicant__c> applicants
   * @return Boolean
   **/
  global virtual Boolean deleteApplicants(List<Applicant__c> applicants) {
    if (!applicants.isEmpty()) {
      ApplicantRepository.deleteRecords(applicants);
      // need to delete child records
    }
    return true;
  }

  /**
   * @description Save financial account and childs
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
