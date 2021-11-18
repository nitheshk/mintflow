// #1
String q = new Query(Profile.SObjectType)
  .addFields()
  .whereCon('UserType=\'Standard\'')
  .toString();
List<Profile> sl = DatabaseUtils.getRecords(q);

system.debug(system.JSON.Serialize(sl));

// #2
Account acc = new Account();
acc.Name = 'Account Name';

acc = (Account) DatabaseUtils.insertRecordsBySharing(
  new List<Account>{ acc }
)[0];

// #3

String q = new Query(Account.SObjectType)
  .addFields()
  .whereCon('id=\'0011y00000HpUSMAA3\'')
  .toString();
Account acc = (account) DatabaseUtils.getRecordsByStrip(q)[0];

system.debug(acc.AccountNumber);

acc.AccountNumber = 'test2';

account abc = new Account();
abc.name = 'name';
abc.AccountNumber = 'AccountNumber';

SObjectAccessDecision securityDecision = Security.stripInaccessible(
  AccessType.UPDATABLE,
  new List<Sobject>{ abc },
  true
);

DatabaseUtils.insertRecordsByStrip(new List<Account>{ abc });

system.debug(abc.id);
system.debug(abc.AccountNumber);

// #4
account acc = new Account();
acc.name = 'name';
acc = (Account) DatabaseUtils.insertRecordsBySharing(acc);
