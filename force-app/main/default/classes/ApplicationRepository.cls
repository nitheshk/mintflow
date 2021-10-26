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
   * @description fetch lead with child objects
   * @author Digital Align Team | 10-12-2021
   * @param Id leadId
   * @return Lead
   **/
  global static Lead fetchLeadById(Id leadId) {
    return (Lead) DatabaseUtils.getRecord(
      new Query(Lead.SObjectType)
        .addFields()
        .queryChild('dau01__Surveys__r')
        .addFields()
        .orderBy('dau01__Order__c')
        .run()
        .whereEq('Id', leadId)
        .toString(true)
    );
  }

  /**
   * @description Read Application with child record
   * @author Digital Align Team | 10-26-2021
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationWithChild(Id applicationId) {
    return (Account) DatabaseUtils.getRecord(
      new Query(Account.SObjectType)
        .addFields()
        .queryChild('dau01__Applicants__r')
        .orderBy('dau01__Order__c')
        .run()
        .queryChild('FinServ__HouseholdFinancialAccounts__r')
        .run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }
}
