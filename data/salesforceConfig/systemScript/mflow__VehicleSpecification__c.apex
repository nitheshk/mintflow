String q = Query.newInstance(mflow__VehicleSpecification__c.SObjectType).addFields().toString(true);
List<mflow__VehicleSpecification__c> sl = DatabaseUtils.getRecords(q);
system.debug('{QueryStart} ' + system.JSON.Serialize(sl) + ' {QueryEnd}');
