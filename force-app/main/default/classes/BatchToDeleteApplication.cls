/**
 * Copyright (c) 2022 Digital Align
 * @group BatchJob
 * @author Digital Align Team
 * @reference
 * @description  Delete Application from system
 * Make Sure Batch job Size is 5
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class BatchToDeleteApplication implements Database.Batchable<sObject>, Database.Stateful {
  private Logger log = Logger.getInstance(BatchToDeleteApplication.class);
  /**
   * @description
   * @author Digital Align Team | 04-26-2022
   * @param Database.BatchableContext bc
   * @return Database.QueryLocator
   **/
  global Database.QueryLocator start(Database.BatchableContext bc) {
    log?.debug('Start BatchToDeleteApplication ');
    String qry = Query.newInstance(Application__c.SObjectType)
      .grpOpen()
      .whereEq('Status__c', ApplicationConstant.ABANDONED)
      .orCon()
      .whereEq('Status__c', ApplicationConstant.SAVED)
      .orCon()
      .whereEq('Status__c', ApplicationConstant.CANCELLED)
      .grpClose()
      .andCon()
      .whereLte('LastModifiedDate', DateTime.now().addDays(-10))
      .addLimit(1000)
      .toString();
    log?.debug('qry :' + qry);
    return Database.getQueryLocator(qry);
  }

  /**
   * @description
   * @author Digital Align Team | 04-26-2022
   * @param Database.BatchableContext BC
   * @param List<Application__c> scope
   **/
  global void execute(Database.BatchableContext bc, List<Application__c> applications) {
    log?.debug('execute BatchToDeleteApplication ');
    for (Application__c application : applications) {
      ApplicationPersistService.getInstance().deleteEntity(application.Id);
    }
    Logger.persist();
  }

  /**
   * @description
   * @author Digital Align Team | 04-26-2022
   * @param Database.BatchableContext BC
   **/
  global void finish(Database.BatchableContext bc) {
    log?.debug('Finished BatchToDeleteApplication ');
    Logger.persist();
  }
}
