@istest
public with sharing class ApexRequestTest {
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
  static void apexRequestTestOne() {
    Account acc = makeAccountData();
    Applicant__c applicant = makeApplicantData();
    ApexRequest request = new ApexRequest();
    test.startTest();
    request.setData(acc);
    request.setHeader('header');
    request.setData('Data');
    request.setHeader(new Map<String, Object>{ 'Account' => acc });
    ApexRequest.setApplicationName(acc.Name);
    ApexRequest.setApplicantId(applicant.Id);
    ApexRequest.setApplicantType(applicant.ApplicantType__c);
    ApexRequest.setFlowType('GetStarted');
    ApexRequest.setToken('Token');
    request.setRequest();
    ApexRequest.setApplicationId(acc.Id);
    id appid = ApexRequest.getApplicationId();
    ApexRequest.getRequest();
    ApexRequest.getParams();
    ApexRequest.getParams('Account');
    ApexRequest.getApplicationName();
    ApexRequest.getApplicantId();
    ApexRequest.getApplicantType();
    ApexRequest.getToken();
    ApexRequest.getFlowType();
    test.stopTest();
    system.assertEquals(acc.Id, appid, 'success');
  }
}
