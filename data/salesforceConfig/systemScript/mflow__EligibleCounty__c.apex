String q = Query.newInstance(EligibleCounty__c.SObjectType)
  .addFields()
  .toString(true);
List<EligibleCounty__c> sl = DatabaseUtils.getRecords(q);
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
