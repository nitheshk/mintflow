@istest
public with sharing class SObjectConstructorTest {
  private static Application__c makeAccountData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);
    return acc;
  }
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

    acc.Applicants__r.addAll(new List<Applicant__c>{ applicant });
    return acc;
  }

  private static Applicant__c makeApplicantData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecords(
      new List<Application__c>{ acc }
    )[0];
    Applicant__c applicant = TestData.createApplicant(acc.Id);
    applicant.Email__c = 'test@mail.com';
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }
  @istest
  static void SObjectConstructorTestOne() {
    Application__c acc = TestData.createApplication();
    Applicant__c applicant = makeApplicantData();
    test.startTest();
    SObjectConstructor sObj = new SObjectConstructor();
    SObjectConstructor.getInstance(acc)
      .setChildObjects('relationShipName', new List<SObject>{ applicant })
      .setChildObject('relationShipName', applicant)
      .addChildObjects('relationShipName', new List<SObject>{ applicant })
      .addChildObject('relationShipName', applicant)
      .setLookupObject('relationShipName', applicant)
      .build();
    SObjectConstructor.deserialize(
      SObjectConstructor.serialize(makeApplicationData()),
      Application__c.class
    );
    SObjectConstructor.writeFieldsAsList(new List<SObject>{ applicant });
    sObj.removeFields('relationShipName');
    test.stopTest();
  }
}
