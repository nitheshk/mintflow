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
   * @description
   * @author Digital Align Team | 10-05-2021
   * @param Id accountId
   * @return Account
   **/
  global static Account fetchPersonAccountByAccId(Id accountId) {
    return (Account) DatabaseUtils.getRecord(
      new Query(Account.SObjectType)
        .addFields('PersonContactId')
        .whereEq('Id', accountId)
        .toString(true)
    );
  }

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
}
