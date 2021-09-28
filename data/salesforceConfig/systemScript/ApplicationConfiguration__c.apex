String q = new Query(ApplicationConfiguration__c.SObjectType)
  .addFields()
  .toString(true);
List<ApplicationConfiguration__c> sl = DatabaseUtils.getRecords(q);
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
