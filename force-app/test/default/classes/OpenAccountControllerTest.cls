@istest
public with sharing class OpenAccountControllerTest {
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

    Map<String, Object> params = new Map<String, Object>();
    params.put('app', application.Name);
    params.put('ch', application.CreatedChannel__c);
    params.put('pid', 'IC001');
    params.put(
      'edt',
      Datetime.now().addHours((Integer) ApplicationConfiguration__c.getInstance().ReferralUrlExpirationTime__c)
    );

    testPage.getParameters().put('cvmf', SecurityUtils.encryptUrl(JSON.serialize(params, true)));
    ApexRequest request = new ApexRequest();
    OpenAccountController oc = new OpenAccountController();
    request = new ApexRequest();
    request.token = ApexRequest.getToken();

    oc.initOpenAccount();
  }
}
