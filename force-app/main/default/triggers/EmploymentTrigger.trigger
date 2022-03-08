/**
 * Copyright (c) 2021 Digital Align
 * @group Trigger
 * @author Digital Align Team
 * @reference
 * @description
 * 1. To Insert/Delete ContentConversion Attacted to Employment records
 **/
trigger EmploymentTrigger on Employment__c(
  after insert,
  after update,
  before delete
) {
  TriggerDispatcher.run(Employment__c.SObjectType);
}
