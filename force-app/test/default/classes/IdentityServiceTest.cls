@isTest
public with sharing class IdentityServiceTest {
  private static Account makeAccountData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  private static ContactPointAddress makeContactPointAddress(Id applicantId) {
    ContactPointAddress address = TestData.createContactPointAddress();
    address.Applicant__c = applicantId;
    address = (ContactPointAddress) DatabaseUtils.insertRecord(address);
    return address;
  }
  private static Applicant__c makeApplicantData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecords(new List<Account>{ acc })[0];
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
  @isTest
  static void verifyCountyTestOne() {
    Account acc = makeAccountData();
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
    Account acc = makeAccountData();
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
  @isTest
  static void IdentityVerifyTestOne() {
    makeApplicationConfiguration();
    Applicant__c applicant = makeApplicantData();
    makeContactPointAddress(applicant.Id);
    ApexRequest request = new ApexRequest();
    request.applicationId = applicant.Application__c; //account ID
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
    request.applicationId = applicant.Application__c; //account ID
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
}
