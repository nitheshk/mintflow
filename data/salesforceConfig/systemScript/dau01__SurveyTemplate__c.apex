String q = new Query(dau01__SurveyTemplate__c.SObjectType)
  .addFields()
  .queryChild('dau01__SurveyTemplateItems__r')
  .addFields()
  .orderBy('dau01__Order__c')
  .run()
  .toString(true);
List<dau01__SurveyTemplate__c> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
