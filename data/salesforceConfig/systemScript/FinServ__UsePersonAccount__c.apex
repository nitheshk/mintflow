String q = new Query(FinServ__UsePersonAccount__c.SObjectType)
  .addFields()
  .addLimit(1)
  .toString(true);
List<FinServ__UsePersonAccount__c> sl = DatabaseUtils.getRecords(q);
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
