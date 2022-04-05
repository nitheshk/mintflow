String q = Query.newInstance(mflow__ProductFeature__c.SObjectType)
  .addFields()
  .queryLookup('mflow__ProductService__r')
  .addFields('mflow__ExternalId__c')
  .run()
  .queryLookup('mflow__FinancialProduct__r')
  .addFields('mflow__InternalCode__c')
  .run()
  .whereNeq('mflow__FinancialProduct__c', null)
  .andCon()
  .whereNeq('mflow__ProductService__c', null)
  .toString(true);
List<mflow__ProductFeature__c> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
