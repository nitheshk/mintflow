@istest
public with sharing class SecurityUtilsTest {
  private static Account makeAccountData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  private static Applicant__c makeApplicantData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecords(new List<Account>{ acc })[0];
    Applicant__c applicant = TestData.createApplicant(acc.Id);
    applicant.Email__c = 'test@mail.com';
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }
  @istest
  static void SecurityUtilsTesttOne() {
    Account acc = TestData.createAccount();
    Applicant__c applicant = makeApplicantData();
    test.startTest();
    SecurityUtils.crud(acc, CrudType.CREATABLE);
    SecurityUtils.crud(acc, CrudType.READABLE);
    SecurityUtils.crud(acc, CrudType.UPDATABLE);
    SecurityUtils.crud(acc, CrudType.UPSERTABLE);
    SecurityUtils.crud(acc, CrudType.DELETEABLE);
    SecurityUtils.decryptUrl('decryptUrl');
    SecurityUtils.encryptBase64('encryptBase64');
    SecurityUtils.decryptBase64('decryptBase64');
    SecurityUtils.generateUUID();
    SecurityUtils.createSessionForApplication(acc);
    SecurityUtils.createSessionForApplicant(applicant);
    SecurityUtils.validateSession();
    test.stopTest();
  }
}
