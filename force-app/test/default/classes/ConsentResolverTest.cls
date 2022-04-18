@istest
public with sharing class ConsentResolverTest {
  //makeApplicationConfiguration
  private static void makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    insert appConfig;
    TestData.createSiteSetting();
    List<FinancialProduct__c> products = TestData.createProduct();
    insert products;
    Testdata.createConsentLineItem();
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
  private static void fetchConsentsTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.header = '{"eventIdentifier":"MemberAgreementPage" }';
    ApexResponse res = ApplicationController.fetchConsents(request);
    res = ApplicationController.fetchConsents(request);
    system.assertEquals(200, res.status, 'success');
  }
  @IsTest
  private static void generateConsentPdfTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200
    ApexRequest request = new ApexRequest();
    ApexResponse res = new ApexResponse();
    request.token = ApexRequest.getToken();
    request.header = '{"eventIdentifier":"MemberAgreementPage" }';
    res = ApplicationController.generateConsentPdf(request);

    request = new ApexRequest();
    res = ApplicationController.generateConsentPdf(request);

    request = new ApexRequest();
    request.token = 'invalid token';
    res = ApplicationController.generateConsentPdf(request);
    system.assertEquals(400, res.status, 'success');
  }
}
