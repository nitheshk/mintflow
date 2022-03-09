@istest
public with sharing class SecurityUtilsTest {
  private static Application__c makeAccountData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  private static ApplicationConfiguration__c makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    appConfig = (ApplicationConfiguration__c) DatabaseUtils.insertRecord(
      appConfig
    );
    return appConfig;
  }
  private static Application__c makeApplicationData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);

    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant.SessionToken__c = 'token';
    Id recType = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName()
      .get('Primary')
      .getRecordTypeId();
    applicant.RecordTypeId = recType;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    acc.Applicants__r.addAll(new List<Applicant__c>{ applicant });
    return acc;
  }
  private static Applicant__c makeApplicantData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecords(
      new List<Application__c>{ acc }
    )[0];
    Applicant__c applicant = TestData.createApplicant(acc.Id);
    applicant.Email__c = 'test@mail.com';
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }
  @istest
  static void SecurityUtilsTesttOne() {
    Application__c acc = TestData.createApplication();
    Applicant__c applicant = makeApplicantData();
    test.startTest();
    SecurityUtils.crud(acc, CrudType.CREATABLE);
    SecurityUtils.crud(acc, CrudType.READABLE);
    SecurityUtils.crud(acc, CrudType.UPDATABLE);
    SecurityUtils.crud(acc, CrudType.UPSERTABLE);
    SecurityUtils.crud(acc, CrudType.DELETEABLE);
    SecurityUtils.decryptUrl(SecurityUtils.encryptUrl('encrypt'));
    SecurityUtils.encryptBase64('encryptBase64');
    SecurityUtils.generateUUID();
    SecurityUtils.createSessionForApplicant(applicant);
    SecurityUtils.validateSession();
    test.stopTest();
  }
  @istest
  static void testMethodTwo() {
    makeApplicationConfiguration();
    test.startTest();
    try {
      Application__c acc = makeApplicationData();
      ApexRequest request = new ApexRequest();
      request.token = SecurityUtils.generateTokenForTesting(
        acc.Id,
        '',
        'Primary',
        'ApplicationFlow'
      );
      SecurityUtils.createSessionForApplicant(acc.Applicants__r[0]);
      SecurityUtils.validateSession();
      SecurityUtils.decryptBase64('decryptBase64');
    } catch (Exception e) {
    }
    test.stopTest();
  }
  @istest
  static void testMethodThree() {
    test.startTest();
    try {
    } catch (Exception e) {
    }

    test.stopTest();
  }
}
