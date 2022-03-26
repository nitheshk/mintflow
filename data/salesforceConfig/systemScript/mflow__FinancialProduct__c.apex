String q = Query.newInstance(mflow__FinancialProduct__c.SObjectType)
  .addFields()
  .queryChild('mflow__ProductServices__r')
  .addFields()
  .orderBy('mflow__Order__c')
  .run()
  .orderBy('mflow__Order__c')
  .toString(true);
List<mflow__FinancialProduct__c> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
