String q = new Query(dau01__SystemSetting__c.SObjectType)
  .addFields()
  .toString(true);
List<dau01__SystemSetting__c> sl = DatabaseUtils.getRecords(q);
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
