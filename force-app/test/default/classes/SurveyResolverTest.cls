@istest
public with sharing class SurveyResolverTest {
  private static mflow__SurveyTemplate__c makeSurveyTemplate() {
    mflow__SurveyTemplate__c surveyTemplate = TestData.createSurveyTemplates();
    surveyTemplate = (mflow__SurveyTemplate__c) DatabaseUtils.insertRecord(surveyTemplate);

    SurveyQuestion__c surveyQuestion = TestData.createSurveyQuestion();
    surveyQuestion.mflow__SurveyTemplate__c = surveyTemplate.Id;
    surveyQuestion = (SurveyQuestion__c) DatabaseUtils.insertRecord(surveyQuestion);
    surveyTemplate.SurveyQuestions__r.addALl(new List<SurveyQuestion__c>{ surveyQuestion });
    return surveyTemplate;
  }
  private static void makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    insert appConfig;
    TestData.createSiteSetting();
    List<FinancialProduct__c> products = TestData.createProduct();
    insert products;
  }

  //createApplicantDataWithChild
  private static Applicant__c createApplicantDataWithChild(Application__c application) {
    Applicant__c applicant = Application.Applicants__r[0];
    SObjectConstructor construct = SObjectConstructor.getInstance(applicant);

    IdentificationDocument__c identity = TestData.createIdentity(applicant.Id);
    insert identity;

    Employment__c employment = TestData.createEmployment(applicant.Id);
    insert employment;

    ContactPointAddress address = TestData.createContactPointAddress(applicant.Id);
    insert address;

    construct.addChildObject('mflow__IdentificationDocuments__r', identity);
    construct.addChildObject('mflow__Employments__r', employment);
    construct.addChildObject('mflow__ContactPointAddresses__r', address);

    return (Applicant__c) construct.build();
  }

  @IsTest
  private static void fetchSurveyTest() {
    makeApplicationConfiguration();
    mflow__SurveyTemplate__c surveyTemplate = makeSurveyTemplate();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.header = '{"eventIdentifier":"Survey" }';
    ApexResponse res = ApplicationController.fetchSurvey(request);

    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.header = '{"eventIdentifier":"Survey","filter":"["filter":"filter"]" }';
    res = ApplicationController.fetchSurvey(request);
  }
}
