/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description Repository to Financial Account
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FinancialAccountRepository extends DatabaseUtils {
  /**
   * @description read financial account with child by ids
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> financialAccountIds
   * @return List<FinServ__FinancialAccount__c>
   **/
  global static List<FinServ__FinancialAccount__c> readFinancialAccountsWithChild(
    Set<Id> financialAccountIds
  ) {
    return (List<FinServ__FinancialAccount__c>) DatabaseUtils.getRecords(
      new Query(FinServ__FinancialAccount__c.SObjectType)
        .addFields()
        .whereIn('Id', financialAccountIds)
        .toString()
    );
  }
}
