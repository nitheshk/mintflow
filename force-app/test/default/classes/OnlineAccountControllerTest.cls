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
  static void initializeOpenAccountTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();

    SecurityUtils.CipherDTO cipher = new SecurityUtils.CipherDTO();
    cipher.aplType = ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE;
    cipher.flw = ApplicationConstant.FLOW_TYPE_APPLICATION;
    String urlSuffix = 'urlSuffix';
    cipher.appId = application.Id;
    cipher.aplId = applicant.Id;
    cipher.edt = Datetime.now()
      .addHours((Integer) ApplicationConfiguration__c.getInstance().EmailLinkExpirationTime__c);
    cipher.ch = ApplicationConstant.CHANNEL_VIRTUAL;
    String pageName = '/OpenAccount';

    testPage.getParameters().put('vmf', SecurityUtils.encryptUrl(JSON.serialize(cipher, true)));
    OnlineAccountController oc = new OnlineAccountController();

    //Success
    PageReference pg = oc.initializeOpenAccount();
    system.assertNotEquals(null, pg, 'success case');

    // exception
    testPage.getParameters().put('cvmf', SecurityUtils.encryptBase64(JSON.serialize(cipher, true)));
    pg = oc.initializeOpenAccount();
    system.assertNotEquals(null, pg, 'exception case');
  }

  @isTest
  static void initializeApplicationTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    SecurityUtils.CipherDTO cipher = new SecurityUtils.CipherDTO();
    cipher.aplType = ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE;
    cipher.flw = ApplicationConstant.FLOW_TYPE_APPLICATION;
    String urlSuffix = 'urlSuffix';
    cipher.appId = application.Id;
    cipher.aplId = applicant.Id;
    cipher.edt = Datetime.now()
      .addHours((Integer) ApplicationConfiguration__c.getInstance().EmailLinkExpirationTime__c);
    cipher.ch = ApplicationConstant.CHANNEL_VIRTUAL;

    Test.startTest();
    OnlineAccountController oc = new OnlineAccountController();
    //testPage.getParameters().put('vmf', SecurityUtils.encryptUrl(JSON.serialize(cipher, true)));
    oc.initializeApplication();

    if (PageUtils.getCookie('token') != null) {
      PageUtils.setCookie(new Cookie('token', null, null, -1, false));
    }
    testPage.getParameters().put('vmf', SecurityUtils.encryptBase64(JSON.serialize(cipher, true)));

    PageReference pg = oc.initializeApplication();
    system.assertEquals(null, pg, 'success case');

    Test.stopTest();
  }

  @isTest
  static void createApplicationTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');

    Test.startTest();
    OnlineAccountController oc = new OnlineAccountController();
    PageReference pg = oc.initializeApplication();
    system.assertEquals(null, pg, 'success case');
    Test.stopTest();
    oc.getStaticUrl();
  }

  @isTest
  static void initializeApplicationTestOne() {
    OnlineAccountController oc = new OnlineAccountController();
    PageReference pg = oc.initializeApplication();
    system.assertNotEquals(null, pg, 'success case');
  }

  @isTest
  static void initializeOnlinePortalTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);

    Test.startTest();
    OnlineAccountController oc = new OnlineAccountController();
    PageReference pg = oc.initializeOnlinePortal();
    system.assertEquals(null, pg, 'success case');
    Test.stopTest();
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
    OnlineAccountController oc = new OnlineAccountController();
    request = new ApexRequest();
    request.token = ApexRequest.getToken();

    PageReference pg = oc.initializeOpenAccount();
    system.assertNotEquals(null, pg, 'success case');
  }
}
