String q = Query.newInstance(mflow__ConsentTemplate__c.SObjectType)
  .addFields()
  .queryChild('mflow__ConsentLineItems__r')
  .addFields()
  .run()
  .toString(true);
List<mflow__ConsentTemplate__c> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
