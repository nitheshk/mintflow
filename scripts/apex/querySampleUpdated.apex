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
