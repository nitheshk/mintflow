/**
 * Copyright (c) 2021 Digital Align
 * @group Builder
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class Flow extends AbstractService {
  @TestVisible
  private static Flow serviceInstance;

  private static Flow__c currentFlow = new Flow__c();
  private static Map<String, Flow__c> flowMap = new Map<String, Flow__c>();
  private static Flow__c currentSubFlow = new Flow__c();
  private static Map<String, Flow__c> subFlowMap = new Map<String, Flow__c>();
  private static Map<String, Map<String, Flow__c>> flows = new Map<String, Map<String, Flow__c>>();

  public Flow() {
    super(Flow.class);
  }

  /**
   * @description Provides a singleton instance of Flow from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static Flow getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (Flow) getNewInstance(Flow.class);
    }
    return serviceInstance;
  }

  global static void initialize() {
  }
}
