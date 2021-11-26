String q = new Query(mflow__ApplicationConfiguration__c.SObjectType)
  .addFields()
  .toString(true);
List<mflow__ApplicationConfiguration__c> sl = DatabaseUtils.getRecords(q);
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
