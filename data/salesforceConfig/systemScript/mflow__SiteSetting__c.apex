String q = new Query(mflow__SiteSetting__c.SObjectType)
  .addFields()
  .toString(true);
List<mflow__SiteSetting__c> sl = DatabaseUtils.getRecords(q);
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
