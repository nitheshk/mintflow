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
  // request.setHeader(new Map<String, object>{ 'applicantIds' => application.mflow__Applicants__r });
  // request.setData(new List<Id>{ application.Id });
  // params.put('recordId', application.mflow__Applicants__r[0].Id);
  // params.put('objectApiName', 'mflow__Applicant__c');
  // params.put('status', 'Passed');
  // params.put('approvalType', 'approvalType');
  // // params.put(arg0, arg1);
  // LwcCustomController.fetchFieldDetails(params);
  // LwcCustomController.fetchFieldDetails(params);
  // LwcCustomController.updateKycDecision(params);

  // @istest
  // private static void readFlowsTestTwo() {
  //   Application__c acc = TestData.createApplication();
  //   Map<String, Object> params = new Map<String, Object>();
  //   params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
  //   params.put('sObjectName', 'Account');
  //   params.put('fieldSetName', 'fieldSetName');
  //   makeApplicationConfiguration();
  //   test.startTest();
  //   try {
  //     LwcCustomController.resubmitApplication(acc.Id);
  //   } catch (Exception e) {
  //   }
  //   test.stopTest();
  // }
  // @istest
  // private static void readFlowsTestThree() {
  //   Application__c acc = TestData.createApplication();
  //   Map<String, Object> params = new Map<String, Object>();
  //   params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
  //   params.put('sObjectName', 'Account');
  //   params.put('fieldSetName', 'fieldSetName');
  //   makeApplicationConfiguration();
  //   LwcCustomController.fetchRelatedFiles(JSON.serialize(new List<String>{ acc.Id }));
  // }
  // @istest
  // private static void authorizeCustomerTest() {
  //   Application__c acc = makeApplicationData();
  //   acc = TestData.readApplicationWithChild(acc.Id);
  //   Map<String, Object> params = new Map<String, Object>();
  //   makeApplicationConfiguration();
  //   ApexResponse res = new ApexResponse();
  //   //400
  //   params.put('applicant', new Applicant__c());
  //   res = LwcCustomController.authorizeCustomer(params);
  //   system.assertEquals(400, res.status, 'success');
  //   //200
  //   params.put('applicant', acc.mflow__Applicants__r[0]);
  //   res = LwcCustomController.authorizeCustomer(params);
  //   system.assertEquals(200, res.status, 'success');

  //   params.remove('applicant');
  //   res = LwcCustomController.authorizeCustomer(params);
  // }
  // @istest
  // private static void lwcRecordLevelVisibilityTest() {
  //   Application__c acc = makeApplicationData();
  //   acc = TestData.readApplicationWithChild(acc.Id);
  //   Map<String, Object> params = new Map<String, Object>();
  //   makeApplicationConfiguration();
  //   ApexResponse res = new ApexResponse();
  //   //400
  //   params.put('recordId', acc.mflow__Applicants__r[0].Id);
  //   params.put('objectApiName', 'mflow__Applicant__c');
  //   params.put('filter', 'filter');
  //   res = LwcCustomController.lwcRecordLevelVisibility(params);
  //   // system.assertEquals(400, res.status, 'success');
  //   // //200
  //   // params.put('applicant', acc.mflow__Applicants__r[0]);
  //   // res = LwcCustomController.authorizeCustomer(params);
  //   // system.assertEquals(200, res.status, 'success');

  //   // params.remove('applicant');
  //   // res = LwcCustomController.authorizeCustomer(params);
  // }
  // @istest
  // private static void readFlowsTestFour() {
  //   Application__c acc = TestData.createApplication();
  //   Map<String, Object> params = new Map<String, Object>();
  //   params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
  //   params.put('sObjectName', 'Account');
  //   params.put('fieldSetName', 'fieldSetName');
  //   makeApplicationConfiguration();
  //   test.startTest();
  //   try {
  //     LwcCustomController.fetchOOWReportData(acc.Id);
  //   } catch (Exception e) {
  //   }
  //   test.stopTest();
  // }
  // @istest
  // private static void readFlowsTestSix() {
  //   Application__c acc = TestData.createApplication();
  //   Map<String, string> params = new Map<String, string>();
  //   params.put('sObjectName', 'Account');
  //   params.put('fieldSetName', 'fieldSetName');
  //   makeApplicationConfiguration();
  //   test.startTest();
  //   try {
  //     LwcCustomController.fetchFieldDetails(params);
  //   } catch (Exception e) {
  //   }
  //   test.stopTest();
  // }
  // @istest
  // private static void readFlowsTestSeven() {
  //   Application__c acc = TestData.createApplication();
  //   acc = TestData.readApplicationWithChild(acc.Id);
  //   Map<String, string> params = new Map<String, string>();
  //   params.put('sObjectName', 'Account');
  //   params.put('fieldSetName', 'fieldSetName');
  //   makeApplicationConfiguration();
  //   test.startTest();
  //   try {
  //     LwcCustomController.fetchFieldDetails(params);
  //   } catch (Exception e) {
  //   }
  //   test.stopTest();
  // }
  // @istest
  // private static void sendResumeApplicationEmailTest() {
  //   Application__c application = makeApplicationData();
  //   application = TestData.readApplicationWithChild(application.Id);
  //   ApexRequest request = new ApexRequest();
  //   Map<String, object> params = new Map<String, object>();
  //   params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
  //   params.put('sObjectName', 'mflow__Application__c');
  //   params.put('fieldSetName', 'fieldSetName');
  //   request.setHeader(new Map<String, object>{ 'applicantIds' => application.mflow__Applicants__r });
  //   request.setData(new List<Id>{ application.mflow__Applicants__r[0].Id });
  //   makeApplicationConfiguration();

  //   ApexResponse res = LwcCustomController.sendResumeApplicationEmail(request);
  //   //500
  //   request = new ApexRequest();
  //   request.token = 'invalidToken';
  //   res = LwcCustomController.sendResumeApplicationEmail(request);
  //   system.assertEquals(500, res.status, 'success');
  // }
  // @istest
  // private static void TestEleven() {
  //   Application__c application = makeApplicationData();
  //   application = TestData.readApplicationWithChild(application.Id);
  //   ApexRequest request = new ApexRequest();
  //   Map<String, object> params = new Map<String, object>();
  //   params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
  //   params.put('sObjectName', 'mflow__Application__c');
  //   params.put('fieldSetName', 'fieldSetName');
  //   request.setHeader(new Map<String, object>{ 'applicantIds' => application.mflow__Applicants__r });
  //   request.setData(new List<Id>{ application.mflow__Applicants__r[0].Id });
  //   makeApplicationConfiguration();
  //   LwcCustomController.fetchPickListValues(params);
  // }
  // @istest
  // private static void TestNine() {
  //   Application__c application = makeApplicationData();
  //   application = TestData.readApplicationWithChild(application.Id);
  //   ApexRequest request = new ApexRequest();
  //   Map<String, object> params = new Map<String, object>();
  //   params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
  //   params.put('objectApiName', 'mflow__Application__c');
  //   params.put('fieldSetName', 'fieldSetName');
  //   params.put('approvalType', 'Application');
  //   params.put('status', ApplicationConstant.KYC_PASSED);
  //   params.put('recordId', application.Id);
  //   request.setHeader(new Map<String, object>{ 'applicantIds' => application.mflow__Applicants__r });
  //   request.setData(new List<Id>{ application.mflow__Applicants__r[0].Id });
  //   makeApplicationConfiguration();
  //   LwcCustomController.updateKycDecision(params);
  //   params.put('approvalType', 'Application And Applicants');
  //   params.put('status', ApplicationConstant.KYC_FAILED);
  //   LwcCustomController.updateKycDecision(params);
  // }
  // @istest
  // private static void TestTen() {
  //   Application__c application = makeApplicationData();
  //   application = TestData.readApplicationWithChild(application.Id);
  //   ApexRequest request = new ApexRequest();
  //   Map<String, object> params = new Map<String, object>();
  //   params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
  //   params.put('objectApiName', 'mflow__Application__c');
  //   params.put('fieldSetName', 'fieldSetName');
  //   params.put('approvalType', 'Application');
  //   params.put('status', ApplicationConstant.KYC_FAILED);
  //   params.put('recordId', application.Id);
  //   request.setHeader(new Map<String, object>{ 'applicantIds' => application.mflow__Applicants__r });
  //   request.setData(new List<Id>{ application.mflow__Applicants__r[0].Id });
  //   makeApplicationConfiguration();
  //   LwcCustomController.updateKycDecision(params);
  //   params.put('approvalType', 'Application And Applicants');
  //   params.put('status', ApplicationConstant.KYC_PASSED);
  //   LwcCustomController.updateKycDecision(params);
  // }
  // @istest
  // private static void TestTwelve() {
  //   Application__c application = makeApplicationData();
  //   application = TestData.readApplicationWithChild(application.Id);
  //   ApexRequest request = new ApexRequest();
  //   Map<String, object> params = new Map<String, object>();
  //   params.put('filter', 'filter');
  //   params.put('recordId', application.mflow__Applicants__r[0].Id);
  //   request.setHeader(new Map<String, object>{ 'applicantIds' => application.mflow__Applicants__r });
  //   request.setData(new List<Id>{ application.mflow__Applicants__r[0].Id });
  //   makeApplicationConfiguration();
  //   LwcCustomController.readApplicationForResume(params);
  // }
}
