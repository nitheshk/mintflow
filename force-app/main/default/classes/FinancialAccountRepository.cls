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
        .queryLookUp('mflow__FinancialProduct__r')
        .addFields('mflow__IsMembershipProduct__c')
        .run()
        .queryChild('mflow__FinancialAccountTransactions__r')
        .addFields()
        .run()
        .queryChild('mflow__FinancialAccountServices__r')
        .addFields()
        .run()
        .whereIn('Id', financialAccountIds)
        .toString()
    );
  }

  /**
   * @description read Financial Accounts By Application Id
   * @author Digital Align Team | 04-11-2022
   * @param Id applicationId
   * @return List<FinancialAccount__c>
   **/
  global static List<FinancialAccount__c> readFinancialAccountsByAppID(Id applicationId) {
    return (List<FinancialAccount__c>) DatabaseUtils.getRecords(
      Query.newInstance(FinancialAccount__c.SObjectType)
        .addFields()
        .queryLookUp('mflow__FinancialProduct__r')
        .addFields('mflow__IsMembershipProduct__c')
        .run()
        .queryChild('mflow__FinancialAccountTransactions__r')
        .addFields()
        .run()
        .queryChild('mflow__FinancialAccountServices__r')
        .addFields()
        .run()
        .whereEq('mflow__Application__c', applicationId)
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

  /**
   * @description fetch base membership product
   * @author Digital Align Team | 04-11-2022
   * @return FinancialProduct__c
   **/
  global static FinancialProduct__c readBaseProduct() {
    return (FinancialProduct__c) DatabaseUtils.getRecord(
      Query.newInstance(FinancialProduct__c.SObjectType)
        .addFields()
        .whereEq('IsMembershipProduct__c', true)
        .addLimit(1)
        .toString()
    );
  }

  /**
   * @description fetch product features based on product Id
   * @author Digital Align Team | 03-25-2022
   * @param String productId
   * @return List<financialProduct__c>
   **/
  public static List<financialProduct__c> fetchProductWithChildConfig(Id applicationId) {
    return (List<financialProduct__c>) getRecords(
      Query.newInstance(financialProduct__c.SObjectType)
        .addFields()
        .queryChild('mflow__ProductFeatures__r')
        .addFields()
        .whereEq('mflow__ProductService__c', null)
        .andCon()
        .whereEq('mflow__Type__c', ApplicationConstant.PRODUCT_FEATURE_TYPE_PRODUCT_CONFIG)
        .orderBy('mflow__Order__c')
        .run()
        .whereEq('mflow__isActive__c', true)
        .andCon()
        .whereIn(
          'Id',
          Query.newInstance(mflow__FinancialAccount__c.SObjectType)
            .addFields('mflow__FinancialProduct__c')
            .whereEq('mflow__Application__c', applicationId)
            .toString()
        )
        .toString()
    );
  }
}
