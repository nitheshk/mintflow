@istest
public with sharing class OnlineAccountControllerTest {
  private static void makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    insert appConfig;
    TestData.createSiteSetting();
    List<FinancialProduct__c> products = TestData.createProduct();
    insert products;
  }
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
  @isTest
  static void initializeApplicationTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();

    SecurityUtils.CipherDTO cipher = new SecurityUtils.CipherDTO();
    cipher.aplType = 'Primary';
    cipher.flw = 'Joint';
    String urlSuffix = 'urlSuffix';
    cipher.appId = application.Id;
    cipher.aplId = applicant.Id;
    cipher.edt = Datetime.now()
      .addHours((Integer) ApplicationConfiguration__c.getInstance().EmailLinkExpirationTime__c);
    cipher.ch = 'Virtual';
    String pageName = '/OpenAccount';

    OnlineAccountController oc = new OnlineAccountController();

    testPage.getParameters().put('vmf', SecurityUtils.encryptUrl(JSON.serialize(cipher, true)));
    oc.initializeApplication();

    //Joint applicant
    ApexRequest.setApplicantType('Joint');
    oc.initializeApplication();

    oc.getStaticUrl();
  }

  @isTest
  static void initializeApplicationTestTwo() {
    OnlineAccountController oc = new OnlineAccountController();
    oc.initializeApplication();
  }
  @isTest
  static void initializeApplicationTestThree() {
    ApexRequest request = new ApexRequest();
    OnlineAccountController oc = new OnlineAccountController();
    oc.initializeApplication();
  }
  @isTest
  static void initializeApplicationFour() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);

    ApexRequest request = new ApexRequest();

    SecurityUtils.CipherDTO cipher = new SecurityUtils.CipherDTO();
    cipher.aplType = 'Primary';
    cipher.flw = 'Joint';
    String urlSuffix = 'urlSuffix';
    cipher.edt = Datetime.now()
      .addHours((Integer) ApplicationConfiguration__c.getInstance().EmailLinkExpirationTime__c);
    cipher.ch = 'Virtual';
    String pageName = '/OpenAccount';

    OnlineAccountController oc = new OnlineAccountController();
    testPage.getParameters().put('vmf', SecurityUtils.encryptUrl(JSON.serialize(cipher, true)));
    oc.initializeApplication();
  }
}
