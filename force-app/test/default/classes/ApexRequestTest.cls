@istest
public with sharing class ApexRequestTest {
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
  static void apexRequestTestOne() {
    Application__c acc = makeAccountData();
    Applicant__c applicant = makeApplicantData();
    ApexRequest request = new ApexRequest();
    test.startTest();
    request.setData(acc);
    request.setHeader('header');
    request.setData('Data');
    request.setHeader(new Map<String, Object>{ 'Application__c' => acc });
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
    ApexRequest.getParams('Application__c');
    ApexRequest.getApplicationName();
    ApexRequest.getApplicantId();
    ApexRequest.getApplicantType();
    ApexRequest.getToken();
    ApexRequest.getFlowType();
    test.stopTest();
    system.assertEquals(acc.Id, appid, 'success');
  }
}
