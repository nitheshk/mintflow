/**
 * Copyright (c) 2021 Digital Align
 * @group Test
 * @author Digital Align Team
 **/
@IsTest
private class DatabaseUtilsTest {
  @IsTest
  private static void withSharingForReadOnlyProfile() {
    //Testing with  Insufficient permission
    //excepected exception because readony profile don't have dml access on Application__c object
    Test.startTest();

    User u = new User(
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Read Only']
      .Id,
      LastName = 'last',
      Email = 'puser000@amamama.com',
      Username = 'puser000@amamama.com' + System.currentTimeMillis(),
      CompanyName = 'TEST',
      Title = 'title',
      Alias = 'alias',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US'
    );
    insert u;

    System.runAs(u) {
      Application__c acc = TestData.createApplication();

      try {
        acc = (Application__c) DatabaseUtils.insertRecordsBySharing(
          new List<Application__c>{ acc }
        )[0];
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains('Insufficient CREATABLE permission on object')
          ? true
          : false;
        System.AssertEquals(expectedExceptionThrown, true);
      }

      try {
        acc = (Application__c) DatabaseUtils.updateRecordsBySharing(
          new List<Application__c>{ acc }
        )[0];
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains('Insufficient UPDATABLE permission on object')
          ? true
          : false;
        System.AssertEquals(expectedExceptionThrown, true);
      }

      try {
        acc = (Application__c) DatabaseUtils.upsertRecordsBySharing(
          new List<Application__c>{ acc }
        )[0];
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains('Insufficient UPSERTABLE permission on object')
          ? true
          : false;
        System.AssertEquals(expectedExceptionThrown, true);
      }

      try {
        acc = (Application__c) DatabaseUtils.upsertRecordsBySharing(
          new List<Application__c>{ acc },
          Application__c.Id
        )[0];
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains('Insufficient UPSERTABLE permission on object')
          ? true
          : false;
        System.AssertEquals(expectedExceptionThrown, true);
      }

      try {
        DatabaseUtils.deleteRecordsBySharing(new List<Application__c>{ acc });
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains('Insufficient DELETEABLE permission on object')
          ? true
          : false;
        System.AssertEquals(expectedExceptionThrown, true);
      }
    }

    Test.stopTest();
  }

  @IsTest
  private static void stripRecordsForReadOnlyProfile() {
    //Testing with  Insufficient permission
    //expected exception
    Test.startTest();

    User u = new User(
      ProfileId = [SELECT Id FROM Profile WHERE Name = 'Read Only']
      .Id,
      LastName = 'last',
      Email = 'puser000@amamama.com',
      Username = 'puser000@amamama.com' + System.currentTimeMillis(),
      CompanyName = 'TEST',
      Title = 'title',
      Alias = 'alias',
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US'
    );
    insert u;

    System.runAs(u) {
      Application__c acc = TestData.createApplication();
      //excepted exception because before insert fields are getting strip because of no access on field for readonly profile
      try {
        acc = (Application__c) DatabaseUtils.insertRecordsByStrip(
          new List<Application__c>{ acc }
        )[0];
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains('REQUIRED_FIELD_MISSING')
          ? true
          : false;
        System.AssertEquals(expectedExceptionThrown, true);
      }

      acc = TestData.createApplication();
      acc = (Application__c) DatabaseUtils.insertRecords(
        new List<Application__c>{ acc }
      )[0];

      acc = (Application__c) DatabaseUtils.upsertRecordsByStrip(
        new List<Application__c>{ acc }
      )[0];

      System.AssertNotEquals(null, acc);
    }
    Test.stopTest();
  }

  @IsTest
  private static void dmlOnSystemAdmin() {
    Application__c acc = TestData.createApplication();
    DatabaseUtils.insertRecordBySharing(acc);
    DatabaseUtils.updateRecordBySharing(acc);
    DatabaseUtils.upsertRecordBySharing(acc);
    DatabaseUtils.upsertRecordBySharing(acc, Application__c.Id);
    DatabaseUtils.deleteRecordBySharing(acc);

    acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecordByStrip(acc);
    acc = (Application__c) DatabaseUtils.updateRecordByStrip(acc);
    acc = (Application__c) DatabaseUtils.upsertRecordByStrip(acc);
    acc = (Application__c) DatabaseUtils.upsertRecordByStrip(
      acc,
      Application__c.Id
    );

    acc = TestData.createApplication();
    DatabaseUtils.insertRecord(acc);
    DatabaseUtils.updateRecord(acc);
    DatabaseUtils.upsertRecord(acc);
    DatabaseUtils.upsertRecord(acc, Application__c.Id);
    DatabaseUtils.deleteRecord(acc);

    List<SObject> objs = DatabaseUtils.getRecords(
      Query.newInstance(Application__c.SObjectType).toString()
    );
    System.assertEquals(1, objs.size(), 'Failed to build query');
  }

  @IsTest
  private static void validateOnEmptyDML() {
    Application__c acc;
    DatabaseUtils.insertRecordBySharing(acc);
    DatabaseUtils.updateRecordBySharing(acc);
    DatabaseUtils.upsertRecordBySharing(acc);
    DatabaseUtils.upsertRecordBySharing(acc, Application__c.Id);
    DatabaseUtils.deleteRecordBySharing(acc);

    DatabaseUtils.insertRecordsBySharing(new List<Application__c>{});
    DatabaseUtils.updateRecordsBySharing(new List<Application__c>{});
    DatabaseUtils.upsertRecordsBySharing(new List<Application__c>{});
    DatabaseUtils.upsertRecordsBySharing(
      new List<Application__c>{},
      Application__c.Id
    );
    DatabaseUtils.deleteRecordsBySharing(new List<Application__c>{});

    DatabaseUtils.insertRecordByStrip(acc);
    DatabaseUtils.updateRecordByStrip(acc);
    DatabaseUtils.upsertRecordByStrip(acc);
    DatabaseUtils.upsertRecordByStrip(acc, Application__c.Id);

    DatabaseUtils.insertRecordsByStrip(new List<Application__c>{});
    DatabaseUtils.updateRecordsByStrip(new List<Application__c>{});
    DatabaseUtils.upsertRecordsByStrip(new List<Application__c>{});
    DatabaseUtils.upsertRecordsByStrip(
      new List<Application__c>{},
      Application__c.Id
    );

    DatabaseUtils.insertRecord(acc);
    DatabaseUtils.updateRecord(acc);
    DatabaseUtils.upsertRecord(acc);
    DatabaseUtils.upsertRecord(acc, Application__c.Id);
    DatabaseUtils.deleteRecord(acc);

    DatabaseUtils.insertRecords(new List<Application__c>{});
    DatabaseUtils.updateRecords(new List<Application__c>{});
    DatabaseUtils.upsertRecords(new List<Application__c>{});
    DatabaseUtils.upsertRecords(new List<Application__c>{}, Application__c.Id);
    DatabaseUtils.deleteRecords(new List<Application__c>{});

    List<SObject> objs = DatabaseUtils.getRecords(
      Query.newInstance(Application__c.SObjectType).toString()
    );
    System.assertEquals(0, objs.size(), 'Failed to build query');
  }
}
