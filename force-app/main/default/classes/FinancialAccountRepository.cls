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
      Query.newInstance(FinServ__FinancialAccount__c.SObjectType)
        .addFields()
        .queryChild('mflow__FinancialAccountTransactions__r')
        .addFields()
        .run()
        .whereIn('Id', financialAccountIds)
        .toString()
    );
  }

  /**
   * @description fetch Account Contact Relation by account and contact id
   * @author Digital Align Team | 12-13-2021
   * @param Id accountId
   * @param Id contactId
   * @return AccountContactRelation
   **/
  global static AccountContactRelation fetchAccountContactRelation(
    Id accountId,
    Id contactId
  ) {
    return (AccountContactRelation) DatabaseUtils.getRecord(
      Query.newInstance(AccountContactRelation.SObjectType)
        .whereEq('AccountId', accountId)
        .andCon()
        .whereEq('ContactId', contactId)
        .addLimit(1)
        .toString()
    );
  }

  /**
   * @description fetch Primary Account Contact Relation by contact id
   * @author Digital Align Team | 12-13-2021
   * @param Id accountId
   * @param Id contactId
   * @return AccountContactRelation
   **/
  global static AccountContactRelation fetchPrimaryAccountContactRelation(
    Id contactId
  ) {
    return (AccountContactRelation) DatabaseUtils.getRecord(
      Query.newInstance(AccountContactRelation.SObjectType)
        .whereEq('FinServ__PrimaryGroup__c', true)
        .andCon()
        .whereEq('ContactId', contactId)
        .addLimit(1)
        .toString()
    );
  }

  /**
   * @description read financial product by Internal Code
   * @author Digital Align Team | 12-13-2021
   * @param String internalProductCode
   * @return FinancialProduct__c
   **/
  global static FinancialProduct__c readFinancialProductByInternalCode(
    String internalProductCode
  ) {
    return (FinancialProduct__c) DatabaseUtils.getRecord(
      Query.newInstance(FinancialProduct__c.SObjectType)
        .addFields()
        .whereEq('InternalCode__c', internalProductCode)
        .addLimit(1)
        .toString()
    );
  }
}
