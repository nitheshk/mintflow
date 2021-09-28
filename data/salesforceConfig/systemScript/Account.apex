String q = new Query(Account.SObjectType)
  .addFields()
  .queryChild('Contacts')
  .addFields()
  .run()
  .addLimit(1)
  .toString(true);
List<Account> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
