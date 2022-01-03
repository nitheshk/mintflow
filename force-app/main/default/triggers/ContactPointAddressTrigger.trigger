/**
 * Copyright (c) 2021 Digital Align
 * @group Trigger
 * @author Digital Align Team
 * @reference
 * @description
 * 1. To Insert/update state field with state full name
 **/
trigger ContactPointAddressTrigger on ContactPointAddress(
  before insert,
  before update
) {
  TriggerDispatcher.run(ContactPointAddress.SObjectType);
}
