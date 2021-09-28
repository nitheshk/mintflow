/**
 * Copyright (c) 2021 Digital Align
 * @group Handler
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class {{TriggerHandlerName}} extends {{Namespace}}AbstractTriggerHandler {
  /**
   * @description override method for the implementing class to override
   * Before insert trigger has Trigger.New
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public override void beforeInsert() {
  }

  /**
   * @description override method for the implementing class to override
   * Before updtae trigger has Trigger.New,Trigger.Old,Trigger.newMap and Trigger.oldMap
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public override void beforeUpdate() {
  }

  /**
   * @description override method for the implementing class to override
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public override void beforeDelete() {
  }

  /**
   * @description override method for the implementing class to override
   * after insert trigger has Trigger.New,Trigger.Old
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public override void afterInsert() {
  }

  /**
   * @description override method for the implementing class to override
   * after updtae trigger has Trigger.New,Trigger.Old,Trigger.newMap and Trigger.oldMap
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public override void afterUpdate() {
  }

  /**
   * @description override method for the implementing class to override
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public override void afterDelete() {
  }

  /**
   * @description override method for the implementing class to override
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public override void afterUndelete() {
  }
}
