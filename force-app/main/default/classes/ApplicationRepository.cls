/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description Repository to fetch application object
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual inherited sharing class ApplicationRepository extends DatabaseUtils {
  /**
   * @description Read Application with child record
   * Applicants contains only ids
   * Financial Account contains only Ids
   * @author Digital Align Team | 10-26-2021
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationWithChild(Id applicationId) {
    return (Account) DatabaseUtils.getRecord(
      new Query(Account.SObjectType)
        .addFieldSet('dau01__Application')
        //.removeFields('dau01__SessionToken__c')
        .queryChild('dau01__Applicants__r')
        .orderBy('dau01__Order__c')
        .run()
        .queryChild('FinServ__HouseholdFinancialAccounts__r')
        .run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }

  /**
   * @description Read Application child with specified applicatid
   * @author Digital Align Team | 11-19-2021
   * @param Id applicationId
   * @param Id applicantId
   * @return Account
   **/
  global static Account readApplicationWithChild(
    Id applicationId,
    Id applicantId
  ) {
    return (Account) DatabaseUtils.getRecord(
      new Query(Account.SObjectType)
        .addFieldSet('dau01__Application')
        .removeFields('dau01__SessionToken__c')
        .queryChild('dau01__Applicants__r')
        .whereEq('Id', applicantId)
        .orderBy('dau01__Order__c')
        .run()
        .queryChild('FinServ__HouseholdFinancialAccounts__r')
        .run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }

  /**
   * @description Read Application
   * @author Digital Align Team | 11-10-2021
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationById(Id applicationId) {
    return (Account) DatabaseUtils.getRecord(
      new Query(Account.SObjectType)
        .addFields()
        .whereEq('Id', applicationId)
        .toString()
    );
  }

  /**
   * @description Read Application for session token verification
   * @author Digital Align Team | 11-17-2021
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationForToken(Id applicationId) {
    return (Account) DatabaseUtils.getRecord(
      new Query(Account.SObjectType)
        .addFields('SessionToken__c,ApplicationNumber__c')
        .whereEq('Id', applicationId)
        .toString()
    );
  }

  /**
   * @description Read application with Applicants
   * @author Digital Align Team | 11-15-2021
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationWithApplicants(Id applicationId) {
    return (Account) DatabaseUtils.getRecord(
      new Query(Account.SObjectType)
        .addFieldSet('dau01__Application')
        .queryChild('dau01__Applicants__r')
        .addFields()
        .orderBy('dau01__Order__c')
        .run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }

  /**
   * @description Read Site setting
   * @author Digital Align Team | 11-22-2021
   * @return SiteSetting__c
   **/
  global static SiteSetting__c readSiteSetting() {
    return (SiteSetting__c) DatabaseUtils.getRecord(
      new Query(SiteSetting__c.SObjectType)
        .addFields()
        .removeFields(
          'dau01__OnlineSiteUserName__c,dau01__OnlineSitePassword__c'
        )
        .toString()
    );
  }
}
