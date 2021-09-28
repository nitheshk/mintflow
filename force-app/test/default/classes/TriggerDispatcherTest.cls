/**
 * Copyright (c) 2021 Digital Align
 * @group Test
 * @author Digital Align Team
 * @reference
 * @description
 **/
@IsTest
public with sharing class TriggerDispatcherTest {
  @IsTest
  private static void triggerHanlder() {
    String handlerName = 'AccountTriggerHandler';
    SObjectTriggerSetting__mdt triggerSetting = new SObjectTriggerSetting__mdt();
    triggerSetting.ObjectAPIName__c = 'Account';
    triggerSetting.TriggerHandlerName__c = 'AccountTriggerHandler';
    triggerSetting.RecursionCount__c = 4;

    TriggerDispatcher.run(Account.SObjectType);
    TriggerDispatcher.executeTriggerAction(triggerSetting, null);
    TriggerDispatcher.setMaxLoopCount(handlerName, 4);
    TriggerDispatcher.validateRun(handlerName);
    TriggerDispatcher.validateRun('Random');
    TriggerDispatcher.removeFromLoopCount(handlerName);
    TriggerDispatcher.bypass(handlerName);
    TriggerDispatcher.clearBypass(handlerName);
    TriggerDispatcher.isBypassed(handlerName);
    TriggerDispatcher.clearAllBypasses();
    TriggerDispatcher.loopCountMap.get(handlerName).setMax(4);
    TriggerDispatcher.loopCountMap.get(handlerName).increment();
    TriggerDispatcher.loopCountMap.get(handlerName).decrement();
    TriggerDispatcher.loopCountMap.get(handlerName).getCount();
    system.assertEquals(
      false,
      TriggerDispatcher.loopCountMap.get(handlerName).exceeded()
    );
  }
}
