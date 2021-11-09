String q = new Query(dau01__FinancialProduct__c.SObjectType)
  .addFields()
  .addFields()
  .run()
  .toString(true);
List<dau01__FinancialProduct__c> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
