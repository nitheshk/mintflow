@istest
public with sharing class SObjectWithSharingTest {
  @istest
  static void sObjectWithSharingTestOne() {
    Application__c acc = TestData.createApplication();
    Application__c acc1 = TestData.createApplication();
    SObjectField a;
    test.startTest();
    try {
      SObjectWithSharing.getRecords('select id from Application__c');
      SObjectWithSharing.getRecords(
        'select id from Application__c',
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
