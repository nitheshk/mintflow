String q = Query.newInstance(mflow__SystemSetting__c.SObjectType)
  .addFields()
  .toString(true);
List<mflow__SystemSetting__c> sl = DatabaseUtils.getRecords(q);
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
