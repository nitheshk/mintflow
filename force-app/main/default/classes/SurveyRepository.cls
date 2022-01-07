/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class SurveyRepository extends DatabaseUtils {
  /**
   * @description fetch templates based on filters
   * @author Digital Align Team | 01-04-2022
   * @param Object filter
   * @param String fieldSetName
   * @param String eventIdentifier
   * @return List<SurveyTemplate__c>
   **/
  public static List<SurveyTemplate__c> fetchSurveyTemplateByFilters(
    Object filter,
    String fieldSetName,
    String eventIdentifier
  ) {
    Query query = Query.newInstance(SurveyTemplate__c.SObjectType)
      .addFields()
      .queryChild('mflow__SurveyQuestions__r')
      .addFields()
      .orderBy('mflow__Order__c')
      .run()
      .whereEq('mflow__isActive__c', true)
      .andCon()
      .whereEq('mflow__EventIdentifier__c', eventIdentifier);
    if (filter != null) {
      query.andCon().filter(filter, fieldSetName);
    }
    query.orderBy('mflow__Order__c');
    return (List<SurveyTemplate__c>) getRecords(query.toString(true));
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
   * @description Read Existing Survey
   * @author Digital Align Team | 01-07-2022
   * @param String eventIdentifier
   * @return List<Survey__c>
   */
  public static List<Survey__c> readExistingSurvey(String eventIdentifier) {
    Query query = Query.newInstance(Survey__c.SObjectType)
      .addFields()
      .whereEq('mflow__EventIdentifier__c', eventIdentifier)
      .andCon()
      .whereEq('mflow__Application__c', ApexRequest.getApplicationId());
    if (ApexRequest.getParams('applicantId') != null) {
      query.andCon()
        .whereEq('mflow__Applicant__c', ApexRequest.getParams('applicantId'));
    }
    query.orderBy('mflow__Order__c');
    return (List<Survey__c>) getRecords(query.toString(true));
  }
}
