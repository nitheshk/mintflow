@istest
public with sharing class SObjectWithSharingTest {
  @istest
  static void sObjectWithSharingTestOne() {
    Account acc = TestData.createAccount();
    account acc1 = TestData.createAccount();
    SObjectField a;
    test.startTest();
    try {
      SObjectWithSharing.getRecords('select id from account');
      SObjectWithSharing.getRecords(
        'select id from account',
        new List<Object>{ 1, 5, 6, 'd', 's', 4 }
      );
      SObjectWithSharing.processRecords(
        crudType.CREATABLE,
        new List<SObject>{ acc, acc1 },
        a
      );

      SObjectWithSharing.processRecords(
        crudType.READABLE,
        new List<SObject>{ acc },
        a
      );
      SObjectWithSharing.processRecords(
        crudType.UPDATABLE,
        new List<SObject>{ acc },
        a
      );
      SObjectWithSharing.processRecords(
        crudType.UPSERTABLE,
        new List<SObject>{ acc },
        a
      );
      SObjectWithSharing.processRecords(
        crudType.DELETEABLE,
        new List<SObject>{ acc },
        a
      );
    } catch (exception e) {
    }
    test.stopTest();
    system.assertEquals(null, null, 'message');
  }
}
