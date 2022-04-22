@istest
public with sharing class LwcCustomServiceTest {
  //makeApplicationConfiguration
  private static void makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    insert appConfig;
    TestData.createSiteSetting();
    List<FinancialProduct__c> products = TestData.createProduct();
    insert products;
  }
  //createApplicantDataWithChild
  private static Applicant__c createApplicantDataWithChild(Application__c application) {
    Applicant__c applicant = Application.Applicants__r[0];
    SObjectConstructor construct = SObjectConstructor.getInstance(applicant);

    IdentificationDocument__c identity = TestData.createIdentity(applicant.Id);
    insert identity;

    Employment__c employment = TestData.createEmployment(applicant.Id);
    insert employment;

    ContactPointAddress address = TestData.createContactPointAddress(applicant.Id);
    insert address;

    construct.addChildObject('mflow__IdentificationDocuments__r', identity);
    construct.addChildObject('mflow__Employments__r', employment);
    construct.addChildObject('mflow__ContactPointAddresses__r', address);

    return (Applicant__c) construct.build();
  }
  //createApplicantDataWithChild
  private static FinancialAccount__c createFinancialAccountWithChild(Application__c application) {
    FinancialAccount__c finAccount = Application.FinancialAccounts__r[0];
    SObjectConstructor construct = SObjectConstructor.getInstance(finAccount);

    FinancialAccountTransaction__c finTransaction = TestData.createFinancialAccountTransaction(finAccount.Id);
    insert finTransaction;

    construct.addChildObject('FinancialAccountTransactions__r', finTransaction);
    return (FinancialAccount__c) construct.build();
  }
  @istest
  private static void readFlowsTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    Map<String, String> params = new Map<String, String>();

    ApexResponse res = LwcCustomController.readFlows(params);
    system.assertEquals(200, res.status, 'success');

    request = new ApexRequest();
    LwcCustomController.readFlows(params);
  }

  @istest
  private static void fetchConfigValuesTest() {
    makeApplicationConfiguration();
    ApexResponse res = LwcCustomController.fetchConfigValues();
    system.assertEquals(200, res.status, 'success');
  }
  @istest
  private static void updateConfigValuesTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    Map<String, String> params = new Map<String, String>();
    params.put('configData', '{\"mflow__OOWTotalQuestionsToShow__c\":5}');
    ApexResponse res = LwcCustomController.updateConfigValues(params);
  }

  @istest
  private static void readApplicationWithChildTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    ApexResponse res = LwcCustomController.readApplicationWithChild(application.Id);
    System.assertEquals(200, res.status, 'success');
    res = LwcCustomController.readApplicationWithChild(applicant.Id);
    System.assertEquals(400, res.status, 'success');
  }

  @istest
  private static void readApplicationWithApplicantsTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    ApexResponse res = LwcCustomController.readApplicationWithApplicants(application.Id);
    System.assertEquals(200, res.status, 'success');
    res = LwcCustomController.readApplicationWithApplicants('');
    System.assertEquals(400, res.status, 'success');
  }

  @istest
  private static void readApplicationForResumeTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    Map<String, String> params = new Map<String, String>();
    params.put('recordId', applicant.Id);
    ApexResponse res = LwcCustomController.readApplicationForResume(params);
    System.assertEquals(400, res.status, 'success');

    params.put('recordId', application.Id);
    res = LwcCustomController.readApplicationForResume(params);
    System.assertEquals(200, res.status, 'success');
  }

  @istest
  private static void sendResumeApplicationEmailTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setData(JSON.serialize(new List<Id>{ applicant.Id }));
    ApexResponse res = LwcCustomController.sendResumeApplicationEmail(request);
    System.assertEquals(200, res.status, 'success');

    request = new ApexRequest();
    request.token = 'Invalid token';
    res = LwcCustomController.sendResumeApplicationEmail(request);
    System.assertEquals(400, res.status, 'success');
  }

  @istest
  private static void fetchFieldDetailsTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    Map<String, String> params = new Map<String, String>();
    params.put('sObjectName', 'mflow__Applicant__c');
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setData(JSON.serialize(new List<Id>{ applicant.Id }));
    ApexResponse res = LwcCustomController.fetchFieldDetails(params);
    System.assertEquals(200, res.status, 'success');

    params.put('fieldSetName', 'mflow__ContactInformation');
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setData(JSON.serialize(new List<Id>{ applicant.Id }));
    res = LwcCustomController.fetchFieldDetails(params);
    System.assertEquals(200, res.status, 'success');

    request = new ApexRequest();
    request.token = 'Invalid token';
    res = LwcCustomController.fetchFieldDetails(null);
    System.assertEquals(400, res.status, 'success');
  }

  @istest
  private static void fetchPickListValuesTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    Map<String, Object> params = new Map<String, Object>();
    params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setData(JSON.serialize(new List<Id>{ applicant.Id }));
    ApexResponse res = LwcCustomController.fetchPickListValues(params);
    System.assertEquals(400, res.status, 'success');
  }
  @istest
  private static void updateKycDecisionTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    Applicant__c jointApplicant = createApplicantDataWithChild(application);
    jointApplicant.RecordTypeId = SObjectUtils.recordTypeIdByName(
      Applicant__c.SObjectType,
      ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
    );
    upsert jointApplicant;
    //Applicant
    Map<String, Object> params = new Map<String, Object>();
    params.put('recordId', application.mflow__Applicants__r[0].Id);
    params.put('objectApiName', 'mflow__Applicant__c');
    params.put('status', 'Passed');
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setData(JSON.serialize(new List<Id>{ applicant.Id }));
    ApexResponse res = LwcCustomController.updateKycDecision(params);
    System.assertEquals(200, res.status, 'success');

    params.put('status', ApplicationConstant.KYC_FAILED);
    res = LwcCustomController.updateKycDecision(params);
    System.assertEquals(200, res.status, 'success');

    //Application
    params = new Map<String, Object>();
    params.put('recordId', application.Id);
    params.put('objectApiName', 'mflow__Application__c');
    params.put('status', 'Passed');
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setData(JSON.serialize(new List<Id>{ applicant.Id }));
    res = LwcCustomController.updateKycDecision(params);
    System.assertEquals(200, res.status, 'success');

    params.put('status', ApplicationConstant.KYC_FAILED);
    res = LwcCustomController.updateKycDecision(params);
    System.assertEquals(200, res.status, 'success');

    // other object type
    params.put('objectApiName', 'Account');
    res = LwcCustomController.updateKycDecision(params);
    System.assertEquals(400, res.status, 'success');
  }
  @istest
  private static void updateKycDecisionTestTwo() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    applicant.KYCStatus__c = ApplicationConstant.KYC_FAILED;
    upsert applicant;
    // Applicant__c jointApplicant = createApplicantDataWithChild(application);
    // jointApplicant.RecordTypeId = SObjectUtils.recordTypeIdByName(
    //   Applicant__c.SObjectType,
    //   ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
    // );
    // jointApplicant.KYCStatus__c = ApplicationConstant.KYC_FAILED;
    // upsert jointApplicant;

    Map<String, Object> params = new Map<String, Object>();
    ApexRequest request = new ApexRequest();
    params.put('recordId', application.Id);
    params.put('objectApiName', 'mflow__Application__c');
    params.put('status', 'Passed');
    request.token = ApexRequest.getToken();
    request.setData(JSON.serialize(new List<Id>{ application.Id }));
    ApexResponse res = LwcCustomController.updateKycDecision(params);
    System.assertEquals(200, res.status, 'success');

    // params.put('status', ApplicationConstant.KYC_FAILED);
    // res = LwcCustomController.updateKycDecision(params);
    // System.assertEquals(200, res.status, 'success');
  }
  @istest
  private static void fetchRelatedFilesTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    ApexResponse res = LwcCustomController.fetchRelatedFiles(JSON.serialize(new List<String>{ applicant.Id }));
    System.assertEquals(200, res.status, 'success');

    res = LwcCustomController.fetchRelatedFiles('string');
    System.assertEquals(400, res.status, 'success');
  }
  @istest
  private static void resubmitApplicationTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    // FinancialAccount__c finAcc = createFinancialAccountWithChild(application);

    ApexResponse res = LwcCustomController.resubmitApplication(application.Id);
    System.assertEquals(200, res.status, 'success');

    res = LwcCustomController.resubmitApplication(null);
    System.assertEquals(400, res.status, 'success');
  }
  @istest
  private static void fetchOOWReportDataTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    // FinancialAccount__c finAcc = createFinancialAccountWithChild(application);

    ApexRequest request = new ApexRequest();
    ApexResponse res = LwcCustomController.fetchOOWReportData(applicant.Id);
    System.assertEquals(200, res.status, 'success');

    res = LwcCustomController.fetchOOWReportData(applicant.Id);
    System.assertEquals(200, res.status, 'success');
  }
  @istest
  private static void lwcRecordLevelVisibilityTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    // FinancialAccount__c finAcc = createFinancialAccountWithChild(application);

    Map<String, Object> params = new Map<String, Object>();
    params = new Map<String, Object>();
    params.put('recordId', application.Id);
    params.put('objectApiName', 'mflow__Application__c');
    params.put('status', 'Passed');
    ApexRequest request = new ApexRequest();
    ApexResponse res = LwcCustomController.lwcRecordLevelVisibility(params);
    System.assertEquals(200, res.status, 'success');

    params.put('recordId', null);
    params.put('objectApiName', 'Account');
    params.put('status', 'Passed');
    res = LwcCustomController.lwcRecordLevelVisibility(params);
    System.assertEquals(500, res.status, 'success');
  }
  @istest
  private static void authorizeCustomerTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    Map<String, Object> params = new Map<String, Object>();
    ApexResponse res = new ApexResponse();
    //200
    params.put('applicant', applicant);
    res = LwcCustomController.authorizeCustomer(params);
    system.assertEquals(200, res.status, 'success');

    params.remove('applicant');
    res = LwcCustomController.authorizeCustomer(params);
  }
}
