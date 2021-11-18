

 // Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

SOQL TESTING SAMPLE



/** Updated SOQL */
// New Updated

Example 18 - Different way of Where Conditions   can written 

String FirstName='Tim';
String q = Query.newInstance(Contact.SObjectType)
    .addFields('Name')
    .whereEq('LastName','Barr')
    .AndCon()
    .whereEq('FirstName',FirstName)
    .toString(true);
  List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
  system.debug(system.JSON.Serialize(sl));


  String q = Query.newInstance(Contact.SObjectType)
    .addFields('Name')
    .whereNotNull('FirstName')
    .toString(true);
  List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
  system.debug(system.JSON.Serialize(sl));


String q = Query.newInstance(Contact.SObjectType)
    .addFields('Name')
    .whereEq('FinServ__CreatedFromLead__c',false)
    .toString(true);
  List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
  system.debug(system.JSON.Serialize(sl));


  String q = Query.newInstance(Contact.SObjectType)
    .addFields('Name')
    .whereLT('CreatedDate', DateTime.now())
    .toString(true);
  List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
  system.debug(system.JSON.Serialize(sl));


Example 19- using IN SOQL
 
String q = Query.newInstance(Account.SObjectType)
    .addFields('Name')
    .whereIn('Id', 
    Query.newInstance(Contact.SObjectType).addFields('AccountId').whereEq('FirstName','Tim').toString()    
    )
    .toString(true);
  List<Account> sl =(List<Account> ) DatabaseUtils.getRecords(q);
  system.debug(system.JSON.Serialize(sl));

Example 20- using In Conditions

//Using SObject
  List<Contact> sl = (List<Contact> )DatabaseUtils.getRecords(Query.newInstance(Contact.SObjectType).addLimit(2).toString());
  String q = Query.newInstance(Contact.SObjectType)
    .addFields('Name')
    .whereIn('Id', sl)
    .toString(true);
    sl =(List<Contact> ) DatabaseUtils.getRecords(q);
  system.debug(system.JSON.Serialize(sl));

  //Using Set
  List<Contact> sl = (List<Contact> )DatabaseUtils.getRecords(Query.newInstance(Contact.SObjectType).addLimit(2).toString());
  String q = Query.newInstance(Contact.SObjectType)
    .addFields('Name')
    .whereIn('Id', new Map<id,sObject>(sl).keyset())
    .toString(true);
    sl =(List<Contact> ) DatabaseUtils.getRecords(q);
  system.debug(system.JSON.Serialize(sl));

//Using List
List<Contact> sl = (List<Contact> )DatabaseUtils.getRecords(Query.newInstance(Contact.SObjectType).addLimit(2).toString());
  String q = Query.newInstance(Contact.SObjectType)
    .addFields('Name')
    .whereIn('Id', new List<id>(new Map<id,sObject>(sl).keyset()))
    .toString(true);
    sl =(List<Contact> ) DatabaseUtils.getRecords(q);
  system.debug(system.JSON.Serialize(sl));


// Old Scripts

Example-1: Simple soql

    String q = Query.newInstance(Account.SObjectType)
      .addFields()
      .debug()
      .addLimit(5)
      .addOffset(5)
      .run()
      //.enforceFLS()
      .toString();
    //List<Account> sl = Database.query(q);
    List<Account> sl =DatabaseUtils.getRecords(q);
    system.debug(system.JSON.Serialize(sl));


     String q = Query.newInstance(Account.SObjectType)
      .addFields()
      .debug()
      .addLimit(5)
      .addOffset(5)
      .run()
      //.enforceFLS()
      .toString();
    //List<Account> sl = Database.query(q);
    List<Account> sl =DatabaseUtils.getRecords(q);

Example-2: with child Object

   String q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .queryLookup('Account')
      .addFields()
      .run()
      .addLimit(5)
      .addOffset(5)
      //.enforceFLS()
      .toString(true);
    List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);


    String q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .buildLookUp('Account')
      .addLimit(5)
      .addOffset(5)
      //.enforceFLS()
      .toString(true);
    List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);


example-3 :

    String q = Query.newInstance(Contact.SObjectType)
      .addFields(new List<String>{'Name','LastName','FirstName'})
        .queryLookup('Account')
        .addFields(new List<String>{'Name','BillingStreet','BillingCity'})
          .queryLookup('LastModifiedBy')
          .addFields()
          .run()
        .run()
      .addLimit(5)
      .addOffset(5)
      .toString(true);
    List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
    system.debug(sl[0].account.LastModifiedBy.Name);


example-4 :

    String q = Query.newInstance(Contact.SObjectType)
      .addFields(new List<String>{'Name','LastName','FirstName'})
        .queryLookup('AccountID',true)
        .addFields('Name,BillingStreet,BillingCity')
        .run()
      .addLimit(5)
      .addOffset(5)
      .toString(true);
    List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);


Example-5 : Security  Enforce

 String q = Query.newInstance(Contact.SObjectType)
      .addFields(new List<String>{'Name','LastName','FirstName'})
        .queryLookup('AccountID',true)
        .addFields('Name,BillingStreet,BillingCity')
        .run()
      .addLimit(5)
      .addOffset(5)
      .enforceFLS()
      .toString(true);
    List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);

Example-6: Child Relationship Testing

  String q = Query.newInstance(Account.SObjectType)
      .addFields()
        .queryChild('Contacts')
        .addFields()
          .queryLookup('Account')
          .addFields()
          .run()
        .run()
      .addLimit(5)
      .addOffset(5)
      //.enforceFLS()
      .toString(true);
  List<Account> sl =(List<Account> ) DatabaseUtils.getRecords(q);


Example-7:  FieldSet Implementation

String q = Query.newInstance(Account.SObjectType)
      //.addFieldset('CustomField')
        .queryChild('Contacts')
        //.addFieldset('CustomField')
        .run()
      .addLimit(5)
      .addOffset(5)
      .toString(true);
  List<Account> sl =(List<Account> ) DatabaseUtils.getRecords(q);


   String q = Query.newInstance(Account.SObjectType)
      .addFieldset('CustomField')
      .toString(true);
    List<Account> sl =DatabaseUtils.getRecords(q);



Example-8: using run time binding values

  String lastName= 'Rogers';
  List<Object> parameters = new List<Object> {lastName,'Jack' };

  String q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
        .queryLookup('Account')
        .addFields('Name')
          .queryLookup('LastModifiedBy')
          .run()
        .run()
      .whereCon('LastName','={0}')
      .andCon()
      .whereCon('FirstName','={1}')
      .toString(true);
    List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q,parameters);
    system.debug(system.JSON.Serialize(sl));


Example-8: using order by

  String q = Query.newInstance(Contact.SObjectType)
      .addFields('Name')
      .orderBy('Name')
      .orderBy('LastName',True)
      .toString(true);
  List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);


Exmaple-9 : remove fields

String q = Query.newInstance(Contact.SObjectType)
      .addFields(new List<String>{'Name','LastName','FirstName'})
      .removeFields(new List<String>{'LastName','FirstName'})
      .toString(true);
  List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);

  String q = Query.newInstance(Contact.SObjectType)
      .addFields('Name,LastName,FirstName')
      .removeFields('LastName,FirstName')
      .toString(true);
  List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);



exmaple-9 Group by and having

 String q = Query.newInstance(Opportunity.SObjectType)
      .addFields('CampaignId, AVG(Amount)')
      .groupBy('CampaignId')
      .havingCon(' AVG(Amount) > 100 And  AVG(Amount) <20000000')
      .toString(true);
  AggregateResult[] groupedResults =  DatabaseUtils.getRecords(q);

  for (AggregateResult ar : groupedResults)  {
    System.debug('Campaign ID' + ar.get('CampaignId'));
    System.debug('Average amount' + ar.get('expr0'));
  }



exmaple-10  Multiple object example

String q = Query.newInstance(Opportunity.SObjectType)
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
    List<Opportunity> sl =(List<Opportunity> ) DatabaseUtils.getRecords(q);
    system.debug(system.JSON.Serialize(sl));


Example-11 Using includes on soql

String q = Query.newInstance(Opportunity.SObjectType)
      .addFields('Name')
      .whereIncludes('testfield__c',new list<String> {'one','two'})
      .toString(true);
    List<Opportunity> sl =(List<Opportunity> ) DatabaseUtils.getRecords(q);
    system.debug(system.JSON.Serialize(sl));


String q = Query.newInstance(Opportunity.SObjectType)
      .addFields('Name')
      .whereIncludes('testfield__c','one;two,three')
      .toString(true);
    List<Opportunity> sl =(List<Opportunity> ) DatabaseUtils.getRecords(q);
    system.debug(system.JSON.Serialize(sl));



 example-12  Using Distance on soql

 String q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .whereDistance('MailingAddress', Location.newInstance(28.635308,77.22496)  , 'mi','<500')
      .orderByDistance('MailingAddress',Location.newInstance(28.635308,77.22496),  'mi',true)
      .toString(true);
    List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
    system.debug(system.JSON.Serialize(sl));


Example 13- Using Like in soql

  String q = Query.newInstance(Account.SObjectType)
          .addFields('Name')
          .whereLeftLike('Name','Burlington')
          .toString(true);
  List<Account> sl =(List<Account> ) DatabaseUtils.getRecords(q);
  system.debug(system.JSON.Serialize(sl));


Example 14-  SQOL One short build

String q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .buildLookUp('Account')
      .toString(true);
    List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);


String q = Query.newInstance(Account.SObjectType)
      .addFields()
      .buildChild('Contacts')
      .toString(true);
    List<Account> sl =(List<Account> ) DatabaseUtils.getRecords(q);


Example 15- where condition without limitation, free to add your custom condition

List<Object> parameters = new List<Object> {'Jack Rogers','Rogers','Jack'};
String q = Query.newInstance(Contact.SObjectType)
    .addFields('Name')
    .whereCon('LastName=\'Rogers\'')
    .andCon()
    .whereCon('FirstName','={2}')
    .toString(true);
  List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q,parameters);
  system.debug(system.JSON.Serialize(sl));


String q = Query.newInstance(Contact.SObjectType)
    .addFields('Name')
    .whereCon('LastName=\'Rogers\'')
    .toString(true);
  List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
  system.debug(system.JSON.Serialize(sl));



  List<Object> parameters = new List<Object> {'Rogers'};
   String q = Query.newInstance(Contact.SObjectType)
    .addFields('Name')
    .whereCon('LastName','={\'Rogers\'}',false)
    .toString(true);
    List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q,parameters);
  system.debug(system.JSON.Serialize(sl));



  List<Object> parameters = new List<Object> {'Jack Rogers','Rogers','Jack'};
  String q = Query.newInstance(Contact.SObjectType)
    .addFields('Name')
    .whereOr('LastName','={1}')
    .whereCon('FirstName','={2}')
    .toString(true);
  List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q,parameters);
  system.debug(system.JSON.Serialize(sl));


  List<Object> parameters = new List<Object> {'Jack Rogers','Rogers','Jack'};
  String q = Query.newInstance(Contact.SObjectType)
    .addFields('Name')
    .whereAnd('LastName','=\'Rogers\'',true)
    .whereCon('FirstName','={2}')
    .toString(true);
  List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q,parameters);
  system.debug(system.JSON.Serialize(sl));


  Example 16 - SOQL by ID

    String q = Query.newInstance(Contact.SObjectType)
          .addFields()
          .queryById('0030w00000bmCut');
    List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
    system.debug(system.JSON.Serialize(sl));

  Exmaple 17 - Order By clause


  String q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .orderBy('Name',true)
      .toString(true);
   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);



list<Contact> lst=new  List<Contact> {new Contact()};
system.debug(SecurityUtils.crud(lst,crudType.UPDATABLE));


