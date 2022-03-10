String q = Query.newInstance(mflow__ReferralProduct__c.SObjectType)
  .addFields()
  .queryLookup('mflow__CrossSellProduct__r')
  .addFields('mflow__InternalCode__c')
  .run()
  .queryLookup('mflow__FinancialProduct__r')
  .addFields('mflow__InternalCode__c')
  .run()
  .run()
  .toString(true);
List<mflow__ReferralProduct__c> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
