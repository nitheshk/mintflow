String q = Query.newInstance(mflow__ConsentTemplate__c.SObjectType)
  .addFields()
  .queryChild('mflow__ConsentLineItems__r')
  .addFields()
  .queryLookup('mflow__FinancialProduct__r')
  .addFields('mflow__InternalCode__c')
  .run()
  .run()
  //.orderBy('mflow__Order__c')
  .toString(true);
List<mflow__ConsentTemplate__c> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
