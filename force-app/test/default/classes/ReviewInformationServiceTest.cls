@istest
public with sharing class ReviewInformationServiceTest {
  private static Application__c makeApplicationData(string status) {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);

    Applicant__c applicant = TestData.createApplicant('Primary');
    Id recType = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Primary').getRecordTypeId();
    applicant.RecordTypeId = recType;
    applicant.Application__c = acc.Id;
    applicant.Status__c = status;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    Applicant__c applicant2 = TestData.createApplicant('Joint');
    Id recType2 = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Joint').getRecordTypeId();
    applicant2.RecordTypeId = recType2;
    applicant2.Application__c = acc.Id;
    applicant2.Status__c = status;
    applicant2 = (Applicant__c) DatabaseUtils.insertRecord(applicant2);

    List<FinancialProduct__c> products = TestData.createProduct();
    products = (List<FinancialProduct__c>) DatabaseUtils.insertRecords(products);

    FinancialAccount__c finAcc = TestData.makeFinancialAccount();
    finAcc.mflow__FinancialProduct__c = products[0].Id;
    finAcc.mflow__Application__c = acc.Id;
    Id recTypef = Schema.SObjectType.FinancialAccount__c.getRecordTypeInfosByName().get('Savings').getRecordTypeId();
    finAcc.RecordTypeId = recTypef;
    finAcc = (FinancialAccount__c) DatabaseUtils.insertRecord(finAcc);

    IdentificationDocument__c identity = TestData.createIdentity(null);
    identity.Applicant__c = applicant.Id;
    identity = (IdentificationDocument__c) DatabaseUtils.insertRecord(identity);
    applicant.mflow__IdentificationDocuments__r.addAll(new List<IdentificationDocument__c>{ identity });
    acc.Applicants__r.addAll(new List<Applicant__c>{ applicant });
    acc.mflow__FinancialAccounts__r.addAll(new List<FinancialAccount__c>{ finAcc });
    return acc;
  }
  private static ApplicationConfiguration__c makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    appConfig = (ApplicationConfiguration__c) DatabaseUtils.insertRecord(appConfig);
    return appConfig;
  }
  @istest
  static void TestOne() {
    makeApplicationConfiguration();
    Application__c acc = makeApplicationData(ApplicationConstant.SUBMITTED_FOR_REVIEW);
    acc = TestData.readApplicationWithChild(acc.Id);
    test.startTest();
    ReviewInformationService.getInstance().primaryConsumerFlow(acc);
    ReviewInformationService.getInstance().reviewInformationSubmit(acc.Id);
    test.stopTest();
  }
  @istest
  static void TestTwo() {
    makeApplicationConfiguration();
    Application__c acc = makeApplicationData(ApplicationConstant.SUBMITTED_FOR_REVIEW);
    acc = TestData.readApplicationWithChild(acc.Id);
    test.startTest();
    try {
      ReviewInformationService.getInstance().reviewInformationSubmit(acc.Id);
      ReviewInformationService.getInstance().resubmitApplicationForReview(acc.Id);
      ReviewInformationService.getInstance().jointConsumerFlow(acc);
    } catch (Exception e) {
    }
    test.stopTest();
  }
}
