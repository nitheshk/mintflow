@istest
public with sharing class SecurityUtilsTest {
  private static Application__c makeAccountData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);
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
    SecurityUtils.decryptBase64('decryptBase64');
    SecurityUtils.generateUUID();
    SecurityUtils.createSessionForApplicant(applicant);
    SecurityUtils.validateSession();
    test.stopTest();
  }
}
