/**
 * Copyright (c) 2021 Digital Align
 * @group Trigger
 * @author Digital Align Team
 * @reference
 * @description
 * 1. To Insert/update state field with state full name
 **/
trigger AddressTrigger on Address__c(before insert, before update) {
  TriggerDispatcher.run(Address__c.SObjectType);
}
