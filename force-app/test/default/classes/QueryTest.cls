/**
 * Copyright (c) 2021 Digital Align
 * @group Test
 * @author Digital Align Team
 **/
@isTest
private class QueryTest {
  private static void makeData() {
    Account acc = TestData.createAccountRecord();
    acc = (Account) DatabaseUtils.insertRecords(new List<Account>{ acc })[0];
    Contact con = TestData.createContact(acc);
    con = (Contact) DatabaseUtils.insertRecords(new List<Contact>{ con })[0];
    Opportunity opp = TestData.createOpportunity(acc);
    opp = (Opportunity) DatabaseUtils.insertRecords(
      new List<Opportunity>{ opp }
    )[0];
    OpportunityContactRole ocr = TestData.createOpportunityContactRole(
      opp,
      con
    );
    ocr = (OpportunityContactRole) DatabaseUtils.insertRecords(
      new List<OpportunityContactRole>{ ocr }
    )[0];
  }

  @isTest
  private static void soqlSample1() {
    makeData();
    //Simple soql
    String q = Query.newInstance(Account.SObjectType)
      .addFields('Name')
      .debug()
      .addLimit(5)
      .addOffset(0)
      .enforceFLS()
      .run()
      .toString();

    List<SObject> objs = DatabaseUtils.getRecords(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Account.SObjectType)
      .addFields('Name')
      .debug()
      .addLimit(5)
      .addOffset(0)
      .enforceFLS()
      .run()
      .toString();

    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    //with child Object
    q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .queryLookup('Account')
      .addFields()
      .run()
      .addLimit(5)
      .addOffset(0)
      .toString(true);

    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .buildLookUp('Account')
      .addLimit(5)
      .addOffset(0)
      .toString(true);

    objs = DatabaseUtils.getRecordsBySharing(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Contact.SObjectType)
      .addFields(new List<String>{ 'Name', 'LastName', 'FirstName' })
      .queryLookup('Account')
      .addFields(new List<String>{ 'Name', 'BillingStreet', 'BillingCity' })
      .queryLookup('LastModifiedBy')
      .addFields()
      .run()
      .run()
      .enforceFLS()
      .toString(true);

    objs = DatabaseUtils.getRecordsBySharing(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Contact.SObjectType)
      .addFields(new List<String>{ 'Name', 'LastName', 'FirstName' })
      .queryLookup('AccountID', true)
      .addFields('Name,BillingStreet,BillingCity')
      .run()
      .toString(true);

    objs = DatabaseUtils.getRecordsByStrip(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    //Security  Enforce
    q = Query.newInstance(Contact.SObjectType)
      .addFields(new List<String>{ 'Name', 'LastName', 'FirstName' })
      .queryLookup('AccountID', true)
      .addFields('Name,BillingStreet,BillingCity')
      .run()
      .enforceFLS()
      .toString(true);

    objs = DatabaseUtils.getRecordsByStrip(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    // Child Relationship Testing
    q = Query.newInstance(Account.SObjectType)
      .addFields()
      .queryChild('Contacts')
      .addFields()
      .queryLookup('Account')
      .addFields()
      .run()
      .run()
      .toString(true);

    objs = DatabaseUtils.getRecordsByStrip(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    // FieldSet Implementation

    q = Query.newInstance(Account.SObjectType)
      //.addFieldset('CustomField')
      .queryChild('Contacts')
      //.addFieldset('CustomField')
      .run()
      .toString(true);

    objs = DatabaseUtils.getRecordsByStrip(q, null);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Account.SObjectType)
      //.addFieldset('CustomField')
      .toString(true);

    objs = DatabaseUtils.getRecordsByStrip(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    //using run time binding values
    q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
      .queryLookup('Account')
      .addFields('Name')
      .queryLookup('LastModifiedBy')
      .run()
      .run()
      .whereCon('FirstName', '={0}')
      .andCon()
      .whereCon('LastName', '={1}')
      .toString(true);

    objs = DatabaseUtils.getRecords(
      q,
      new List<Object>{ 'FirstName', 'LastName' }
    );
    System.assertEquals(1, objs.size(), 'Failed to build query');

    objs = DatabaseUtils.getRecordsByStrip(
      q,
      new List<Object>{ 'FirstName', 'LastName' }
    );
    System.assertEquals(1, objs.size(), 'Failed to build query');

    objs = DatabaseUtils.getRecordsBySharing(
      q,
      new List<Object>{ 'FirstName', 'LastName' }
    );
    System.assertEquals(1, objs.size(), 'Failed to build query');
    //using order by

    q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
      .orderBy('Name')
      .orderBy('LastName', true)
      .toString(true);
    objs = DatabaseUtils.getRecordsByStrip(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
      .orderBy('Name')
      .orderBy('LastName', true, true)
      .toString(true);
    objs = DatabaseUtils.getRecordsByStrip(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    //remove fields
    q = Query.newInstance(Contact.SObjectType)
      .addFields(new List<String>{ 'Name', 'LastName', 'FirstName' })
      .removeFields(new List<String>{ 'LastName', 'FirstName' })
      .toString(true);
    objs = DatabaseUtils.getRecordsByStrip(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Contact.SObjectType)
      .addFields('Name,LastName,FirstName')
      .removeFields('LastName,FirstName')
      .toString(true);
    objs = DatabaseUtils.getRecordsByStrip(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    //Group by and having

    q = Query.newInstance(Opportunity.SObjectType)
      .addFields('CampaignId, AVG(Amount)')
      .groupBy('CampaignId')
      .havingCon(' AVG(Amount) > 100 And  AVG(Amount) <20000000')
      .toString(true);
    List<AggregateResult> agr = (List<AggregateResult>) DatabaseUtils.getRecordsByStrip(
      q
    );
    System.assertEquals(0, agr.size(), 'Failed to build query');

    //Multiple object example
    q = Query.newInstance(Opportunity.SObjectType)
      .addFields('Name')
      .queryLookup('Account')
      .addFields('Name')
      .run()
      .queryChild('OpportunityLineItems')
      .addFields('Name')
      .run()
      .queryChild('OpportunityContactRoles')
      .addFields()
      .run()
      .enforceFLS()
      .toString(true);
    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    //Using includes on soql
    try {
      q = Query.newInstance(Opportunity.SObjectType)
        .addFields('Name')
        .whereIncludes('testfield__c', new List<String>{ 'one', 'two' })
        .toString(true);
      objs = DatabaseUtils.getRecords(q);
    } catch (Exception ex) {
      System.assertEquals(1, objs.size(), 'Failed to build query');
    }

    try {
      q = Query.newInstance(Opportunity.SObjectType)
        .addFields('Name')
        .whereIncludes('testfield__c', 'one;two,three')
        .toString(true);
      objs = DatabaseUtils.getRecords(q);
    } catch (Exception e) {
      System.assertEquals(1, objs.size(), 'Failed to build query');
    }

    //Using Distance on soql
    q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .whereDistance(
        'MailingAddress',
        Location.newInstance(28.635308, 77.22496),
        'mi',
        '<500'
      )
      .orderByDistance(
        'MailingAddress',
        Location.newInstance(28.635308, 77.22496),
        'mi'
      )
      .toString(true);
    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(0, objs.size(), 'Failed to build query');

    // Using Like in soql
    q = Query.newInstance(Account.SObjectType)
      .addFields('Name')
      .whereLeftLike('Name', 'Name')
      .toString(true);
    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Account.SObjectType)
      .addFields('Name')
      .whereRightLike('Name', 'Account')
      .toString(true);
    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Account.SObjectType)
      .addFields('Name')
      .whereLike('Name', 'account')
      .toString(true);
    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');
    // SQOL One short build

    q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .buildLookUp('Account')
      .toString(true);
    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Account.SObjectType)
      .addFields()
      .buildChild('Contacts')
      .toString(true);
    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    //where conditions

    q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
      .whereCon('LastName=\'Rogers\'')
      .andCon()
      .whereCon('FirstName', '={0}')
      .toString(true);
    objs = DatabaseUtils.getRecords(q, new List<Object>{ 'FirstName' });
    System.assertEquals(0, objs.size(), 'Failed to build query');

    q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
      .whereCon('LastName=\'LastName\'')
      .toString(true);
    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
      .whereCon('LastName', '=\'Rogers\'', false)
      .toString(true);
    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(0, objs.size(), 'Failed to build query');

    q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
      .whereCon('LastName', '=\'Rogers\'', false)
      .toString(true);
    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(0, objs.size(), 'Failed to build query');

    q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
      .whereAnd('LastName', '={0}')
      .whereAnd('LastName', '=\'Lastname\'', false)
      .whereCon('FirstName', '={1}')
      .toString(true);
    objs = DatabaseUtils.getRecords(
      q,
      new List<Object>{ 'LastName', 'FirstName' }
    );
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
      .whereAnd('LastName', '=\'LastName\'', false)
      .whereCon('FirstName', '={0}')
      .toString(true);
    objs = DatabaseUtils.getRecords(q, new List<Object>{ 'FirstName' });
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
      .grpOpen()
      .whereCon('LastName', '={0}')
      .orCon()
      .whereCon('FirstName', '={1}')
      .grpClose()
      .toString(true);
    objs = DatabaseUtils.getRecords(
      q,
      new List<Object>{ 'LastName', 'FirstName' }
    );
    System.assertEquals(1, objs.size(), 'Failed to build query');
  }

  private static void soqlSample3() {
    makeData();

    //validate maximum parameter
    String q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
      .WhereOr('LastName', '={0}')
      .WhereOr('LastName', '={1}')
      .WhereOr('LastName', '={2}')
      .WhereOr('LastName', '={3}')
      .WhereOr('LastName', '={4}')
      .WhereOr('LastName', '={5}')
      .toString(true);

    List<Object> paramter = new List<Object>{
      'LastName',
      'LastName',
      'LastName',
      'LastName',
      'LastName',
      'LastName'
    };

    List<SObject> objs = DatabaseUtils.getRecords(q, paramter);
    objs = DatabaseUtils.getRecordsBySharing(q, paramter);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    //SOQL by ID

    q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .queryById(objs[0].get('Id'));
    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .orderBy('Name', true)
      .toString(true);
    objs = DatabaseUtils.getRecords(q);
    System.assertEquals(1, objs.size(), 'Failed to build query');

    System.assertNotEquals(q, null, 'Failed to build query');
  }

  @IsTest
  private static void exceptionCase() {
    Test.startTest();

    //soql on invalid relationship filed name
    try {
      String q = Query.newInstance(Account.SObjectType)
        .queryLookup('InvalidFieldName', true)
        .run()
        .toString();
    } catch (Exception e) {
      Boolean expectedExceptionThrown = e.getMessage()
          .contains('Not found for Account.InvalidFieldName')
        ? true
        : false;
      System.AssertEquals(expectedExceptionThrown, true);
    }

    // soql on invalid relationship name
    try {
      String q = Query.newInstance(Account.SObjectType)
        .queryLookup('InvalidFieldName')
        .run()
        .toString();
    } catch (Exception e) {
      Boolean expectedExceptionThrown = e.getMessage()
          .contains('Not found for Account.InvalidFieldName')
        ? true
        : false;
      System.AssertEquals(expectedExceptionThrown, true);
    }

    // soql on invalid child relationship name
    try {
      String q = Query.newInstance(Account.SObjectType)
        .queryChild('InvalidFieldName')
        .run()
        .toString();
    } catch (Exception e) {
      Boolean expectedExceptionThrown = e.getMessage()
          .contains('Not found for Account.InvalidFieldName')
        ? true
        : false;
      System.AssertEquals(expectedExceptionThrown, true);
    }

    // Nested Child query not allowed
    try {
      String q = Query.newInstance(Contact.SObjectType)
        .queryLookup('Account')
        .QueryChild('Contacts')
        .run()
        .run()
        .toString();
    } catch (Exception e) {
      Boolean expectedExceptionThrown = e.getMessage().contains('Not found for')
        ? true
        : false;
      System.AssertEquals(expectedExceptionThrown, true);
    }

    Test.stopTest();
  }
}
