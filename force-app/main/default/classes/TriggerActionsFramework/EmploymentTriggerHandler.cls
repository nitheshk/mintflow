/**
 * Copyright (c) 2021 Digital Align
 * @group Handler
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class EmploymentTriggerHandler extends AbstractTriggerHandler {
  public EmploymentTriggerHandler() {
    super(EmploymentTriggerHandler.class);
  }
  /**
   * @description override method for the implementing class to override
   * after insert trigger has Trigger.New,Trigger.Old
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public override void afterInsert() {
    List<Employment__c> newEmployments = (List<Employment__c>) Trigger.new;
    List<FileDTO> fileDtos = new List<FileDTO>();
    for (Employment__c emp : newEmployments) {
      if (String.isNotBlank(emp.PrimaryContentDocumentID__c)) {
        fileDtos.add(new FileDTO(emp.PrimaryContentDocumentID__c, emp.Id));
      }
    }
    if (!fileDtos.isEmpty()) {
      FileService.getInstance().linkContentDocumentWithEntity(fileDtos);
    }
  }

  /**
   * @description override method for the implementing class to override
   * after updtae trigger has Trigger.New,Trigger.Old,Trigger.newMap and Trigger.oldMap
   */
  @SuppressWarnings('PMD.EmptyStatementBlock,PMD.CognitiveComplexity')
  public override void afterUpdate() {
    List<Employment__c> newEmployments = (List<Employment__c>) Trigger.new;
    Map<Id, Employment__c> oldEmploymentMap = (Map<Id, Employment__c>) Trigger.oldMap;
    List<FileDTO> fileDtos = new List<FileDTO>();
    List<Id> contentDocumentIds = new List<Id>();
    for (Employment__c newEmp : newEmployments) {
      Employment__c oldEmp = oldEmploymentMap.get(newEmp.Id);

      if (oldEmp.PrimaryContentDocumentID__c != newEmp.PrimaryContentDocumentID__c) {
        if (String.isNotBlank(newEmp.PrimaryContentDocumentID__c)) {
          fileDtos.add(new FileDTO(newEmp.PrimaryContentDocumentID__c, newEmp.Id));
        }
        if (String.isNotBlank(oldEmp.PrimaryContentDocumentID__c)) {
          contentDocumentIds.add(oldEmp.PrimaryContentDocumentID__c);
        }
      }
    }

    //delete old content version
    if (!contentDocumentIds.isEmpty()) {
      FileService.getInstance().deleteContentVersions(contentDocumentIds);
    }
    // insert new updated content version
    if (!fileDtos.isEmpty()) {
      FileService.getInstance().linkContentDocumentWithEntity(fileDtos);
    }
  }

  /**
   * @description override method for the implementing class to override
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public override void beforeDelete() {
    List<Id> contentDocumentIds = new List<Id>();
    for (Employment__c emp : (List<Employment__c>) Trigger.old) {
      if (String.isNotBlank(emp.PrimaryContentDocumentID__c)) {
        contentDocumentIds.add(emp.PrimaryContentDocumentID__c);
      }
    }
    //delete old content version
    try {
      if (!contentDocumentIds.isEmpty()) {
        log?.debug('contentDocumentIds to delete :' + contentDocumentIds);
        FileService.getInstance().deleteContentVersions(contentDocumentIds);
      }
    } catch (Exception ex) {
      log?.error(ex);
    }
  }
}
