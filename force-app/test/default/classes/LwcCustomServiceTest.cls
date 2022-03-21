@istest
public with sharing class LwcCustomServiceTest {
  private static Application__c makeApplicationData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);

    List<FinancialProduct__c> products = TestData.createProduct();
    products = (List<FinancialProduct__c>) DatabaseUtils.insertRecords(products);

    ProductService__c productService = TestData.makeProductService();
    productService.mflow__FinancialProduct__c = products[0].Id;
    productService = (ProductService__c) DatabaseUtils.insertRecord(productService);

    FinancialAccount__c finAcc = TestData.makeFinancialAccount();
    finAcc.mflow__FinancialProduct__c = products[0].Id;
    finAcc.mflow__Application__c = acc.Id;
    Id recType = Schema.SObjectType.FinancialAccount__c.getRecordTypeInfosByName().get('Savings').getRecordTypeId();
    finAcc.RecordTypeId = recType;
    finAcc = (FinancialAccount__c) DatabaseUtils.insertRecord(finAcc);

    FinancialAccountTransaction__c tran = TestData.createFinancialAccountTransaction();
    tran.FinancialAccount__c = finAcc.Id;
    tran.TransactionDate__c = DateTime.newInstance(2007, 6, 23, 3, 3, 3);
    tran = (FinancialAccountTransaction__c) DatabaseUtils.insertRecord(tran);

    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    acc.Applicants__r.addAll(new List<Applicant__c>{ applicant });
    IdentificationDocument__c identity = TestData.createIdentity(null);
    identity.Applicant__c = applicant.Id;
    identity = (IdentificationDocument__c) DatabaseUtils.insertRecord(identity);
    applicant.mflow__IdentificationDocuments__r.addAll(new List<IdentificationDocument__c>{ identity });
    acc.mflow__FinancialAccounts__r.addAll(new List<FinancialAccount__c>{ finAcc });
    acc.mflow__CustomerInterests__r.addAll(new List<mflow__CustomerInterest__c>{ new mflow__CustomerInterest__c() });
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
    Application__c application = makeApplicationData();
    application = TestData.readApplicationWithChild(application.Id);
    Map<String, String> params = new Map<String, String>();
    params.put('configData', 'configData');
    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantIds' => application.mflow__Applicants__r });
    request.setData(new List<Id>{ application.Id });
    test.startTest();
    LwcCustomController.readFlows(params);
    params.put('recordId', application.mflow__Applicants__r[0].Id);
    params.put('objectApiName', 'mflow__Applicant__c');
    params.put('status', 'Passed');
    params.put('approvalType', 'approvalType');
    // params.put(arg0, arg1);
    LwcCustomController.readFlows(params);
    LwcCustomController.fetchConfigValues();
    LwcCustomController.updateConfigValues(params);
    LwcCustomController.readApplicationWithChild(application.Id);
    LwcCustomController.readApplicationWithApplicants(application.Id);
    LwcCustomController.readApplicationForResume(application.Id);
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
  @istest
  private static void TestEight() {
    Application__c application = makeApplicationData();
    application = TestData.readApplicationWithChild(application.Id);
    ApexRequest request = new ApexRequest();
    Map<String, object> params = new Map<String, object>();
    params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
    params.put('sObjectName', 'mflow__Application__c');
    params.put('fieldSetName', 'fieldSetName');
    request.setHeader(new Map<String, object>{ 'applicantIds' => application.mflow__Applicants__r });
    request.setData(new List<Id>{ application.mflow__Applicants__r[0].Id });
    makeApplicationConfiguration();
    test.startTest();
    try {
      LwcCustomController.sendResumeApplicationEmail(request);
      LwcCustomController.fetchPickListValues(params);
      LwcCustomController.updateKycDecision(params);
    } catch (Exception e) {
    }
    test.stopTest();
  }
  @istest
  private static void TestNine() {
    Application__c application = makeApplicationData();
    application = TestData.readApplicationWithChild(application.Id);
    ApexRequest request = new ApexRequest();
    Map<String, object> params = new Map<String, object>();
    params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
    params.put('objectApiName', 'mflow__Application__c');
    params.put('fieldSetName', 'fieldSetName');
    params.put('approvalType', 'Application');
    params.put('status', ApplicationConstant.KYC_PASSED);
    params.put('recordId', application.Id);
    request.setHeader(new Map<String, object>{ 'applicantIds' => application.mflow__Applicants__r });
    request.setData(new List<Id>{ application.mflow__Applicants__r[0].Id });
    makeApplicationConfiguration();
    test.startTest();
    try {
      LwcCustomController.updateKycDecision(params);
      params.put('approvalType', 'Application And Applicants');
      params.put('status', ApplicationConstant.KYC_FAILED);
      LwcCustomController.updateKycDecision(params);
    } catch (Exception e) {
    }
    test.stopTest();
  }
  @istest
  private static void TestTen() {
    Application__c application = makeApplicationData();
    application = TestData.readApplicationWithChild(application.Id);
    ApexRequest request = new ApexRequest();
    Map<String, object> params = new Map<String, object>();
    params.put('Lead', new List<string>{ 'LeadSource', 'Staus' });
    params.put('objectApiName', 'mflow__Application__c');
    params.put('fieldSetName', 'fieldSetName');
    params.put('approvalType', 'Application');
    params.put('status', ApplicationConstant.KYC_FAILED);
    params.put('recordId', application.Id);
    request.setHeader(new Map<String, object>{ 'applicantIds' => application.mflow__Applicants__r });
    request.setData(new List<Id>{ application.mflow__Applicants__r[0].Id });
    makeApplicationConfiguration();
    test.startTest();
    try {
      LwcCustomController.updateKycDecision(params);
      params.put('approvalType', 'Application And Applicants');
      params.put('status', ApplicationConstant.KYC_PASSED);
      LwcCustomController.updateKycDecision(params);
    } catch (Exception e) {
    }
    test.stopTest();
  }
}
