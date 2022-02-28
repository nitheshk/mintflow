/**
 * Copyright (c) 2021 Digital Align
 * @group Resolver
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class SurveyResolver extends AbstractService {
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
   * @description
   * @author Digital Align Team | 01-05-2022
   * @param String data
   * @return List<Survey__c>
   **/
  global virtual List<Survey__c> fetchSurvey(String data) {
    List<Object> filters = (List<Object>) ApexRequest.getParams('filter');
    List<Survey__c> surveys = new List<Survey__c>();

    String eventIdentifier = String.valueOf(
      ApexRequest.getParams('eventIdentifier')
    );

    surveys = SurveyRepository.readExistingSurvey(eventIdentifier);
    if (!surveys.isEmpty()) {
      return surveys;
    }

    Account application = SurveyRepository.readApplicationWithFA(
      ApexRequest.getApplicationId()
    );

    //resolve survey using financial account
    surveys.addAll(resolveSurveys(application));
    //resolve survey using custom filter
    surveys.addAll(resolveSurveys(application, filters));
    // remove duplicate survey
    if (!surveys.isEmpty()) {
      surveys = this.removeDuplicateSurveys(surveys);
      surveys = this.sort(surveys);
      SurveyRepository.upsertRecords(surveys);
    }

    return surveys;
  }

  /**
   * @description resolve survey using custom filter
   * @author Digital Align Team | 12-27-2021
   * @param Account application
   * @param List<Object> filters
   * @return List<Survey__c>
   **/
  global virtual List<Survey__c> resolveSurveys(
    Account application,
    List<Object> filters
  ) {
    if (!CollectionUtils.isListEmpty(filters)) {
      for (Object filter : filters) {
        Map<String, Object> filterMap = (Map<String, Object>) filter;
        filterMap.put(
          'mflow__ApplicantType__c',
          ApexRequest.getApplicantType()
        );
        filterMap.put('$mflow__ApplicantType__c', 'INCLUDES');
        filterMap.put('mflow__Channel__c', application.CreatedChannel__c);
        filterMap.put('$mflow__Channel__c', 'INCLUDES');
      }
    } else {
      filters = new List<Object>();
      Map<String, Object> filterMap = new Map<String, Object>();
      filterMap.put('mflow__ApplicantType__c', ApexRequest.getApplicantType());
      filterMap.put('$mflow__ApplicantType__c', 'INCLUDES');
      filterMap.put('mflow__Channel__c', application.CreatedChannel__c);
      filterMap.put('$mflow__Channel__c', 'INCLUDES');
      filters.add(filterMap);
    }

    String eventIdentifier = String.valueOf(
      ApexRequest.getParams('eventIdentifier')
    );

    // fetch survey item by  custom filter
    List<SurveyTemplate__c> templates = SurveyRepository.fetchSurveyTemplateByFilters(
      filters,
      'mflow__Filter',
      eventIdentifier
    );

    // map survey items into survey
    return this.buildSurvey(templates, null);
  }

  /**
   * @description Resolve survey using Financial Account selection
   * @author Digital Align Team | 12-27-2021
   * @param Account application
   * @param List<Object> filters
   * @return List<Survey__c>
   **/
  global virtual List<Survey__c> resolveSurveys(Account application) {
    List<Survey__c> surveys = new List<Survey__c>();

    if (CollectionUtils.isListEmpty(application.FinancialAccounts__r)) {
      return surveys;
    }

    String eventIdentifier = String.valueOf(
      ApexRequest.getParams('eventIdentifier')
    );

    for (
      FinServ__FinancialAccount__c financialAccount : application.FinancialAccounts__r
    ) {
      Map<String, Object> filterMap = new Map<String, Object>();
      filterMap.put('mflow__ApplicantType__c', ApexRequest.getApplicantType());
      filterMap.put('$mflow__ApplicantType__c', 'INCLUDES');
      filterMap.put('mflow__Channel__c', application.CreatedChannel__c);
      filterMap.put('$mflow__Channel__c', 'INCLUDES');
      filterMap.put(
        'mflow__FinancialProductCode__c',
        financialAccount.FinancialProduct__r.InternalCode__c
      );

      // fetch survey item by  custom filter
      List<SurveyTemplate__c> templates = SurveyRepository.fetchSurveyTemplateByFilters(
        filterMap,
        'mflow__Filter',
        eventIdentifier
      );

      // map survey items into survey
      surveys.addAll(this.buildSurvey(templates, financialAccount.Id));
    }
    return surveys;
  }

  /**
   * @description  build survey object based on the template list
   * @author Digital Align Team | 01-05-2022
   * @param List<SurveyTemplate__c> surveyTemplates
   * @param Id financialAccountId
   * @return  List<Survey__c>
   **/
  global virtual List<Survey__c> buildSurvey(
    List<SurveyTemplate__c> surveyTemplates,
    Id financialAccountId
  ) {
    List<Survey__c> surveyList = new List<Survey__c>();
    for (SurveyTemplate__c surveyTemplate : surveyTemplates) {
      for (SurveyQuestion__c item : surveyTemplate.SurveyQuestions__r) {
        Survey__c surveyObj = new Survey__c();
        if (ApexRequest.getParams('applicantId') != null) {
          surveyObj.Applicant__c = (Id) ApexRequest.getParams('applicantId');
        }
        if (String.isNotBlank(financialAccountId)) {
          surveyObj.FinancialAccount__c = financialAccountId;
        }
        surveyObj.EventIdentifier__c = surveyTemplate.EventIdentifier__c;
        surveyObj.Answer__c = null;
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
        surveyObj.Required__c = item.Required__c;
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

  /**
   * @description remove duplicate survey
   * @author Digital Align Team | 12-27-2021
   * @param List<Survey__c> surveys
   * @return List<Survey__c>
   **/
  global virtual List<Survey__c> removeDuplicateSurveys(
    List<Survey__c> surveys
  ) {
    Set<String> consentCode = new Set<String>();
    List<Survey__c> newSurveyList = new List<Survey__c>();
    for (Survey__c survey : surveys) {
      if (consentCode.add(survey.QuestionCode__c)) {
        newSurveyList.add(survey);
      }
    }
    return newSurveyList;
  }

  // Custom Sort Wrapper Class
  global class SurveyWrapper implements Comparable {
    global Survey__c survey;
    // Constructor
    global SurveyWrapper(Survey__c survey) {
      this.survey = survey;
    }
    global Integer compareTo(Object compareTo) {
      SurveyWrapper compareToSurvey = (SurveyWrapper) compareTo;
      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;
      if (survey.Order__c > compareToSurvey.survey.Order__c) {
        // Set return value to a positive value.
        returnValue = 1;
      } else if (survey.Order__c < compareToSurvey.survey.Order__c) {
        // Set return value to a negative value.
        returnValue = -1;
      }
      return returnValue;
    }
  }

  /**
   * @description  Custom Sort for survey quesitons
   * @author Digital Align Team | 01-21-2022
   * @param List<Survey__c> surveys
   * @return List<Survey__c>
   **/
  global virtual List<Survey__c> sort(List<Survey__c> surveys) {
    List<SurveyWrapper> surveyWrapperList = new List<SurveyWrapper>();
    for (Survey__c survey : surveys) {
      surveyWrapperList.add(new SurveyWrapper(survey));
    }
    surveyWrapperList.sort();
    surveys = new List<Survey__c>();
    for (SurveyWrapper surveyWrapper : surveyWrapperList) {
      surveys.add(surveyWrapper.survey);
    }
    return surveys;
  }
}
