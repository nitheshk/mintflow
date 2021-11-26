@istest
public with sharing class SObjectConstructorTest {
  private static Account makeAccountData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecord(acc);
    return acc;
  }

  private static Applicant__c makeApplicantData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecords(new List<Account>{ acc })[0];
    Applicant__c applicant = TestData.createApplicant(acc.Id);
    applicant.Email__c = 'test@mail.com';
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }
  @istest
  static void SObjectConstructorTestOne() {
    Account acc = TestData.createAccount();
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
      SObjectConstructor.serialize(acc),
      Account.class
    );
    SObjectConstructor.writeFieldsAsList(new List<SObject>{ applicant });

    test.stopTest();
  }
}
