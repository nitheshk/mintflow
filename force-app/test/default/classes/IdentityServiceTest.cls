@isTest
public with sharing class IdentityServiceTest {
  //makeApplicationConfiguration
  private static void makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    insert appConfig;
    TestData.createSiteSetting();
    List<FinancialProduct__c> products = TestData.createProduct();
    insert products;
  }
  private static EligibleCounty__c makeCountyData() {
    EligibleCounty__c county = TestData.createCounty();
    county = (EligibleCounty__c) DatabaseUtils.insertRecord(county);
    return county;
  }

  public static ContentVersion makeContentVersion() {
    ContentVersion cv = TestData.createContentVersion();
    cv = (ContentVersion) DatabaseUtils.insertRecord(cv);
    return cv;
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
  @isTest
  static void verifyCountyTestOne() {
    makeCountyData();
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, String>{ 'zipcode' => '10001' });
    Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('GeocodingProvider', '200'));
    Test.startTest();
    ApexResponse response = IdentityController.verifyCounty(request);
    Test.stopTest();
    System.assertEquals(200, response.status, 'success');

    request.token = 'Invalid token';
    response = IdentityController.verifyCounty(request);
    system.assertEquals(500, response.status, 'success');
  }

  @isTest
  static void verifyCountyTestTwo() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    ApexRequest request = new ApexRequest();
    ApexResponse response1 = IdentityController.verifyCounty(request);
  }
  @isTest
  static void scanIdentityDocumentTestOne() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //500
    ContentVersion cv = makeContentVersion();
    cv = fileService.getInstance().fetchContentVersionById(cv.id, true);
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse response = IdentityController.scanIdentityDocument(request);
    system.assertEquals(500, response.status, 'success');

    //200
    request.setHeader(new Map<String, Object>{ 'frontImageDocumentId' => cv.ContentDocumentId });
    Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('idScanAnalyzer', '200'));
    Test.startTest();
    response = IdentityController.scanIdentityDocument(request);
    Test.stopTest();
  }
  @isTest
  static void IdentityVerifyTestOne() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, String>{ 'applicantId' => applicant.Id, 'apiName' => 'SentiLink' });
    Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('SentiLinkProvider', '200'));
    Test.startTest();
    ApexResponse response = IdentityController.identityVerify(request);
    Test.stopTest();

    request.token = 'Invalid token';
    response = IdentityController.identityVerify(request);
    system.assertEquals(500, response.status, 'success');
  }

  @isTest
  static void scanIdentityDocumentTestTwo() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    ContentVersion cv = makeContentVersion();

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(
      new Map<String, Object>{ 'contentDocumentId' => cv.ContentDocumentId, 'applicantId' => applicant.Id }
    );
    Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('idScanAnalyzer', '200'));
    Test.startTest();
    ApexResponse response = IdentityController.scanIdentityDocument(request);
    IdentityController.generateUrlForIdentityUpload(request);
    Test.stopTest();

    request.token = 'Invalid token';
    response = IdentityController.scanIdentityDocument(request);
    system.assertEquals(500, response.status, 'success');
  }
  @isTest
  static void customerDueDiligenceTestOne() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    ContentVersion cv = makeContentVersion();

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, Object>{ 'applicantId' => applicant.Id });
    ApexResponse response = new ApexResponse();
    Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('DueDiligence', '200'));
    Test.startTest();
    response = IdentityController.customerDueDiligence(request);
    request.setData(
      '[{"questionType":1,"answer":"3750 TAYLOR BV","answerCode":3},{"questionType":2,"answer":"502","answerCode":3},{"questionType":3,"answer":"Hendricks","answerCode":3},{"questionType":4,"answer":"40202","answerCode":3},{"questionType":5,"answer":"West Virginia","answerCode":3}]'
    );
    IdentityController.validateCustomerAnswers(request);
    Test.stopTest();
  }
  @isTest
  static void customerDueDiligenceTestTwo() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    ContentVersion cv = makeContentVersion();

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, Object>{ 'applicantId' => applicant.Id });
    ApexResponse response = new ApexResponse();
    Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('DueDiligenceFail', '400'));
    Test.startTest();
    response = IdentityController.customerDueDiligence(request);
    Test.stopTest();

    request.token = 'Invalid token';
    response = IdentityController.customerDueDiligence(request);
    system.assertEquals(500, response.status, 'success');
  }
  @isTest
  static void customerDueDiligenceTestThree() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    ContentVersion cv = makeContentVersion();

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, Object>{ 'applicantId' => applicant.Id });
    ApexResponse response = new ApexResponse();
    Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('DueDiligenceNullResponse', '200'));
    Test.startTest();
    response = IdentityController.customerDueDiligence(request);
    Test.stopTest();
  }
  @isTest
  static void validateCustomerAnswersOne() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    ContentVersion cv = makeContentVersion();

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, Object>{ 'applicantId' => '' });
    ApexResponse response = new ApexResponse();
    response = IdentityController.validateCustomerAnswers(request);
    system.assertEquals(500, response.status, 'success');
  }
  @isTest
  static void validateCustomerAnswersTwo() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    ContentVersion cv = makeContentVersion();

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, Object>{ 'applicantId' => applicant.Id });
    ApexResponse response = IdentityController.validateCustomerAnswers(request);
    system.assertEquals(500, response.status, 'success');
  }
  @isTest
  static void verifyCountyUsingGoogleApi() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    Map<String, Object> params = new Map<String, Object>{ 'zipcode' => '98013' };
    Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('verifyCountyUsingGoogleApi', '200'));
    Test.startTest();
    IdentityService.getInstance().verifyCountyUsingGoogleApi(params);
    Test.stopTest();
  }

  // @isTest
  // static void IdentityVerifyTestOne() {
  //   makeApplicationConfiguration();
  //   Applicant__c applicant = makeApplicantData();
  //   makeContactPointAddress(applicant.Id);
  //   ApexRequest request = new ApexRequest();
  //   request.applicationId = applicant.Application__c; //Application__c ID
  //   request.setHeader(new Map<String, String>{ 'applicantId' => applicant.Id, 'apiName' => 'SentiLink' });
  //   Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('SentiLinkProvider', '200'));
  //   Test.startTest();
  //   ApexResponse response = IdentityController.identityVerify(request);
  //   Test.stopTest();
  // }
  // @isTest
  // static void IdentityVerifyTestTwo() {
  //   makeApplicationConfiguration();
  //   Applicant__c applicant = makeApplicantData();
  //   makeContactPointAddress(applicant.Id);
  //   ApexRequest request = new ApexRequest();
  //   request.applicationId = applicant.Application__c; //Application__c ID
  //   request.setHeader(new Map<String, String>{ 'applicantId' => applicant.Id, 'apiName' => 'SentiLinkIdCompletion' });
  //   Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('SentiLinkProvider', '400'));
  //   Test.startTest();
  //   ApexResponse response = IdentityController.identityVerify(request);
  //   Test.stopTest();
  // }
  // @isTest
  // static void IdentityVerifyTestThree() {
  //   makeApplicationConfiguration();
  //   Applicant__c applicant = makeApplicantData();
  //   makeContactPointAddress(applicant.Id);
  //   ApexRequest request = new ApexRequest();
  //   request.applicationId = applicant.Application__c; //Application__c ID
  //   request.setHeader(new Map<String, String>{ 'applicantId' => applicant.Id, 'apiName' => 'SentiLinkkk' });
  //   Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('SentiLinkProvider', '400'));
  //   Test.startTest();
  //   ApexResponse response = IdentityController.identityVerify(request);
  //   Test.stopTest();
  // }

  //---------------------------------------------customerDueDiligenceTest-----------------------------------
  // @isTest
  // static void customerDueDiligenceTestOne() {
  //   makeApplicationConfiguration();
  //   ContentVersion cv = makeContentVersion();
  //   Applicant__c applicant = makeApplicantData();
  //   ApexRequest request = new ApexRequest();
  //   request.applicantId = applicant.Id;
  //   request.applicationId = applicant.Application__c; //Application__c ID
  //   request.setHeader(new Map<String, Object>{ 'applicantId' => applicant.Id });
  //   ApexResponse response = new ApexResponse();
  //   Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('DueDiligence', '200'));
  //   Test.startTest();
  //   response = IdentityController.customerDueDiligence(request);
  //   request.setData(response.data);
  //   IdentityController.validateCustomerAnswers(request);
  //   Test.stopTest();
  // }
  // @isTest
  // static void customerDueDiligenceTestTwo() {
  //   makeApplicationConfiguration();
  //   ContentVersion cv = makeContentVersion();
  //   Applicant__c applicant = makeApplicantData();
  //   ApexRequest request = new ApexRequest();
  //   request.applicantId = applicant.Id;
  //   request.applicationId = applicant.Application__c; //Application__c ID
  //   request.setHeader(new Map<String, Object>{ 'applicantId' => applicant.Id });
  //   ApexResponse response = new ApexResponse();
  //   Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('DueDiligenceFail', '400'));
  //   Test.startTest();
  //   response = IdentityController.customerDueDiligence(request);
  //   Test.stopTest();
  // }
  // @isTest
  // static void customerDueDiligenceTestThree() {
  //   makeApplicationConfiguration();
  //   ContentVersion cv = makeContentVersion();
  //   Applicant__c applicant = makeApplicantData();
  //   ApexRequest request = new ApexRequest();
  //   request.applicantId = applicant.Id;
  //   request.applicationId = applicant.Application__c; //Application__c ID
  //   request.setHeader(new Map<String, Object>{ 'applicantId' => applicant.Id });
  //   ApexResponse response = new ApexResponse();
  //   Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('DueDiligenceNullResponse', '200'));
  //   Test.startTest();
  //   response = IdentityController.customerDueDiligence(request);
  //   Test.stopTest();
  // }
  // @isTest
  // static void validateCustomerAnswersOne() {
  //   makeApplicationConfiguration();
  //   Applicant__c applicant = makeApplicantData();
  //   ApexRequest request = new ApexRequest();
  //   request.applicantId = applicant.Id; //Application__c ID
  //   request.setHeader(new Map<String, Object>{ 'applicantId' => '' });
  //   ApexResponse response = new ApexResponse();
  //   response = IdentityController.validateCustomerAnswers(request);
  //   system.assertEquals(500, response.status, 'success');
  // }
  // @isTest
  // static void validateCustomerAnswersTwo() {
  //   makeApplicationConfiguration();
  //   Applicant__c applicant = makeApplicantData();
  //   ApexRequest request = new ApexRequest();
  //   request.applicantId = applicant.Id; //Application__c ID
  //   request.applicationId = applicant.Application__c;
  //   request.setHeader(new Map<String, Object>{ 'applicantId' => applicant.Id });
  //   ApexResponse response = IdentityController.validateCustomerAnswers(request);
  //   system.assertEquals(500, response.status, 'success');
  // }
}
