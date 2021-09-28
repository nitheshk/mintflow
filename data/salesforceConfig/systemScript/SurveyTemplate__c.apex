String q = new Query(SurveyTemplate__c.SObjectType)
  .addFields()
  .queryChild('SurveyTemplateItems__r')
  .addFields()
  .orderBy('Order__c')
  .run()
  .toString(true);
List<SurveyTemplate__c> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
