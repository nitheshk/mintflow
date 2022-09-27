@istest
public with sharing class FinancialAccountControllerTest {
  private static ReferralProduct__c makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    insert appConfig;
    TestData.createSiteSetting();
    List<FinancialProduct__c> products = TestData.createProduct();
    insert products;
    ProductService__c productService = TestData.makeProductService();
    productService.mflow__FinancialProduct__c = products[0].Id;
    insert productService;
    ReferralProduct__c referralProduct = testdata.makeReferralProduct();
    referralProduct.mflow__FinancialProduct__c = products[0].Id;
    referralProduct.mflow__CrossSellProduct__c = products[1].Id;
    insert referralProduct;
    return referralProduct;
  }
  private static Applicant__c createApplicantDataWithChild(Application__c application) {
    Applicant__c applicant = Application.Applicants__r[0];
    SObjectConstructor construct = SObjectConstructor.getInstance(applicant);

    IdentificationDocument__c identity = TestData.createIdentity(applicant.Id);
    insert identity;

    Employment__c employment = TestData.createEmployment(applicant.Id);
    insert employment;

    Address__c address = TestData.createAddress(applicant.Id);
    insert address;

    construct.addChildObject('mflow__IdentificationDocuments__r', identity);
    construct.addChildObject('mflow__Employments__r', employment);
    construct.addChildObject('mflow__Addresses__r', address);

    return (Applicant__c) construct.build();
  }
  private static Application__c makeApplicationData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);

    List<FinancialProduct__c> products = TestData.createProduct();
    products[0].InternalCode__c = 'IC001';
    products = (List<FinancialProduct__c>) DatabaseUtils.insertRecords(products);

    FinancialAccount__c finAcc = TestData.makeFinancialAccount();
    finAcc.mflow__FinancialProduct__c = products[0].Id;
    finAcc.mflow__Application__c = acc.Id;
    Id recType = Schema.SObjectType.FinancialAccount__c.getRecordTypeInfosByName().get('Savings').getRecordTypeId();
    finAcc.RecordTypeId = recType;
    finAcc = (FinancialAccount__c) DatabaseUtils.insertRecord(finAcc);

    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    acc.mflow__Applicants__r.addAll(new List<Applicant__c>{ applicant });
    acc.mflow__FinancialAccounts__r.addAll(new List<FinancialAccount__c>{ finAcc });
    return acc;
  }
  @IsTest
  private static void fetchServicesTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    FinancialAccountController.fetchServices(request);
  }

  @IsTest
  private static void fetchReferralProductsTest() {
    ReferralProduct__c rf = makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    FinancialAccountController.fetchReferralProducts(request);

    // SObjectConstructor construct = SObjectConstructor.getInstance(application);
    // CustomerInterest__c customerInsert = new CustomerInterest__c();
    // customerInsert.Name = 'Prime Debit Account';
    // customerInsert.mflow__InterestProduct__c = rf.Id;
    // customerInsert.mflow__IsSelected__c = false;
    // construct.addChildObject('mflow__CustomerInterests__r', customerInsert);
    // request = new ApexRequest();
    // request.token = ApexRequest.getToken();
    // FinancialAccountController.fetchReferralProducts(request);
  }
  @IsTest
  private static void saveFinancialAccountsTest() {
    ApexRequest request = new ApexRequest();
    ApexResponse res = new ApexResponse();
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //400
    request.token = ApexRequest.getToken();
    res = FinancialAccountController.saveFinancialAccounts(request);

    //200
    request.applicationId = application.Id; //Application__c ID
    request.setData(JSON.serialize(application.FinancialAccounts__r));
    ApexPages.currentPage().getParameters().put('pid', 'IC001');
    ApexPages.StandardController sc = new ApexPages.StandardController(application);
    res = FinancialAccountController.saveFinancialAccounts(request);

    request = new ApexRequest();
    request.token = 'InvalidToken';
    res = FinancialAccountController.saveFinancialAccounts(null);
  }
  @IsTest
  private static void fetchProductFeaturesTest() {
    ApexRequest request = new ApexRequest();
    ApexResponse res = new ApexResponse();
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200
    request.token = ApexRequest.getToken();
    res = FinancialAccountController.fetchProductFeatures(request);
    system.assertEquals(200, res.status, 'success');
    //500
    request = new ApexRequest();
    request.token = 'InvalidToken';
    res = FinancialAccountController.fetchProductFeatures(request);
    system.assertEquals(500, res.status, 'success');

    request = new ApexRequest();
    res = FinancialAccountController.fetchProductFeatures(null);
  }
  @IsTest
  private static void readFinancialAccountsTest() {
    ApexRequest request = new ApexRequest();
    ApexResponse res = new ApexResponse();
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //400
    request.token = ApexRequest.getToken();
    res = FinancialAccountController.readFinancialAccounts(request);

    //200
    request.applicationId = application.Id; //Application__c ID
    request.setData(JSON.serialize(application.FinancialAccounts__r));
    ApexPages.currentPage().getParameters().put('pid', 'IC001');
    ApexPages.StandardController sc = new ApexPages.StandardController(application);
    res = FinancialAccountController.readFinancialAccounts(request);

    request = new ApexRequest();
    request.token = 'InvalidToken';
    res = FinancialAccountController.readFinancialAccounts(null);
  }

  @IsTest
  private static void fetchVehicleDetailsTest() {
    ApexRequest request = new ApexRequest();
    ApexResponse res = new ApexResponse();
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    TestData.createVehicleSpecification();
    Test.startTest();
    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, object>{ 'searchType' => 'Vin', 'vin' => '565516' });
    res = FinancialAccountController.fetchVehicleDetails(request);
    system.assertEquals(200, res.status, 'success');

    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, object>{ 'searchType' => 'Make', 'year' => '2013' });
    res = FinancialAccountController.fetchVehicleDetails(request);
    system.assertEquals(200, res.status, 'success');

    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, object>{ 'searchType' => 'Model', 'year' => '2013', 'make' => '77' });
    res = FinancialAccountController.fetchVehicleDetails(request);
    system.assertEquals(200, res.status, 'success');

    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(
      new Map<String, object>{ 'searchType' => 'SubModel', 'year' => '2013', 'make' => '77', 'model' => '254' }
    );
    res = FinancialAccountController.fetchVehicleDetails(request);
    system.assertEquals(200, res.status, 'success');

    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, object>{ 'searchType' => 'Failure' });
    res = FinancialAccountController.fetchVehicleDetails(request);
    system.assertEquals(200, res.status, 'success');
    //400
    request = new ApexRequest();
    request.token = 'InvalidToken';
    res = FinancialAccountController.fetchVehicleDetails(request);
    system.assertEquals(500, res.status, 'success');
    Test.stopTest();
  }
}
