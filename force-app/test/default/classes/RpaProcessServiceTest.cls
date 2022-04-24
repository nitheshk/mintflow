@IsTest
public with sharing class RpaProcessServiceTest {
  //makeApplicationConfiguration
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
  private static void testObtainApplicationData() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/mflow/rpa/v1/obtainapplicationdata/';
    req.addParameter('applicationName', application.Name);
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    Test.startTest();
    RpaProcessService.doGet();
    Test.stopTest();
  }
  @IsTest
  private static void testObtainapplicationfilesData() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/mflow/rpa/v1/obtainapplicationfiles/';
    req.addParameter('applicationNumber', application.Name);
    req.httpMethod = 'GET';
    RestContext.request = req;
    RestContext.response = res;
    Test.startTest();
    RpaProcessService.doGet();
    Test.stopTest();
  }

  @IsTest
  private static void updateApplicationData() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/mflow/rpa/v1/updateapplicationdata/';
    req.httpMethod = 'POST';
    req.requestBody = Blob.valueOf(
      '{"ApplicationId":"' +
      application.Id +
      '","ApplicationNumber":"App-0084","ExternalApplicationNumber":"4099","ExternalApplicationStatus":"PENDING","IsExistingCustomer":false,"Applicants":[{"ApplicantId":"' +
      applicant.Id +
      '","CustomerNumber":"","OverallDebitBureauResult":"","CreditScore":0,"QualifiedScore":0,"CustomerScore":0,"HighRiskConsumer":"","QualifiedDecision":"","IdentityVerificationStatus":"","OFAC":"","SSNValidation":"","RunWithKIQ":"","RunWithoutKIQ":""}]}'
    );
    RestContext.request = req;
    RestContext.response = res;
    RpaProcessService.doPost();

    req.requestBody = Blob.valueOf(
      '{"ApplicationId":"' +
      application.Id +
      '","ApplicationNumber":"App-0084","ExternalApplicationNumber":"4099","ExternalApplicationStatus":"Approved","IsExistingCustomer":false,"Applicants":[{"ApplicantId":"' +
      applicant.Id +
      '","CustomerNumber":"","OverallDebitBureauResult":"","CreditScore":0,"QualifiedScore":0,"CustomerScore":0,"HighRiskConsumer":"","QualifiedDecision":"","IdentityVerificationStatus":"","OFAC":"","SSNValidation":"","RunWithKIQ":"","RunWithoutKIQ":""}]}'
    );
    RestContext.request = req;
    RpaProcessService.doPost();
  }

  @IsTest
  private static void scheduleApplicationTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    RpaProcessService.getInstance().scheduleApplication(application);
  }
}
