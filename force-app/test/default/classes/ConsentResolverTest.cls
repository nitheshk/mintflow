@istest
public with sharing class ConsentResolverTest {
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
    ApexRequest.setApplicantType('Primary');
    request.header = '{"eventIdentifier":"event" }';
    ApexResponse res = ApplicationController.fetchConsents(request);
    res = ApplicationController.fetchConsents(request);
    system.assertEquals(200, res.status, 'success');

    // insert TestData.createConsentLineItem();
    // request = new ApexRequest();
    // request.token = ApexRequest.getToken();
    // ApexRequest.setApplicantType('Primary');
    // request.header = '{"eventIdentifier":"event" }';
    // ApplicationController.fetchConsents(request);
    // system.assertEquals(200, res.status, 'success');

    // request = new ApexRequest();
    // request.token = ApexRequest.getToken();
    // ApexRequest.setApplicantType('Primary');
    // request.header = '{"eventIdentifier":"event","filter":[Name] }';
    // ApplicationController.fetchConsents(request);
    // system.assertEquals(200, res.status, 'success');
  }
}
