/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class ProductServiceRepository extends DatabaseUtils {
  /**
   * @description Read Existing Service
   * @author Digital Align Team | 02-25-2022
   * @param Id financialAccountId
   * @return List<FinancialAccountService__c>
   */
  public static List<FinancialAccountService__c> readExistingService(Id financialAccountId) {
    Query query = Query.newInstance(FinancialAccountService__c.SObjectType)
      .addFields()
      .whereEq('FinancialAccount__c', financialAccountId)
      .orderBy('mflow__Order__c');
    return (List<FinancialAccountService__c>) getRecords(query.toString(true));
  }
  /**
   * @description Read Application with child record
   * Applicants contains only ids
   * Financial Application__c contains only Ids
   * @author Digital Align Team | 10-26-2021
   * @param Id applicationId
   * @return Application__c
   **/
  public static Application__c readApplicationWithFA(Id applicationId) {
    Query qry = Query.newInstance(Application__c.SObjectType)
      .addFields()
      .queryChild('mflow__CustomerInterests__r')
      .run()
      .queryChild('mflow__FinancialAccounts__r')
      .addFields()
      .run()
      .addLimit(1)
      .whereEq('Id', applicationId);
    return (Application__c) getRecord(qry.toString());
  }
  /**
   * @description fetch templates based on filters
   * @author Digital Align Team | 01-04-2022
   * @param String productId
   * @return List<ProductService__c>
   **/
  public static List<ProductService__c> fetchServicesByProduct(string productId) {
    return (List<ProductService__c>) getRecords(
      Query.newInstance(ProductService__c.SObjectType)
        .addFields()
        .whereEq('mflow__isActive__c', true)
        .andCon()
        .whereEq('FinancialProduct__c', productId)
        .toString()
    );
  }

  /**
   * @description fetch product features based on product Id
   * @author Digital Align Team | 03-25-2022
   * @param String productId
   * @return List<ProductFeature__c>
   **/
  public static List<ProductFeature__c> fetchProductFeatureByProduct(string productId) {
    return (List<ProductFeature__c>) getRecords(
      Query.newInstance(ProductFeature__c.SObjectType)
        .addFields()
        .whereEq('mflow__isActive__c', true)
        .andCon()
        .whereEq('FinancialProduct__c', productId)
        .toString()
    );
  }
  /**
   * @description fetch templates based on filters
   * @author Digital Align Team | 01-04-2022
   * @param List<FinancialAccount__c> financialAccounts
   * @return List<ProductService__c>
   **/
  public static List<ReferralProduct__c> fetchReferralProducts(Set<Id> productIds) {
    return (List<ReferralProduct__c>) getRecords(
      Query.newInstance(ReferralProduct__c.SObjectType)
        .addFields(
          'Name,mflow__Required__c,mflow__Order__c,mflow__FinancialProduct__c,mflow__CrossSellProduct__c,IsSelected__c'
        )
        .queryLookup('mflow__CrossSellProduct__r')
        .addFields()
        .run()
        .whereEq('mflow__isActive__c', true)
        .andCon()
        .whereIn('FinancialProduct__c', productIds)
        .andCon()
        .whereNotIn('CrossSellProduct__c', productIds)
        .orderBy('mflow__Order__c')
        .toString()
    );
  }

  /**
   * @description fetch all products
   * @author Digital Align Team | 03-22-2022
   * @return List<financialProduct__c>
   **/
  public static List<financialProduct__c> fetchProducts() {
    return (List<financialProduct__c>) DatabaseUtils.getRecords(
      Query.newInstance(financialProduct__c.SObjectType)
        .addFields()
        .queryChild('mflow__ProductFeatures__r')
        .addFields()
        .whereEq('mflow__ProductService__c', null)
        .andCon()
        .whereEq('mflow__Type__c', 'Product Configuration')
        .orderBy('mflow__Order__c')
        .run()
        .whereEq('mflow__isActive__c', true)
        .orderBy('mflow__Order__c')
        .toString()
    );
  }
}
