delete [SELECT id FROM account WHERE name = 'init'];

String q = new Query(Account.SObjectType)
  .addFields('Name')
  .queryChild('AccountContactRelations')
  .addFields()
  //.queryLookup('Contact')
  //.addFields()
  //.removeFields('AccountId,CleanStatus')
  //.run()
  .run()
  .whereEq('Name', 'Init')
  .addLimit(1)
  .toString();
List<Account> sl = (List<Account>) DatabaseUtils.getRecords(q);
system.debug('all : ' + system.JSON.Serialize(sl));

Map<String, Object> mp = new Map<String, Object>();
mp.put('put', 'test');
mp.put('put1', 'test1');
mp.put('sl', sl);

// constructor
String accountJson = '{"attributes":{"type":"Account","url":"/services/data/v52.0/sobjects/Account/0011y00000NMYupAAH"},"Name":"Init","Id":"0011y00000NMYupAAH"}';
String accountRelJson = '[{"attributes":{"type":"AccountContactRelation","url":"/services/data/v52.0/sobjects/AccountContactRelation/07k1y000004B9LYAA0"},"AccountId":"0011y00000NMYupAAH","Id":"07k1y000004B9LYAA0","ContactId":"0031y00000HkuwgAAB","Roles":"Business User","IsDirect":false,"IsActive":true,"StartDate":"2021-10-06","IsDeleted":false,"FinServ__IncludeInGroup__c":false,"FinServ__PrimaryGroup__c":true,"FinServ__Primary__c":true,"FinServ__Rollups__c":"All"}]';

Account acc = (Account) JSON.deserialize(accountJson, Account.class);
List<AccountContactRelation> accRel = (List<AccountContactRelation>) JSON.deserialize(
  accountRelJson,
  List<AccountContactRelation>.class
);

Map<String, Object> mp = (Map<String, Object>) JSON.deserializeUntyped(
  Json.Serialize(acc)
);
mp.put(
  'AccountContactRelations',
  new Map<String, Object>{
    'totalSize' => accRel.size(),
    'done' => true,
    'records' => accRel
  }
);

system.debug('val : ' + mp.get('Name'));

acc = (Account) JSON.deserialize(Json.Serialize(mp), Account.class);

system.debug('acc : ' + JSON.Serialize(acc));
//

String accountJson = '{"attributes":{"type":"Account","url":"/services/data/v52.0/sobjects/Account/0011y00000NMYupAAH"},"Name":"Init","Id":"0011y00000NMYupAAH"}';
String accountRelJson = '[{"attributes":{"type":"AccountContactRelation","url":"/services/data/v52.0/sobjects/AccountContactRelation/07k1y000004B9LYAA0"},"AccountId":"0011y00000NMYupAAH","Id":"07k1y000004B9LYAA0","ContactId":"0031y00000HkuwgAAB","Roles":"Business User","IsDirect":false,"IsActive":true,"StartDate":"2021-10-06","IsDeleted":false,"FinServ__IncludeInGroup__c":false,"FinServ__PrimaryGroup__c":true,"FinServ__Primary__c":true,"FinServ__Rollups__c":"All"}]';

Account acc = (Account) JSON.deserialize(accountJson, Account.class);
List<AccountContactRelation> accRel = (List<AccountContactRelation>) JSON.deserialize(
  accountRelJson,
  List<AccountContactRelation>.class
);

Account acc1 = (Account) dau01.SObjectConstructor.getInstance(acc)
  .addChildObjects('AccountContactRelations', accRel)
  .build();
system.debug('acc : ' + JSON.Serialize(acc1));

//
//
//
//
String q = new Query(Account.SObjectType)
  .addFields('Name')
  .queryChild('FinServ__HouseholdFinancialAccounts__r')
  .addFields('FinServ__PrimaryOwner__r.PersonContactId')
  .run()
  .whereEq('Name', 'Init')
  .toString();

List<Account> sl1 = (List<Account>) DatabaseUtils.getRecords(q);

String pa = sl1[0]
  .FinServ__HouseholdFinancialAccounts__r[0]
  .FinServ__PrimaryOwner__c;

q = new Query(Account.SObjectType)
  .addFields()
  .queryChild('FinServ__Employment__pr')
  .addFields()
  .run()
  .whereEq('Id', pa)
  .andCon()
  .whereEq('isPersonAccount ', true)
  .toString();

List<Account> sl2 = (List<Account>) DatabaseUtils.getRecords(q);

FinServ__FinancialAccount__c fa = (FinServ__FinancialAccount__c) dau01.SObjectConstructor.getInstance(
    sl1[0].FinServ__HouseholdFinancialAccounts__r[0]
  )
  .setLookupObject('FinServ__PrimaryOwner__r', sl2[0])
  .build();

Account acc = (Account) dau01.SObjectConstructor.getInstance(sl1[0])
  .setChildObject('FinServ__HouseholdFinancialAccounts__r', fa)
  .build();

system.debug('acc : ' + JSON.Serialize(acc));
