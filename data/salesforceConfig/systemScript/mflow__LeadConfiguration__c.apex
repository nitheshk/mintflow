String q = Query.newInstance(mflow__LeadConfiguration__c.SObjectType)
  .addFields()
  .toString(true);
List<mflow__LeadConfiguration__c> sl = DatabaseUtils.getRecords(q);
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
