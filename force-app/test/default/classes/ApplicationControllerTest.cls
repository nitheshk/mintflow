@istest
public with sharing class ApplicationControllerTest {
  private static ApplicationConfiguration__c makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    appConfig = (ApplicationConfiguration__c) DatabaseUtils.insertRecord(appConfig);
    return appConfig;
  }
  private static Application__c makeApplicationData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);

    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    IdentificationDocument__c identity = TestData.createIdentity(null);
    identity.Applicant__c = applicant.Id;
    identity = (IdentificationDocument__c) DatabaseUtils.insertRecord(identity);
    applicant.mflow__IdentificationDocuments__r.addAll(new List<IdentificationDocument__c>{ identity });
    acc.Applicants__r.addAll(new List<Applicant__c>{ applicant });
    return acc;
  }
  @istest
  private static void startApplicationTest() {
    Application__c application = makeApplicationData();
    makeApplicationConfiguration();
    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'url' => 'url', 'ch' => 'Virtual' });
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicantType('Primary');
    request.setData(application);
    test.startTest();
    ApplicationController.startApplication(request);
    ApplicationController.readApplicationWithChild(request);
    ApplicationController.saveApplication(request);
    ApplicationController.deleteEntity(request);
    ApplicationController.reviewInformationSubmit(request);
    ApplicationController.refreshToken(request);
    ApplicationController.expireToken(request);
    ApplicationController.generateConsentPdf(request);
    ApplicationController.preserveApplication(request);
    ApplicationController.fetchConsents(request);
    ApplicationController.fetchSurvey(request);
    test.stopTest();
  }
  @istest
  private static void submitApplicationTest() {
    Application__c application = makeApplicationData();
    makeApplicationConfiguration();
    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'url' => 'url', 'ch' => 'Virtual' });
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicantType('Primary');
    request.setData(application);
    Test.setMock(HttpCalloutMock.class, new RpaServiceMock('updatememberdetails', '200'));
    Test.startTest();
    ApplicationController.submitApplication(request);
    Test.stopTest();
  }
}
