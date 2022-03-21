public with sharing class ProductController {
  @AuraEnabled(cacheable=true)
  public static List<financialProduct__c> getProducts() {
    return [
      SELECT
        Id,
        Name,
        mflow__Category__c,
        mflow__ImageURL__c,
        mflow__ShortDescription__c,
        mflow__Type__c,
        mflow__longDescription__c
      FROM mflow__FinancialProduct__c
      WHERE mflow__isActive__c = TRUE
    ];
  }
}
//
