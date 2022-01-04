String q = Query.newInstance(mflow__SurveyTemplate__c.SObjectType)
  .addFields()
  .queryChild('mflow__SurveyQuestions__r')
  .addFields()
  .orderBy('mflow__Order__c')
  .run()
  .toString(true);
List<mflow__SurveyTemplate__c> sl = DatabaseUtils.getRecords(q);
//**Include below system.debug statement always for every script file**
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
