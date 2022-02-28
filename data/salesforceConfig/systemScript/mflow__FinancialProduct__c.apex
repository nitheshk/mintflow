String q = Query.newInstance(mflow__FinancialProduct__c.SObjectType)
  .addFields()
  .queryChild('mflow__ProductServices__r')
  .addFields()
  .run()
  .toString(true);
List<mflow__FinancialProduct__c> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
