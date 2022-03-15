@istest
public with sharing class ConsentResolverTest {
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

    mflow__Consent__c consent = TestData.createConsent();
    consent.Application__c = acc.Id;
    consent.mflow__Applicant__c = applicant.Id;
    consent = (mflow__Consent__c) DatabaseUtils.insertRecord(consent);

    acc.Applicants__r.addAll(new List<Applicant__c>{ applicant });
    acc.mflow__FinancialAccounts__r.addAll(new List<FinancialAccount__c>{ finAcc });
    return acc;
  }
  private static ConsentLineItem__c makeConsentLineItem() {
    ConsentLineItem__c cli = TestData.createConsentLineItem();
    return cli;
  }

  @IsTest
  private static void fetchConsentsTest() {
    mflow__Application__c application = makeApplicationData();
    ApexRequest request = new ApexRequest();
    ApexRequest.setApplicantType('Primary');
    request.header = '{"eventIdentifier":"ReviewSubmit"}';
    ApexRequest.setApplicationId(application.Id);
    List<Applicant__c> applicant = [SELECT id FROM Applicant__c WHERE mflow__Application__c = :application.Id];
    ApexRequest.setApplicantId(applicant[0].Id);
    test.startTest();
    ApplicationController.fetchConsents(request);
    ConsentResolver.getInstance()
      .resolveConsents(
        application,
        new List<object>{ new Map<String, Object>{ 'Name' => 'Checking Application__c Agreement' } }
      );
    ConsentResolver.getInstance().resolveConsents(application, new List<object>());
    ConsentResolver.getInstance().resolveConsents(application);
    ConsentResolver.getInstance()
      .mapConsentItemToConsent(new List<ConsentLineItem__c>{ makeConsentLineItem() }, application.Id);
    ConsentResolver.getInstance().removeDuplicateConsents(new List<Consent__c>{ TestData.createConsent() });
    ConsentResolver.getInstance().sort(new List<Consent__c>{ TestData.createConsent() });
    ConsentResolver.getInstance().generateConsentPdf(application.Id);
    test.stopTest();
  }
}
