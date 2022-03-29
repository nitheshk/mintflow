String q = Query.newInstance(mflow__ProductService__c.SObjectType)
  .addFields()
  .queryLookup('mflow__FinancialProduct__r')
  .addFields('mflow__InternalCode__c')
  .run()
  .orderBy('mflow__Order__c')
  .toString(true);
List<mflow__ProductService__c> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
