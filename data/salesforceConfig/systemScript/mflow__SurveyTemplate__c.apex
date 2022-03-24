String q = Query.newInstance(mflow__SurveyTemplate__c.SObjectType)
  .addFields()
  .queryChild('mflow__SurveyQuestions__r')
  .addFields()
  .orderBy('mflow__Order__c')
  .run()
  .queryLookup('mflow__FinancialProduct__r')
  .addFields('mflow__InternalCode__c')
  .run()
  .orderBy('mflow__Order__c')
  .toString(true);
List<mflow__SurveyTemplate__c> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
