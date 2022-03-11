@istest
public with sharing class BuildFundingWrapperTest {
  private static Application__c makeApplicationData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);

    List<FinancialProduct__c> products = TestData.createProduct();
    products = (List<FinancialProduct__c>) DatabaseUtils.insertRecords(products);

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
    acc.mflow__FinancialAccounts__r.addAll(new List<FinancialAccount__c>{ finAcc });
    return acc;
  }
  @IsTest
  private static void obtainFundingDataTest() {
    mflow__Application__c application = makeApplicationData();
    application = [SELECT Id, Name FROM mflow__Application__c WHERE id = :application.id];
    test.startTest();
    BuildFundingWrapper.getInstance().obtainFundingData(application.Name);
    test.stopTest();
  }
}
