/**
 * Copyright (c) 2021 Digital Align
 * @group Utils Dispatcher
 * @author Digital Align Team
 * @reference
 * @description  An trigger handler framework
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class TriggerDispatcher {
  // static map of handlername, times run() was invoked
  @testVisible
  private static Map<String, LoopCount> loopCountMap;
  private static Set<String> bypassedHandlers;

  // static initialization
  static {
    loopCountMap = new Map<String, LoopCount>();
    bypassedHandlers = new Set<String>();
  }

  /**
   * @description This is main brokering method that is called by the trigger.
   * It's responsible for determining the proper context, and calling the
   * correct method
   * @author Digital Align | 06-05-2021
   * @param Schema.SObjectType sType
   **/
  global static void run(Schema.SObjectType sType) {
    String sObjectName = sType.getDescribe().getName();
    for (SObjectTriggerSetting__mdt triggerSetting : TriggerRepository.fetchTriggerSettingBySobject(sObjectName)) {
      //Driving from metadata

      Type classType = Type.forName(triggerSetting.TriggerHandlerName__c);
      if (classType == null) {
        throw new SObjectException('Class has not defined : ' + triggerSetting.TriggerHandlerName__c);
      }
      TriggerDispatcher.executeTriggerAction(triggerSetting, (AbstractTriggerHandler) classType.newInstance());
    }
  }

  /**
   * @description Internal method for manually handler method on trigger context
   * @author Digital Align | 06-05-2021
   * @param AbstractTriggerHandler `triggerAction`
   **/
  @testVisible
  private static void executeTriggerAction(
    SObjectTriggerSetting__mdt triggerSetting,
    AbstractTriggerHandler triggerAction
  ) {
    TriggerDispatcher.setMaxLoopCount(
      triggerSetting.TriggerHandlerName__c,
      Integer.valueOf(triggerSetting.RecursionCount__c)
    );

    // Validate
    if (!TriggerDispatcher.validateRun(triggerSetting.TriggerHandlerName__c)) {
      return;
    }

    //throws an error when exceed the max look limit
    TriggerDispatcher.addToLoopCount(triggerSetting.TriggerHandlerName__c);

    switch on Trigger.operationType {
      when BEFORE_INSERT {
        triggerAction.beforeInsert();
      }
      when BEFORE_UPDATE {
        triggerAction.beforeUpdate();
      }
      when BEFORE_DELETE {
        triggerAction.beforeDelete();
      }
      when AFTER_INSERT {
        triggerAction.afterInsert();
      }
      when AFTER_UPDATE {
        triggerAction.afterUpdate();
      }
      when AFTER_DELETE {
        triggerAction.afterDelete();
      }
      when AFTER_UNDELETE {
        triggerAction.afterUndelete();
      }
    }

    TriggerDispatcher.removeFromLoopCount(triggerSetting.TriggerHandlerName__c);
  }

  /**
   * @description Allows developers to prevent trigger loops, or allow
   * a limited number of them by setting the maximum number of times
   * this trigger is called.
   * @param max   A valid number (generally 1) of times you'd like
   * to allow the trigger to run.
   * @example
   * In the context of a TriggerDispatcher class,
   * TriggerDispatcher.setMaxLoopCount(5);
   */
  public static void setMaxLoopCount(String handlerName, Integer max) {
    if (!TriggerDispatcher.loopCountMap.containsKey(handlerName)) {
      TriggerDispatcher.loopCountMap.put(handlerName, new LoopCount(max));
    } else {
      TriggerDispatcher.loopCountMap.get(handlerName).setMax(max);
    }
  }

  /**
   * @description  make sure this trigger should continue to run
   * @author Digital Align | 06-05-2021
   * @param String handlerName
   * @return Boolean
   **/
  @testVisible
  private static Boolean validateRun(String handlerName) {
    if (TriggerDispatcher.bypassedHandlers.contains(handlerName)) {
      return false;
    }
    return true;
  }

  /**
   * @description increment the loop count
   * @author Digital Align | 06-05-2021
   * @exception   Throws loop count exception if the max loop count is reached
   */
  @testVisible
  private static void addToLoopCount(String handlerName) {
    if (TriggerDispatcher.loopCountMap.containsKey(handlerName)) {
      Boolean exceeded = TriggerDispatcher.loopCountMap.get(handlerName).increment();
      if (exceeded) {
        throw new SObjectException('Maximum loop count has reached in ' + handlerName);
      }
    }
  }

  /**
   * @description
   * @author Digital Align | 06-05-2021
   * @param String handlerName
   **/
  @testVisible
  private static void removeFromLoopCount(String handlerName) {
    if (TriggerDispatcher.loopCountMap.containsKey(handlerName)) {
      TriggerDispatcher.loopCountMap.get(handlerName).decrement();
    }
  }

  /**
   * @description Allows developers to conditionally bypass (disable)
   * other triggers that *also* implement this TriggerDispatcher
   * @param handlerName Class name (String) of the trigger handler to bypass
   * @example
   * TriggerDispatcher.bypass('AccountTriggerHandler');
   */
  public static void bypass(String handlerName) {
    TriggerDispatcher.bypassedHandlers.add(handlerName);
  }

  /**
   * @description Removes a given trigger handler class name from
   * the list of bypassed trigger handlers.
   * @param handlerName Handler class name to remove from the bypass list
   * @example
   * TriggerDispatcher.clearBypass('AccountTriggerHandler');
   */
  public static void clearBypass(String handlerName) {
    TriggerDispatcher.bypassedHandlers.remove(handlerName);
  }

  /**
   * @description Allows developers to check whether a given trigger
   * handler class is currently bypassed.
   * @param handlerName The name of the trigger handler class to check for
   * @return `Boolean`
   * @example
   * TriggerDispatcher.isBypassed('AccountTriggerHandler');
   */
  public static Boolean isBypassed(String handlerName) {
    return TriggerDispatcher.bypassedHandlers.contains(handlerName);
  }

  /**
   * @description removes all classes from the bypass list
   * @example
   * TriggerDispatcher.clearAllBypasses();
   */
  public static void clearAllBypasses() {
    TriggerDispatcher.bypassedHandlers.clear();
  }

  /**
   * @description inner class for managing the loop count per handler
   */
  @testVisible
  private class LoopCount {
    private Integer max;
    private Integer count;
    /**
     * @description Sets loop count based on the param.
     * @param max   Maximum number of loops to allow.
     */
    public LoopCount(Integer max) {
      this.max = max;
      this.count = 0;
    }

    /**
     * @description Increment the internal counter returning the results of
     * this.exceeded().
     * @return `Boolean` true if count will exceed max count or is less
     * than 0.
     */
    public Boolean increment() {
      this.count++;
      return this.exceeded();
    }

    /**
     * @description Decrement the internal counter
     */
    public void decrement() {
      this.count--;
    }

    public Integer getCount() {
      return count;
    }

    /**
     * @description Determines if this we're about to exceed the loop count.
     * @return `Boolean` true if less than 0 or more than max.
     */
    public Boolean exceeded() {
      if (this.count > this.max) {
        return true;
      }
      return false;
    }

    /**
     * @description Sets the max loop size
     * @param max   The integer to set max to.
     */
    public void setMax(Integer max) {
      this.max = max;
    }
  }
}
