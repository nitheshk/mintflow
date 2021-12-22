/**
 * Copyright (c) 2021 Digital Align
 * @group Resolver
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class SurveyResolver extends AbstractService {
  @TestVisible
  private static SurveyResolver serviceInstance;

  public SurveyResolver() {
    super(SurveyResolver.class);
  }

  /**
   * @description Provides a singleton instance of SurveyResolver from which all other class methods can be accessed.
   * @author Digital Align Team | 07-22-2021
   * @return Object  singleton
   **/
  public static SurveyResolver getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (SurveyResolver) getInstance(SurveyResolver.class);
    }
    return serviceInstance;
  }

  /**
   * @description fetch survey by filters
   * @author Digital Align | 12-22-2021
   * @param List<Object> filters
   * @return virtual
   **/
  global virtual List<Survey__c> fetchSurvey(List<Object> filters) {
    List<SurveyTemplate__c> surveyTemlates = SurveyRepository.fetchSurveyTemplateByFilters(
      filters
    );
    return buildSurvey(surveyTemlates);
  }

  /**
   * @description build survey object based on the template list
   * @author Digital Align Team | 08-25-2021
   * @param List<SurveyTemplate__c> surveyTemlates
   * @return List<Survey__c>
   **/
  global virtual List<Survey__c> buildSurvey(
    List<SurveyTemplate__c> surveyTemlates
  ) {
    List<Survey__c> surveyList = new List<Survey__c>();
    for (SurveyTemplate__c surveyTemplate : surveyTemlates) {
      for (SurveyTemplateItem__c item : surveyTemplate.SurveyTemplateItems__r) {
        Survey__c surveyObj = new Survey__c();
        surveyObj.OptionType__c = item.OptionType__c;
        surveyObj.ParentQuestionCode__c = item.ParentQuestionCode__c;
        surveyObj.QuestionCode__c = item.QuestionCode__c;
        surveyObj.QuestionNumber__c = item.QuestionNumber__c;
        surveyObj.ShortDescription__c = item.ShortDescription__c;
        surveyObj.LongDescription__c = item.LongDescription__c;
        surveyObj.ShowQuestionNumber__c = item.ShowQuestionNumber__c;
        surveyObj.Condition__c = item.Condition__c;
        surveyObj.hasChild__c = item.hasChild__c;
        surveyObj.CustomStyle__c = item.CustomStyle__c;
        surveyObj.Order__c = item.Order__c;
        surveyObj.Options__c = item.Options__c;
        surveyObj.Name = item.Name;
        surveyObj.TemplateName__c = surveyTemplate.Name;
        if (String.isBlank(item.ParentQuestionCode__c)) {
          surveyObj.isDisplayed__c = true;
        } else {
          surveyObj.isDisplayed__c = false;
        }
        surveyList.add(surveyObj);
      }
    }
    return surveyList;
  }
}
