/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class ConsentRepository extends DatabaseUtils {
  /**
   * @description Fetch consent template by custom filter
   * @author Digital Align Team | 08-25-2021
   * @param List<Object> filters
   * @param String fieldSetName
   * @return List<SurveyTemplate__c>
   **/
  public static List<ConsentLineItem__c> fetchConsentByFilter(
    List<Object> filters,
    String fieldSetName,
    String eventIdentifier
  ) {
    return (List<ConsentLineItem__c>) getRecords(
      Query.newInstance(mflow__ConsentLineItem__c.SObjectType)
        .addFields()
        .queryLookup('mflow__mflow__ConsentTemplate__r')
        .addFields()
        .run()
        .whereEq('mflow__isActive__c', true)
        .andCon()
        .whereNotNull('mflow__ConsentTemplate__c')
        .andCon()
        .whereEq('mflow__EventIdentifier__c', eventIdentifier)
        .andCon()
        .filter(filters, fieldSetName)
        .orderBy('mflow__Order__c')
        .toString(true)
    );
  }
}
