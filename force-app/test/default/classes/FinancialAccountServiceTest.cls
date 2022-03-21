@istest
public with sharing class FinancialAccountServiceTest {
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
    IdentificationDocument__c identity = TestData.createIdentity();
    identity.Applicant__c = applicant.Id;
    identity = (IdentificationDocument__c) DatabaseUtils.insertRecord(identity);
    applicant.mflow__IdentificationDocuments__r.addAll(new List<IdentificationDocument__c>{ identity });
    acc.mflow__FinancialAccounts__r.addAll(new List<FinancialAccount__c>{ finAcc });
    acc.mflow__CustomerInterests__r.addAll(new List<mflow__CustomerInterest__c>{ new mflow__CustomerInterest__c() });
    return acc;
  }
  @isTest
  static void testOne() {
    test.startTest();
    // FinancialAccountService.
    test.stopTest();
  }
}
