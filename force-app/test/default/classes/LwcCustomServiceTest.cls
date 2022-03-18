@istest
public with sharing class LwcCustomServiceTest {
  private static Application__c makeApplicationData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);

    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    IdentificationDocument__c identity = TestData.createIdentity();
    identity.Applicant__c = applicant.Id;
    identity = (IdentificationDocument__c) DatabaseUtils.insertRecord(identity);
    applicant.mflow__IdentificationDocuments__r.addAll(new List<IdentificationDocument__c>{ identity });
    acc.Applicants__r.addAll(new List<Applicant__c>{ applicant });
    return acc;
  }
  private static ApplicationConfiguration__c makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    appConfig = (ApplicationConfiguration__c) DatabaseUtils.insertRecord(appConfig);
    return appConfig;
  }
  @istest
  private static void readFlowsTest() {
    makeApplicationConfiguration();
    Application__c acc = TestData.createApplication();
    Map<String, String> params = new Map<String, String>();
    params.put('configData', 'configData');
    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantIds' => acc.applicants__r });
    request.setData(new List<Id>{ acc.Id });
    test.startTest();
    LwcCustomController.readFlows(params);
    params.put('recordId', acc.Id);
    params.put('objectApiName', 'mflow__Applicant__c');
    params.put('status', 'Passed');
    params.put('approvalType', 'approvalType');
    // params.put(arg0, arg1);
    LwcCustomController.readFlows(params);
    LwcCustomController.fetchConfigValues();
    LwcCustomController.updateConfigValues(params);
    LwcCustomController.readApplicationWithChild(acc.Id);
    LwcCustomController.readApplicationWithApplicants(acc.Id);
    LwcCustomController.readApplicationForResume(acc.Id);
    LwcCustomController.sendResumeApplicationEmail(request);
    LwcCustomController.resendFundingRequest(request);
    LwcCustomController.fetchFieldDetails(params);
    LwcCustomController.fetchFieldDetails(params);
    LwcCustomController.updateKycDecision(params);

    test.stopTest();
  }
  @istest
  private static void readFlowsTestTwo() {
    Application__c acc = TestData.createApplication();
    Map<String, Object> params = new Map<String, Object>();
    params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
    params.put('sObjectName', 'Account');
    params.put('fieldSetName', 'fieldSetName');
    makeApplicationConfiguration();
    test.startTest();
    try {
      LwcCustomController.resubmitTheApplication(acc.Id);
      LwcCustomController.fetchPickListValues(params);
    } catch (Exception e) {
    }
    test.stopTest();
  }
  @istest
  private static void readFlowsTestThree() {
    Application__c acc = TestData.createApplication();
    Map<String, Object> params = new Map<String, Object>();
    params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
    params.put('sObjectName', 'Account');
    params.put('fieldSetName', 'fieldSetName');
    makeApplicationConfiguration();
    test.startTest();
    try {
      LwcCustomController.fetchRelatedFiles(JSON.serialize(new List<String>{ acc.Id }));
    } catch (Exception e) {
    }
    test.stopTest();
  }
  @istest
  private static void readFlowsTestFive() {
    Application__c acc = TestData.createApplication();
    Map<String, Object> params = new Map<String, Object>();
    params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
    params.put('sObjectName', 'Account');
    params.put('fieldSetName', 'fieldSetName');
    makeApplicationConfiguration();
    test.startTest();
    try {
      LwcCustomController.authorizeCustomer(params);
    } catch (Exception e) {
    }
    test.stopTest();
  }
  @istest
  private static void readFlowsTestFour() {
    Application__c acc = TestData.createApplication();
    Map<String, Object> params = new Map<String, Object>();
    params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
    params.put('sObjectName', 'Account');
    params.put('fieldSetName', 'fieldSetName');
    makeApplicationConfiguration();
    test.startTest();
    try {
      LwcCustomController.fetchOOWReportData(acc.Id);
    } catch (Exception e) {
    }
    test.stopTest();
  }
  @istest
  private static void readFlowsTestSix() {
    Application__c acc = TestData.createApplication();
    Map<String, string> params = new Map<String, string>();
    params.put('sObjectName', 'Account');
    params.put('fieldSetName', 'fieldSetName');
    makeApplicationConfiguration();
    test.startTest();
    try {
      LwcCustomController.fetchFieldDetails(params);
    } catch (Exception e) {
    }
    test.stopTest();
  }
  @istest
  private static void readFlowsTestSeven() {
    Application__c acc = TestData.createApplication();
    acc = TestData.readApplicationWithChild(acc.Id);
    Map<String, string> params = new Map<String, string>();
    params.put('sObjectName', 'Account');
    params.put('fieldSetName', 'fieldSetName');
    makeApplicationConfiguration();
    test.startTest();
    try {
      LwcCustomController.fetchFieldDetails(params);
    } catch (Exception e) {
    }
    test.stopTest();
  }
}
