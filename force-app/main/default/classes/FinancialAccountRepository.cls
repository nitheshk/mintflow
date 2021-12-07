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
        .whereIn('Id', financialAccountIds)
        .toString()
    );
  }

  /**
   * @description Read Application with FinancialAccount and Applicants
   * @author Digital Align Team | 12-02-2021
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationWithChild(Id applicationId) {
    return (Account) DatabaseUtils.getRecord(
      Query.newInstance(Account.SObjectType)
        .addFields()
        .queryChild('mflow__Applicants__r')
        .addFields()
        .addFields('RecordType.Name')
        .orderBy('mflow__Order__c')
        .run()
        .queryChild('FinServ__HouseholdFinancialAccounts__r')
        .addFields()
        .addFields('RecordType.Name')
        .run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }
}
