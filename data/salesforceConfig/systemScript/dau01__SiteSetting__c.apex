String q = new Query(dau01__SiteSetting__c.SObjectType)
  .addFields()
  .toString(true);
List<dau01__SiteSetting__c> sl = DatabaseUtils.getRecords(q);
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
