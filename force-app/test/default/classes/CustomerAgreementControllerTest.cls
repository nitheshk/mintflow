@IsTest
public with sharing class CustomerAgreementControllerTest {
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
    applicant.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
      Applicant__c.SObjectType,
      'Primary'
    );
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }
  @IsTest
  private static void testVfPage() {
    account app = makeAccountData();
    Applicant__c applicant = makeApplicantData();
    PageReference customerAgreementPage = Page.CustomerAgreement;
    Test.setCurrentPage(customerAgreementPage);
    // Put Id into the current page Parameters
    ApexPages.currentPage().getParameters().put('id', applicant.Application__c);
    ApexPages.StandardController sc = new ApexPages.StandardController(app);
    Test.startTest();
    CustomerAgreementController cc = new CustomerAgreementController();
    Test.stopTest();
  }
}
