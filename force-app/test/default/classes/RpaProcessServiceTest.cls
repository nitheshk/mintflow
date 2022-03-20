@istest
public with sharing class RpaProcessServiceTest {
  private static ApplicationConfiguration__c makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    appConfig = (ApplicationConfiguration__c) DatabaseUtils.insertRecord(appConfig);
    return appConfig;
  }
  private static Application__c makeApplicationData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);

    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    IdentificationDocument__c identity = TestData.createIdentity(null);
    identity.Applicant__c = applicant.Id;
    identity = (IdentificationDocument__c) DatabaseUtils.insertRecord(identity);
    applicant.mflow__IdentificationDocuments__r.addAll(new List<IdentificationDocument__c>{ identity });
    acc.Applicants__r.addAll(new List<Applicant__c>{ applicant });
    return acc;
  }
  @istest
  private static void scheduleApplicationTest() {
    Application__c application = makeApplicationData();
    makeApplicationConfiguration();
    ApexRequest request = new ApexRequest();
    RestRequest req = new RestRequest();
    req.requestURI = 'services/apexrest/mflow/rpa/v1/obtainreviewapplicationdata/?applicationName=App-00014';
    request.setHeader(new Map<String, object>{ 'url' => 'url', 'ch' => 'Virtual' });
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicantType('Primary');
    request.setData(application);
    Test.setMock(HttpCalloutMock.class, new RpaServiceMock('updatememberdetails', '200'));
    // Test.setMock(HttpCalloutMock.class, new IdentityServiceMock('OAuthProvider', '200'));
    Test.startTest();
    try {
      RpaProcessService.getInstance().scheduleApplication(application);
      RpaProcessService.getInstance().obtainReviewApplicationData();
    } catch (Exception e) {
    }
    Test.stopTest();
  }
  @istest
  private static void scheduleApplicationTwo() {
    Test.startTest();
    try {
      RpaProcessService.getInstance().obtainApplicationFiles();
    } catch (Exception e) {
    }
    test.stopTest();
  }
  @istest
  private static void scheduleApplicationThree() {
    Test.startTest();
    try {
      RpaProcessService.getInstance().updateFundingDetails();
    } catch (Exception e) {
    }
    test.stopTest();
  }
  @istest
  private static void scheduleApplicationFour() {
    Test.startTest();
    try {
      RpaProcessService.getInstance().obtainFundingData();
    } catch (Exception e) {
    }
    test.stopTest();
  }
  @istest
  private static void scheduleApplicationFive() {
    Test.startTest();
    try {
      RpaProcessService.getInstance().updateMemberDetails();
    } catch (Exception e) {
    }
    test.stopTest();
  }
  @istest
  private static void scheduleApplicationSix() {
    Test.startTest();
    try {
      RpaProcessService rp = new RpaProcessService();
      RpaProcessService.doPost();
      RpaProcessService.doGet();
    } catch (Exception e) {
    }
    test.stopTest();
  }
}
