trigger AfterCommitEventTrigger on AfterCommitEvent__e(after insert) {
  TriggerDispatcher.run(AfterCommitEvent__e.SObjectType);
}
