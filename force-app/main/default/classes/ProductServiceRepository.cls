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
  public static List<FinancialAccountService__c> readExistingService(
    Id financialAccountId
  ) {
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
      .queryChild('mflow__FinancialAccounts__r')
      .addFields()
      .queryLookup('mflow__FinancialProduct__r')
      .addFields('mflow__InternalCode__c')
      .run()
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
  public static List<ProductService__c> fetchServicesByProduct(
    string productId
  ) {
    return (List<ProductService__c>) getRecords(
      Query.newInstance(ProductService__c.SObjectType)
        .addFields()
        .whereEq('mflow__isActive__c', true)
        .andCon()
        .whereEq('FinancialProduct__c', productId)
        .toString()
    );
  }
}
