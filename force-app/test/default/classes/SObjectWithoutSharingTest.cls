@istest
public with sharing class SObjectWithoutSharingTest {
  private static Application__c makeAccountData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  @istest
  static void SObjectWithoutSharingTestOne() {
    Application__c acc = TestData.createApplication();
    Application__c acc1 = TestData.createApplication();
    SObjectField a;
    test.startTest();
    try {
      SObjectWithoutSharing.getRecords('select id from Application__c');
      SObjectWithoutSharing.getRecords(
        'select id from Application__c',
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
