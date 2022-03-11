/**
 * Copyright (c) 2021 Digital Align
 * @group Utils Handler
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global abstract with sharing class AbstractTriggerHandler {
  //shared attribute
  global static Map<String, Object> sharedMap = new Map<String, Object>();
  protected Type classType = AbstractService.class;
  protected logger log;
  public AbstractTriggerHandler() {
    classType = AbstractService.class;
    log = logger.getInstance(classType);
  }

  public AbstractTriggerHandler(Type classType) {
    this.classType = classType;
    log = logger.getInstance(this.classType);
  }

  /**
   * These methods are all intended to be overridden by
   * individual trigger handlers. They exist here only to
   * establish the 'software contract' that they exist.
   */

  /**
   * @description Virtual method for the implementing class to override
   * Before insert trigger has Trigger.New
   */
  @testVisible
  @SuppressWarnings('PMD.EmptyStatementBlock')
  global virtual void beforeInsert() {
  }
  /**
   * @description Virtual method for the implementing class to override
   * Before updtae trigger has Trigger.New,Trigger.Old,Trigger.newMap and Trigger.oldMap
   */
  @testVisible
  @SuppressWarnings('PMD.EmptyStatementBlock')
  global virtual void beforeUpdate() {
  }
  /**
   * @description Virtual method for the implementing class to override
   */
  @testVisible
  @SuppressWarnings('PMD.EmptyStatementBlock')
  global virtual void beforeDelete() {
  }
  /**
   * @description Virtual method for the implementing class to override
   * after insert trigger has Trigger.New,Trigger.Old
   */
  @testVisible
  @SuppressWarnings('PMD.EmptyStatementBlock')
  global virtual void afterInsert() {
  }
  /**
   * @description Virtual method for the implementing class to override
   * after updtae trigger has Trigger.New,Trigger.Old,Trigger.newMap and Trigger.oldMap
   */
  @testVisible
  @SuppressWarnings('PMD.EmptyStatementBlock')
  global virtual void afterUpdate() {
  }
  /**
   * @description Virtual method for the implementing class to override
   */
  @testVisible
  @SuppressWarnings('PMD.EmptyStatementBlock')
  global virtual void afterDelete() {
  }
  /**
   * @description Virtual method for the implementing class to override
   */
  @testVisible
  @SuppressWarnings('PMD.EmptyStatementBlock')
  global virtual void afterUndelete() {
  }

  /**
   * By bass Trigger methods
   */

  /**
   * @description Allows developers to conditionally bypass (disable)
   * other triggers that *also* implement this triggerHandler
   * @param handlerName Class name (String) of the trigger handler to bypass
   * @example
   * this.bypass('AccountTriggerHandler');
   */
  global void bypass(String handlerName) {
    TriggerDispatcher.bypass(handlerName);
  }

  /**
   * @description Removes a given trigger handler class name from
   * the list of bypassed trigger handlers.
   * @param handlerName Handler class name to remove from the bypass list
   * @example
   * this.clearBypass('AccountTriggerHandler');
   */
  global void clearBypass(String handlerName) {
    TriggerDispatcher.clearBypass(handlerName);
  }

  /**
   * @description Allows developers to check whether a given trigger
   * handler class is currently bypassed.
   * @param handlerName The name of the trigger handler class to check for
   * @return `Boolean`
   * @example
   * this.isBypassed('AccountTriggerHandler');
   */
  global Boolean isBypassed(String handlerName) {
    return TriggerDispatcher.isBypassed(handlerName);
  }

  /**
   * @description removes all classes from the bypass list
   * @example
   * this.clearAllBypasses();
   */
  global void clearAllBypasses() {
    TriggerDispatcher.clearAllBypasses();
  }

  /**
   * @description
   * @author Digital Align | 06-05-2021
   * @param Map<Id SObject> newRecords
   * @param Map<Id SObject> oldRecords
   * @return Set<Id>
   **/
  global Set<Id> filterUnchangedRecords(Map<Id, SObject> newRecords, Map<Id, SObject> oldRecords) {
    Set<Id> changedRecordIds = new Set<Id>();
    for (Id recordId : newRecords.keySet()) {
      if (newRecords.get(recordId).clone(false, false, false) != oldRecords.get(recordId).clone(false, false, false)) {
        changedRecordIds.add(recordId);
      }
    }
    return changedRecordIds;
  }
}
