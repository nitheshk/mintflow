@istest
public with sharing class FinancingControllerTest {
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
  @istest
  private static void fetchLinkTokenTestOne() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    ApexRequest request = new ApexRequest();

    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('PlaidRequest', '200'));
    test.startTest();
    ApexResponse res = FinancingController.fetchLinkToken(request);

    request.token = 'Invalid token';
    res = FinancingController.fetchLinkToken(request);
    Test.stopTest();
  }
  @istest
  private static void fetchLinkTokenTestTwo() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('PlaidRequestFailed', '400'));
    ApexResponse res = FinancingController.fetchLinkToken(request);
    Test.stopTest();
  }

  @istest
  private static void fetchAccountsForTransactionOne() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'publicToken' => 'publicToken' });
    request.token = ApexRequest.getToken();
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('PlaidExchangeToken', '200'));
    ApexResponse res = FinancingController.fetchAccountsForTransaction(request);
    Test.stopTest();
  }
  @istest
  private static void fetchAccountsForTransactionTwo() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'publicToken' => 'publicToken' });
    request.token = ApexRequest.getToken();
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('Plaid', '200'));
    ApexResponse res = FinancingController.fetchAccountsForTransaction(request);
    Test.stopTest();
  }
}
