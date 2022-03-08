@IsTest
public with sharing class BuildApplicationWrapperTest {
  private static Application__c makeApplicationData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);

    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    IdentificationDocument__c identity = TestData.createIdentity();
    identity.Applicant__c = applicant.Id;
    identity = (IdentificationDocument__c) DatabaseUtils.insertRecord(identity);
    applicant.mflow__IdentificationDocuments__r.addAll(
      new List<IdentificationDocument__c>{ identity }
    );

    Employment__c employment = TestData.createEmployment();
    employment.Applicant__c = applicant.Id;
    employment = (Employment__c) DatabaseUtils.insertRecord(employment);
    applicant.mflow__Employments__r.addAll(
      new List<Employment__c>{ employment }
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
    mflow__Application__c application = makeApplicationData();
    application = [
      SELECT Id, Name
      FROM mflow__Application__c
      WHERE id = :application.id
    ];
    Test.startTest();
    BuildApplicationWrapper.getInstance()
      .obtainApplicationData(application.Name);
    BuildApplicationWrapper.getInstance()
      .obtainApplicationFiles(application.Name);
    Test.stopTest();
  }
}
