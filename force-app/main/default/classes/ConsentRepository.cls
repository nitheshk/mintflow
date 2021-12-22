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
    Query query = Query.newInstance(mflow__ConsentLineItem__c.SObjectType)
      .addFields()
      .queryLookup('mflow__ConsentTemplate__r')
      .addFields()
      .run()
      .whereEq('mflow__isActive__c', true)
      .andCon()
      .whereNotNull('mflow__ConsentTemplate__c')
      .andCon()
      .whereEq('mflow__EventIdentifier__c', eventIdentifier);

    if (!CollectionUtils.isListEmpty(filters)) {
      query.andCon().filter(filters, fieldSetName);
    }
    query.orderBy('mflow__Order__c');
    return (List<ConsentLineItem__c>) getRecords(query.toString(true));
  }

  /**
   * @description read document by developer name
   * @author Digital Align Team | 12-22-2021
   * @param List<String> documentNames
   * @return List<Document>
   **/
  public static List<Document> readDocuments(List<String> documentNames) {
    return (List<Document>) getRecords(
      Query.newInstance(Document.SObjectType)
        .addFields('DeveloperName')
        .whereIn('DeveloperName', documentNames)
        .addLimit(1000)
        .toString(true)
    );
  }
}
