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
    Object filter,
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

    if (filter != null) {
      query.andCon().filter(filter, fieldSetName);
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

  /**
   * @description Read Application with child record
   * Applicants contains only ids
   * Financial Account contains only Ids
   * @author Digital Align Team | 10-26-2021
   * @param Id applicationId
   * @return Account
   **/
  public static Account readApplicationWithFA(Id applicationId) {
    Query qry = Query.newInstance(Account.SObjectType)
      .addFields()
      .queryChild('mflow__FinancialAccounts__r')
      .addFields()
      .queryLookup('mflow__FinancialProduct__r')
      .addFields('mflow__InternalCode__c')
      .run()
      .run()
      .addLimit(1)
      .whereEq('Id', applicationId);
    return (Account) getRecord(qry.toString());
  }

  /**
   * @description Read Existing Consent
   * @author Digital Align Team | 01-07-2022
   * @param String eventIdentifier
   * @return List<Consent__c>
   */
  public static List<Consent__c> readExistingConsent(String eventIdentifier) {
    Query qry = Query.newInstance(Consent__c.SObjectType)
      .addFields()
      .queryLookup('mflow__ConsentTemplate__r')
      .addFields()
      .run()
      .whereEq('mflow__EventIdentifier__c', eventIdentifier)
      .andCon()
      .whereEq('mflow__Application__c', ApexRequest.getApplicationId());
    if (ApexRequest.getParams('applicantId') != null) {
      qry.andCon()
        .whereEq('mflow__Applicant__c', ApexRequest.getParams('applicantId'));
    }
    qry.orderBy('mflow__Order__c');
    return (List<Consent__c>) getRecords(qry.toString(true));
  }
}
