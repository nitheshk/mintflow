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
    //excepected exception because readony profile don't have dml access on account object
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
      Account acc = TestData.createAccount();

      try {
        acc = (Account) DatabaseUtils.insertRecordsBySharing(
          new List<Account>{ acc }
        )[0];
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains('Insufficient CREATABLE permission on object')
          ? true
          : false;
        System.AssertEquals(expectedExceptionThrown, true);
      }

      try {
        acc = (Account) DatabaseUtils.updateRecordsBySharing(
          new List<Account>{ acc }
        )[0];
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains('Insufficient UPDATABLE permission on object')
          ? true
          : false;
        System.AssertEquals(expectedExceptionThrown, true);
      }

      try {
        acc = (Account) DatabaseUtils.upsertRecordsBySharing(
          new List<Account>{ acc }
        )[0];
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains('Insufficient UPSERTABLE permission on object')
          ? true
          : false;
        System.AssertEquals(expectedExceptionThrown, true);
      }

      try {
        acc = (Account) DatabaseUtils.upsertRecordsBySharing(
          new List<Account>{ acc },
          Account.Id
        )[0];
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains('Insufficient UPSERTABLE permission on object')
          ? true
          : false;
        System.AssertEquals(expectedExceptionThrown, true);
      }

      try {
        DatabaseUtils.deleteRecordsBySharing(new List<Account>{ acc });
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
      Account acc = TestData.createAccount();
      //excepted exception because before insert fields are getting strip because of no access on field for readonly profile
      try {
        acc = (Account) DatabaseUtils.insertRecordsByStrip(
          new List<Account>{ acc }
        )[0];
      } catch (Exception e) {
        Boolean expectedExceptionThrown = e.getMessage()
            .contains('REQUIRED_FIELD_MISSING')
          ? true
          : false;
        System.AssertEquals(expectedExceptionThrown, true);
      }

      acc = TestData.createAccount();
      acc = (Account) DatabaseUtils.insertRecords(new List<Account>{ acc })[0];

      acc = (Account) DatabaseUtils.upsertRecordsByStrip(
        new List<Account>{ acc }
      )[0];

      System.AssertNotEquals(null, acc);
    }
    Test.stopTest();
  }

  @IsTest
  private static void dmlOnSystemAdmin() {
    Account acc = TestData.createAccount();
    DatabaseUtils.insertRecordBySharing(acc);
    DatabaseUtils.updateRecordBySharing(acc);
    DatabaseUtils.upsertRecordBySharing(acc);
    DatabaseUtils.upsertRecordBySharing(acc, Account.Id);
    DatabaseUtils.deleteRecordBySharing(acc);

    acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecordByStrip(acc);
    acc = (Account) DatabaseUtils.updateRecordByStrip(acc);
    acc = (Account) DatabaseUtils.upsertRecordByStrip(acc);
    acc = (Account) DatabaseUtils.upsertRecordByStrip(acc, Account.Id);

    acc = TestData.createAccount();
    DatabaseUtils.insertRecord(acc);
    DatabaseUtils.updateRecord(acc);
    DatabaseUtils.upsertRecord(acc);
    DatabaseUtils.upsertRecord(acc, Account.Id);
    DatabaseUtils.deleteRecord(acc);

    List<SObject> objs = DatabaseUtils.getRecords(
      Query.newInstance(Account.SObjectType).toString()
    );
    System.assertEquals(1, objs.size(), 'Failed to build query');
  }

  @IsTest
  private static void validateOnEmptyDML() {
    Account acc;
    DatabaseUtils.insertRecordBySharing(acc);
    DatabaseUtils.updateRecordBySharing(acc);
    DatabaseUtils.upsertRecordBySharing(acc);
    DatabaseUtils.upsertRecordBySharing(acc, Account.Id);
    DatabaseUtils.deleteRecordBySharing(acc);

    DatabaseUtils.insertRecordsBySharing(new List<Account>{});
    DatabaseUtils.updateRecordsBySharing(new List<Account>{});
    DatabaseUtils.upsertRecordsBySharing(new List<Account>{});
    DatabaseUtils.upsertRecordsBySharing(new List<Account>{}, Account.Id);
    DatabaseUtils.deleteRecordsBySharing(new List<Account>{});

    DatabaseUtils.insertRecordByStrip(acc);
    DatabaseUtils.updateRecordByStrip(acc);
    DatabaseUtils.upsertRecordByStrip(acc);
    DatabaseUtils.upsertRecordByStrip(acc, Account.Id);

    DatabaseUtils.insertRecordsByStrip(new List<Account>{});
    DatabaseUtils.updateRecordsByStrip(new List<Account>{});
    DatabaseUtils.upsertRecordsByStrip(new List<Account>{});
    DatabaseUtils.upsertRecordsByStrip(new List<Account>{}, Account.Id);

    DatabaseUtils.insertRecord(acc);
    DatabaseUtils.updateRecord(acc);
    DatabaseUtils.upsertRecord(acc);
    DatabaseUtils.upsertRecord(acc, Account.Id);
    DatabaseUtils.deleteRecord(acc);

    DatabaseUtils.insertRecords(new List<Account>{});
    DatabaseUtils.updateRecords(new List<Account>{});
    DatabaseUtils.upsertRecords(new List<Account>{});
    DatabaseUtils.upsertRecords(new List<Account>{}, Account.Id);
    DatabaseUtils.deleteRecords(new List<Account>{});

    List<SObject> objs = DatabaseUtils.getRecords(
      Query.newInstance(Account.SObjectType).toString()
    );
    System.assertEquals(0, objs.size(), 'Failed to build query');
  }
}
