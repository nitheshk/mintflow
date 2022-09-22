String q = Query.newInstance(mflow__CountryAndStateNames__c.SObjectType).addFields().toString(true);
List<mflow__CountryAndStateNames__c> sl = DatabaseUtils.getRecords(q);
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
