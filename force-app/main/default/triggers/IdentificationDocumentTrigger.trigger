/**
 * Copyright (c) 2021 Digital Align
 * @group Trigger
 * @author Digital Align Team
 * @reference
 * @description
 * 1. To Insert/Delete ContentConversion Attacted to IdentificationDocument
 **/
trigger IdentificationDocumentTrigger on FinServ__IdentificationDocument__c(
  after insert,
  after update
) {
  TriggerDispatcher.run(FinServ__IdentificationDocument__c.SObjectType);
}
