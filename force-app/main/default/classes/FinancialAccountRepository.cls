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
   * @return List<FinancialAccount__c>
   **/
  global static List<FinancialAccount__c> readFinancialAccountsWithChild(Set<Id> financialAccountIds) {
    return (List<FinancialAccount__c>) DatabaseUtils.getRecords(
      Query.newInstance(FinancialAccount__c.SObjectType)
        .addFields()
        .queryChild('mflow__FinancialAccountTransactions__r')
        .addFields()
        .run()
        .addFields()
        .queryChild('mflow__FinancialAccountServices__r')
        .addFields()
        .run()
        .whereIn('Id', financialAccountIds)
        .toString()
    );
  }

  /**
   * @description read financial product by Internal Code
   * @author Digital Align Team | 12-13-2021
   * @param String internalProductCode
   * @return FinancialProduct__c
   **/
  global static FinancialProduct__c readFinancialProductByInternalCode(String internalProductCode) {
    return (FinancialProduct__c) DatabaseUtils.getRecord(
      Query.newInstance(FinancialProduct__c.SObjectType)
        .addFields()
        .whereEq('InternalCode__c', internalProductCode)
        .addLimit(1)
        .toString()
    );
  }
}
