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
      if (String.isNotBlank(applicant.Id)) {
        // existing applicant
        log?.fine('Existing applicant');
      } else {
        //new applicant
        //set record type
        applicant.dau01__Application__c = applicationId;
      }
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
   * @author Digital Align Team | 10-26-2021
   * @param Applicant__c applicant
   * @return Applicant__c
   **/
  global virtual Applicant__c saveApplicantChild(Applicant__c applicant) {
    //Do upsert in one short
    List<SObject> listToUpdate = new List<SObject>();

    // upsert contact point address
    if (!CollectionUtils.isListEmpty(applicant?.ContactPointAddresses__r)) {
      for (ContactPointAddress cpa : applicant.ContactPointAddresses__r) {
        if (String.isBlank(cpa.id)) {
          cpa.Applicant__c = applicant.Id;
        }
      }
      ApplicantRepository.upsertRecords(applicant.ContactPointAddresses__r);
    }

    // upsert Identitifcation document
    if (!CollectionUtils.isListEmpty(applicant?.IdentificationDocuments__r)) {
      for (
        FinServ__IdentificationDocument__c identityDoc : applicant.IdentificationDocuments__r
      ) {
        if (String.isBlank(identityDoc.id)) {
          identityDoc.Applicant__c = applicant.Id;
        }
      }
      ApplicantRepository.upsertRecords(applicant.IdentificationDocuments__r);
    }

    // upsert employement
    if (!CollectionUtils.isListEmpty(applicant?.Employments__r)) {
      for (FinServ__Employment__c employment : applicant.Employments__r) {
        if (String.isBlank(employment.id)) {
          employment.Applicant__c = applicant.Id;
        }
      }
      ApplicantRepository.upsertRecords(applicant.Employments__r);
    }

    // upsert Asset And Liabilities
    if (!CollectionUtils.isListEmpty(applicant?.AssetsAndLiabilities__r)) {
      for (
        FinServ__AssetsAndLiabilities__c assetAndLiabilities : applicant.AssetsAndLiabilities__r
      ) {
        if (String.isBlank(assetAndLiabilities.id)) {
          assetAndLiabilities.Applicant__c = applicant.Id;
        }
      }
      ApplicantRepository.upsertRecords(applicant.AssetsAndLiabilities__r);
    }

    // upsert revenues
    if (!CollectionUtils.isListEmpty(applicant?.Revenues__r)) {
      for (FinServ__Revenue__c revenue : applicant.Revenues__r) {
        if (String.isBlank(revenue.id)) {
          revenue.Applicant__c = applicant.Id;
        }
      }
      ApplicantRepository.upsertRecords(applicant.Revenues__r);
    }

    return applicant;
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
