/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class SurveyRepository extends DatabaseUtils {
  /**
   * @description Fetch survey template by template unique name
   * @author Digital Align Team | 08-25-2021
   * @param String templateName
   * @return List<SurveyTemplate__c>
   **/
  public static List<SurveyTemplate__c> fetchSurveyTemplatesByName(
    String templateName
  ) {
    return (List<SurveyTemplate__c>) getRecords(
      Query.newInstance(SurveyTemplate__c.SObjectType)
        .addFields()
        .queryChild('mflow__SurveyTemplateItems__r')
        .addFields()
        .orderBy('mflow__Order__c')
        .run()
        .whereEq('Name', templateName)
        .orderBy('mflow__Order__c')
        .toString(true)
    );
  }

  /**
   * @description getch survey template by passing custom conditions to where clause
   * @author Digital Align Team | 08-25-2021
   * @param String customCondition
   * @return List<SurveyTemplate__c>
   **/
  public static List<SurveyTemplate__c> fetchSurveyTemplateByCondition(
    String customCondition
  ) {
    return (List<SurveyTemplate__c>) getRecords(
      Query.newInstance(SurveyTemplate__c.SObjectType)
        .addFields()
        .queryChild('mflow__SurveyTemplateItems__r')
        .addFields()
        .orderBy('mflow__Order__c')
        .run()
        .whereCon(customCondition)
        .orderBy('mflow__Order__c')
        .toString(true)
    );
  }
}
