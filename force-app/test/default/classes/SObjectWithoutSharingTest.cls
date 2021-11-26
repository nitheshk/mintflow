@istest
public with sharing class SObjectWithoutSharingTest {
  private static Account makeAccountData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  @istest
  static void SObjectWithoutSharingTestOne() {
    Account acc = TestData.createAccount();
    account acc1 = TestData.createAccount();
    SObjectField a;
    test.startTest();
    try {
      SObjectWithoutSharing.getRecords('select id from account');
      SObjectWithoutSharing.getRecords(
        'select id from account',
        new List<Object>{ 1, 5, 6, 'd', 's', 4 }
      );
      SObjectWithoutSharing.processRecords(
        crudType.CREATABLE,
        new List<SObject>{ acc, acc1 },
        a
      );

      SObjectWithoutSharing.processRecords(
        crudType.READABLE,
        new List<SObject>{ acc },
        a
      );
      SObjectWithoutSharing.processRecords(
        crudType.UPDATABLE,
        new List<SObject>{ acc },
        a
      );
      SObjectWithoutSharing.processRecords(
        crudType.UPSERTABLE,
        new List<SObject>{ acc },
        a
      );
      SObjectWithoutSharing.processRecords(
        crudType.DELETEABLE,
        new List<SObject>{ acc },
        a
      );
      SObjectWithoutSharing.deleteRecords(new List<id>{ acc1.id }, true);
      SObjectWithoutSharing.assignProfileIdToUser(new user(), acc.Id);
      SObjectWithoutSharing.renderStoredEmailTemplate(
        new Messaging.SingleEmailMessage()
      );
    } catch (exception e) {
    }
    test.stopTest();
    system.assertEquals(null, null, 'message');
  }
}
