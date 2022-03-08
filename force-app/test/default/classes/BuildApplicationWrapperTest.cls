@IsTest
public with sharing class BuildApplicationWrapperTest {
  private static Account makeApplicationData() {
    Account acc = TestData.createApplication();
    acc.Name = 'App-001';
    acc = (Account) DatabaseUtils.insertRecord(acc);

    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    FinServ__IdentificationDocument__c identity = TestData.createIdentity();
    identity.Applicant__c = applicant.Id;
    identity = (FinServ__IdentificationDocument__c) DatabaseUtils.insertRecord(
      identity
    );
    applicant.mflow__IdentificationDocuments__r.addAll(
      new List<FinServ__IdentificationDocument__c>{ identity }
    );

    FinServ__Employment__c employment = TestData.createEmployment();
    employment.Applicant__c = applicant.Id;
    employment = (FinServ__Employment__c) DatabaseUtils.insertRecord(
      employment
    );
    applicant.mflow__Employments__r.addAll(
      new List<FinServ__Employment__c>{ employment }
    );

    ContactPointAddress address = TestData.createContactPointAddress();
    address.Applicant__c = applicant.Id;
    address = (ContactPointAddress) DatabaseUtils.insertRecord(address);
    applicant.mflow__ContactPointAddresses__r.addAll(
      new List<ContactPointAddress>{ address }
    );

    mflow__Survey__c survey = TestData.createSurvey();
    survey.Applicant__c = applicant.Id;
    survey = (mflow__Survey__c) DatabaseUtils.insertRecord(survey);
    applicant.mflow__Surveys__r.addAll(new List<mflow__Survey__c>{ survey });

    acc.Applicants__r.addAll(new List<Applicant__c>{ applicant });
    return acc;
  }
  @IsTest
  private static void testObtainApplicationData() {
    account application = makeApplicationData();
    application = [
      SELECT Id, mflow__ApplicationNumber__c
      FROM account
      WHERE id = :application.id
    ];
    Test.startTest();
    BuildApplicationWrapper.getInstance()
      .obtainApplicationData(application.mflow__ApplicationNumber__c);
    BuildApplicationWrapper.getInstance()
      .obtainApplicationFiles(application.mflow__ApplicationNumber__c);
    Test.stopTest();
  }
}
