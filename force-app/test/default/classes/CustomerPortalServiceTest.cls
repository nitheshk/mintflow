@Istest
public with sharing class CustomerPortalServiceTest {
  private static Applicant__c makeApplicantData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecords(new List<Account>{ acc })[0];
    Applicant__c applicant = TestData.createApplicant(acc.Id);
    applicant.Email__c = 'test@mail.com';
    applicant.mflow__SSN__c = '323543454';
    applicant.mflow__Email__c = 'test@email.com';
    applicant.mflow__LastName__c = 'LastName';
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }
  @IsTest
  private static void testAuthorize() {
    Applicant__c applicant = makeApplicantData();
    map<string, object> params = new Map<string, object>();
    params.put('applicant', applicant);
    Test.startTest();
    CustomerPortalService.getInstance().authorize(params);
    Test.stopTest();
  }
}
