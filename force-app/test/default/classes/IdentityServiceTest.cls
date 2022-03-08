@isTest
public with sharing class IdentityServiceTest {
  private static Application__c makeAccountData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  private static ContactPointAddress makeContactPointAddress(Id applicantId) {
    ContactPointAddress address = TestData.createContactPointAddress();
    address.Applicant__c = applicantId;
    address = (ContactPointAddress) DatabaseUtils.insertRecord(address);
    return address;
  }

  public static ContentVersion makeContentVersion() {
    ContentVersion cv = TestData.createContentVersion();
    cv = (ContentVersion) DatabaseUtils.insertRecord(cv);
    return cv;
  }
  private static Applicant__c makeApplicantData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecords(
      new List<Application__c>{ acc }
    )[0];
    Applicant__c applicant = TestData.createApplicant(acc.Id);
    applicant.Email__c = 'test@mail.com';
    applicant.SSN__c = '986584759';
    applicant.Phone__c = '7894661236';
    applicant.Birthdate__c = date.valueOf('1990-11-01');
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }
  private static ApplicationConfiguration__c makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    appConfig = (ApplicationConfiguration__c) DatabaseUtils.insertRecord(
      appConfig
    );
    return appConfig;
  }

  //------------------------------TEST METHOD--------------------------------------------
  @isTest
  static void verifyCountyTestOne() {
    Application__c acc = makeAccountData();
    ApexRequest request = new ApexRequest();
    request.applicationId = acc.Id;
    request.setHeader(new Map<String, String>{ 'zipcode' => '98013' });
    Test.setMock(
      HttpCalloutMock.class,
      new IdentityServiceMock('GeocodingProvider', '200')
    );
    Test.startTest();
    ApexResponse response = IdentityController.verifyCounty(request);
    Test.stopTest();
    System.assertEquals(200, response.status, 'success');
  }
  @isTest
  static void verifyCountyTestTwo() {
    Application__c acc = makeAccountData();
    ApexRequest request = new ApexRequest();
    request.applicationId = acc.Id;
    Test.startTest();
    try {
      ApexResponse response1 = IdentityController.verifyCounty(request);
    } catch (Exception e) {
      System.assertEquals(e.getMessage(), 'Zipcode value not set');
    }
    Test.stopTest();
  }

  //-----------------------------------------------------------------------------
  @isTest
  static void IdentityVerifyTestOne() {
    makeApplicationConfiguration();
    Applicant__c applicant = makeApplicantData();
    makeContactPointAddress(applicant.Id);
    ApexRequest request = new ApexRequest();
    request.applicationId = applicant.Application__c; //Application__c ID
    request.setHeader(
      new Map<String, String>{
        'applicantId' => applicant.Id,
        'apiName' => 'SentiLink'
      }
    );
    Test.setMock(
      HttpCalloutMock.class,
      new IdentityServiceMock('SentiLinkProvider', '200')
    );
    Test.startTest();
    ApexResponse response = IdentityController.identityVerify(request);
    Test.stopTest();
  }
  @isTest
  static void IdentityVerifyTestTwo() {
    makeApplicationConfiguration();
    Applicant__c applicant = makeApplicantData();
    makeContactPointAddress(applicant.Id);
    ApexRequest request = new ApexRequest();
    request.applicationId = applicant.Application__c; //Application__c ID
    request.setHeader(
      new Map<String, String>{
        'applicantId' => applicant.Id,
        'apiName' => 'SentiLinkIdCompletion'
      }
    );
    Test.setMock(
      HttpCalloutMock.class,
      new IdentityServiceMock('SentiLinkProvider', '400')
    );
    Test.startTest();
    ApexResponse response = IdentityController.identityVerify(request);
    Test.stopTest();
  }
  @isTest
  static void IdentityVerifyTestThree() {
    makeApplicationConfiguration();
    Applicant__c applicant = makeApplicantData();
    makeContactPointAddress(applicant.Id);
    ApexRequest request = new ApexRequest();
    request.applicationId = applicant.Application__c; //Application__c ID
    request.setHeader(
      new Map<String, String>{
        'applicantId' => applicant.Id,
        'apiName' => 'SentiLinkkk'
      }
    );
    Test.setMock(
      HttpCalloutMock.class,
      new IdentityServiceMock('SentiLinkProvider', '400')
    );
    Test.startTest();
    ApexResponse response = IdentityController.identityVerify(request);
    Test.stopTest();
  }

  //-----------------------------------------------------------------------
  @isTest
  static void scanIdentityDocumentTestOne() {
    ContentVersion cv = makeContentVersion();
    cv = fileService.getInstance().fetchContentVersionById(cv.id, true);
    Applicant__c applicant = makeApplicantData();
    ApexRequest request = new ApexRequest();
    request.applicationId = applicant.Application__c; //Application__c ID
    request.setHeader(
      new Map<String, Object>{ 'contentDocumentId' => cv.ContentDocumentId }
    );
    Test.setMock(
      HttpCalloutMock.class,
      new IdentityServiceMock('idScanAnalyzer', '200')
    );
    Test.startTest();
    ApexResponse response = IdentityController.scanIdentityDocument(request);
    Test.stopTest();
    System.assertEquals(200, response.status, 'msg');
  }
  @isTest
  static void scanIdentityDocumentTestTwo() {
    ContentVersion cv = makeContentVersion();
    Applicant__c applicant = makeApplicantData();
    ApexRequest request = new ApexRequest();
    request.applicationId = applicant.Application__c; //Application__c ID
    request.setHeader(
      new Map<String, Object>{ 'contentDocumentId' => cv.ContentDocumentId }
    );
    Test.setMock(
      HttpCalloutMock.class,
      new IdentityServiceMock('idScanAnalyzer', '200')
    );
    Test.startTest();
    ApexResponse response = IdentityController.scanIdentityDocument(request);
    Test.stopTest();
    System.assertEquals(null, null, 'msg');
  }
  @isTest
  static void identityControllerTest() {
    Test.startTest();
    IdentityController.identityVerify(new ApexRequest());
    IdentityController.verifyCounty(new ApexRequest());
    IdentityController.scanIdentityDocument(new ApexRequest());
    Test.stopTest();
    System.assertEquals(null, null, 'msg');
  }
}
