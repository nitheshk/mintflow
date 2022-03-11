@istest
public with sharing class FinancialAccountControllerTest {
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

    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    acc.mflow__Applicants__r.addAll(new List<Applicant__c>{ applicant });
    acc.mflow__FinancialAccounts__r.addAll(new List<FinancialAccount__c>{ finAcc });
    return acc;
  }
  @IsTest
  private static void fetchServicesTest() {
    mflow__Application__c application = makeApplicationData();
    ApexRequest request = new ApexRequest();
    request.applicationId = application.Id; //Application__c ID
    Test.startTest();
    FinancialAccountController.fetchServices(request);
    FinancialAccountController.fetchServices(request);
    FinancialAccountController.fetchReferralProducts(request);
    Test.stopTest();
  }
  @IsTest
  private static void exceptionTest() {
    Test.startTest();
    FinancialAccountController.fetchServices(new ApexRequest());
    FinancialAccountController.fetchReferralProducts(new ApexRequest());
    Test.stopTest();
  }
  @IsTest
  private static void saveFinancialAccountsTest() {
    mflow__Application__c application = makeApplicationData();
    ApexRequest request = new ApexRequest();
    request.applicationId = application.Id; //Application__c ID
    request.setData(JSON.serialize(application.FinancialAccounts__r));
    Test.startTest();
    FinancialAccountController.saveFinancialAccounts(new ApexRequest());
    FinancialAccountController.fetchReferralProducts(new ApexRequest());
    Test.stopTest();
  }
}
