@istest
public with sharing class SurveyResolverTest {
  private static Application__c makeApplicationData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);

    List<FinancialProduct__c> products = TestData.createProduct();
    products = (List<FinancialProduct__c>) DatabaseUtils.insertRecords(products);

    FinancialAccount__c finAcc = TestData.makeFinancialAccount();
    finAcc.mflow__FinancialProduct__c = products[0].Id;
    finAcc.mflow__Application__c = acc.Id;
    Id recType = Schema.SObjectType.FinancialAccount__c.getRecordTypeInfosByName().get('Savings').getRecordTypeId();
    finAcc.RecordTypeId = recType;
    finAcc = (FinancialAccount__c) DatabaseUtils.insertRecord(finAcc);

    FinancialAccountTransaction__c tran = TestData.createFinancialAccountTransaction();
    tran.FinancialAccount__c = finAcc.Id;
    tran.TransactionDate__c = DateTime.newInstance(2007, 6, 23, 3, 3, 3);
    tran = (FinancialAccountTransaction__c) DatabaseUtils.insertRecord(tran);

    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    mflow__Consent__c consent = TestData.createConsent();
    consent.Application__c = acc.Id;
    consent.mflow__Applicant__c = applicant.Id;
    consent = (mflow__Consent__c) DatabaseUtils.insertRecord(consent);

    acc.Applicants__r.addAll(new List<Applicant__c>{ applicant });
    acc.mflow__FinancialAccounts__r.addAll(new List<FinancialAccount__c>{ finAcc });
    return acc;
  }
  private static mflow__SurveyTemplate__c makeSurveyTemplate() {
    mflow__SurveyTemplate__c surveyTemplate = TestData.createSurveyTemplates();
    surveyTemplate = (mflow__SurveyTemplate__c) DatabaseUtils.insertRecord(surveyTemplate);

    SurveyQuestion__c surveyQuestion = TestData.createSurveyQuestion();
    surveyQuestion.mflow__SurveyTemplate__c = surveyTemplate.Id;
    surveyQuestion = (SurveyQuestion__c) DatabaseUtils.insertRecord(surveyQuestion);
    surveyTemplate.SurveyQuestions__r.addALl(new List<SurveyQuestion__c>{ surveyQuestion });
    return surveyTemplate;
  }
  @IsTest
  private static void fetchSurveyTest() {
    mflow__Application__c application = makeApplicationData();
    mflow__SurveyTemplate__c surveyTemplate = makeSurveyTemplate();
    List<Applicant__c> applicant = [SELECT id FROM Applicant__c WHERE mflow__Application__c = :application.Id];
    ApexRequest request = new ApexRequest();
    request.header = '{"eventIdentifier":"CustomerFlowQuestionaire","filter":[]}';
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicantId(applicant[0].Id);
    test.startTest();
    ApplicationController.fetchSurvey(request);
    SurveyResolver.getInstance()
      .resolveSurveys(
        application,
        new List<object>{ new Map<String, Object>{ 'Name' => 'Checking Application__c Agreement' } }
      );
    SurveyResolver.getInstance().resolveSurveys(application);
    SurveyResolver.getInstance().resolveSurveys(application, new List<object>());
    SurveyResolver.getInstance().removeDuplicateSurveys(new List<Survey__c>());
    SurveyResolver.getInstance().sort(new List<Survey__c>());
    SurveyResolver.getInstance()
      .buildSurvey(new List<SurveyTemplate__c>{ TestData.createSurveyTemplates() }, application.Id);

    test.stopTest();
  }
}
