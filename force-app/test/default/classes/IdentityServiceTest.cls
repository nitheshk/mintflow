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
  static void scanIdentityDocumentTestOne() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    ContentVersion cv = makeContentVersion();
    cv = fileService.getInstance().fetchContentVersionById(cv.id, true);
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, Object>{ 'frontImageDocumentId' => cv.ContentDocumentId });
    Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('idScanAnalyzer', '200'));
    Test.startTest();
    ApexResponse response = IdentityController.scanIdentityDocument(request);
    Test.stopTest();
  }

  // private static Application__c makeAccountData() {
  //   Application__c acc = TestData.createApplication();
  //   acc = (Application__c) DatabaseUtils.insertRecord(acc);
  //   return acc;
  // }
  // private static EligibleCounty__c makeCountyData() {
  //   EligibleCounty__c county = TestData.createCounty();
  //   county = (EligibleCounty__c) DatabaseUtils.insertRecord(county);
  //   return county;
  // }
  // private static ContactPointAddress makeContactPointAddress(Id applicantId) {
  //   ContactPointAddress address = TestData.createContactPointAddress(null);
  //   address.Applicant__c = applicantId;
  //   address = (ContactPointAddress) DatabaseUtils.insertRecord(address);
  //   return address;
  // }

  // public static ContentVersion makeContentVersion() {
  //   ContentVersion cv = TestData.createContentVersion();
  //   cv = (ContentVersion) DatabaseUtils.insertRecord(cv);
  //   return cv;
  // }
  // private static Applicant__c makeApplicantData() {
  //   Application__c acc = TestData.createApplication();
  //   acc = (Application__c) DatabaseUtils.insertRecords(new List<Application__c>{ acc })[0];
  //   Applicant__c applicant = TestData.createApplicant(acc.Id);
  //   applicant.Email__c = 'test@mail.com';
  //   applicant.SSN__c = '986584759';
  //   applicant.Phone__c = '7894661236';
  //   applicant.Birthdate__c = date.valueOf('1990-11-01');
  //   applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

  //   IdentificationDocument__c identity = TestData.createIdentity(null);
  //   identity.Applicant__c = applicant.Id;
  //   identity = (IdentificationDocument__c) DatabaseUtils.insertRecord(identity);
  //   applicant.mflow__IdentificationDocuments__r.addAll(new List<IdentificationDocument__c>{ identity });

  //   Employment__c employment = TestData.createEmployment(null);
  //   employment.Applicant__c = applicant.Id;
  //   employment = (Employment__c) DatabaseUtils.insertRecord(employment);
  //   applicant.mflow__Employments__r.addAll(new List<Employment__c>{ employment });

  //   ContactPointAddress address = TestData.createContactPointAddress(null);
  //   address.Applicant__c = applicant.Id;
  //   address = (ContactPointAddress) DatabaseUtils.insertRecord(address);
  //   applicant.mflow__ContactPointAddresses__r.addAll(new List<ContactPointAddress>{ address });
  //   return applicant;
  // }
  // private static ApplicationConfiguration__c makeApplicationConfiguration() {
  //   ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
  //   appConfig = (ApplicationConfiguration__c) DatabaseUtils.insertRecord(appConfig);
  //   return appConfig;
  // }

  //------------------------------TEST METHOD--------------------------------------------
  // @isTest
  // static void verifyCountyTestOne() {
  //   makeCountyData();
  //   Application__c acc = makeAccountData();
  //   ApexRequest request = new ApexRequest();
  //   request.applicationId = acc.Id;
  //   request.setHeader(new Map<String, String>{ 'zipcode' => '10001' });
  //   Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('GeocodingProvider', '200'));
  //   Test.startTest();
  //   ApexResponse response = IdentityController.verifyCounty(request);
  //   Test.stopTest();
  //   System.assertEquals(200, response.status, 'success');
  // }
  // @isTest
  // static void verifyCountyTestTwo() {
  //   Application__c acc = makeAccountData();
  //   ApexRequest request = new ApexRequest();
  //   request.applicationId = acc.Id;
  //   Test.startTest();
  //   try {
  //     ApexResponse response1 = IdentityController.verifyCounty(request);
  //     IdScanProvider.getInstance();
  //   } catch (Exception e) {
  //     System.assertEquals(null, null);
  //   }
  //   Test.stopTest();
  // }

  // //-----------------------------------------------------------------------------
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

  // //-----------------------------------------------------------------------
  // @isTest
  // static void scanIdentityDocumentTestOne() {
  //   ContentVersion cv = makeContentVersion();
  //   cv = fileService.getInstance().fetchContentVersionById(cv.id, true);
  //   Applicant__c applicant = makeApplicantData();
  //   ApexRequest request = new ApexRequest();
  //   request.applicationId = applicant.Application__c; //Application__c ID
  //   request.setHeader(new Map<String, Object>{ 'frontImageDocumentId' => cv.ContentDocumentId });
  //   Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('idScanAnalyzer', '200'));
  //   Test.startTest();
  //   ApexResponse response = IdentityController.scanIdentityDocument(request);
  //   Test.stopTest();
  // }
  // @isTest
  // static void scanIdentityDocumentTestTwo() {
  //   makeApplicationConfiguration();
  //   ContentVersion cv = makeContentVersion();
  //   Applicant__c applicant = makeApplicantData();
  //   ApexRequest request = new ApexRequest();
  //   request.applicantId = applicant.Id;
  //   request.applicationId = applicant.Application__c; //Application__c ID
  //   request.setHeader(
  //     new Map<String, Object>{ 'contentDocumentId' => cv.ContentDocumentId, 'applicantId' => applicant.Id }
  //   );
  //   Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('idScanAnalyzer', '200'));
  //   Test.startTest();
  //   ApexResponse response = IdentityController.scanIdentityDocument(request);
  //   IdentityController.generateUrlForIdentityUpload(request);
  //   Test.stopTest();
  //   System.assertEquals(null, null, 'msg');
  // }
  // //---------------------------------------------customerDueDiligenceTest-----------------------------------
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
  // @isTest
  // static void verifyCountyUsingGoogleApi() {
  //   makeApplicationConfiguration();
  //   Map<String, Object> params = new Map<String, Object>{ 'zipcode' => '98013' };
  //   Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('verifyCountyUsingGoogleApi', '200'));
  //   Test.startTest();
  //   IdentityService.getInstance().verifyCountyUsingGoogleApi(params);
  //   Test.stopTest();
  //   System.assertEquals(null, null, 'msg');
  // }
  // @isTest
  // static void identityControllerTest() {
  //   Test.startTest();
  //   IdentityController.identityVerify(new ApexRequest());
  //   IdentityController.verifyCounty(new ApexRequest());
  //   IdentityController.scanIdentityDocument(new ApexRequest());
  //   Test.stopTest();
  //   System.assertEquals(null, null, 'msg');
  // }
}
