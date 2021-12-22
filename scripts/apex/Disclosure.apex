// #1 Testing fileter Option
DisclosureLineItem__c item = new DisclosureLineItem__c();
item.Name = 'Test1';
//item.mflow__test1__c = 43;
item.mflow__Product__c = '';
item.mflow__test2__c = 'test3';
insert item;

String jsonString = '[{"Name":"Test12","$Name":"!=", "mflow__test2__c":["test3","test4"],"$mflow__test2__c":"INCLUDES", "mflow__EventIdentifier__c":"","mflow__isActive__c":true,"mflow__test1__c":43, "mflow__Product__c":""}, {"Name":"Test1","mflow__EventIdentifier__c":"","mflow__isActive__c":true}]';
List<Object> filters = (List<Object>) JSON.deserializeUntyped(jsonString);
List<DisclosureLineItem__c> items = (List<DisclosureLineItem__c>) EmailNotificationRepository.getRecords(
  Query.newInstance(DisclosureLineItem__c.SObjectType)
    .addFields()
    .filter(filters, 'mflow__Filter')
    .toString(true)
);
system.debug('items :' + items);
