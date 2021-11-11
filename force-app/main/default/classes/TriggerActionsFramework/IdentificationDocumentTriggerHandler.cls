/**
 * Copyright (c) 2021 Digital Align
 * @group Handler
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class IdentificationDocumentTriggerHandler extends AbstractTriggerHandler {
  public IdentificationDocumentTriggerHandler() {
    super(IdentificationDocumentTriggerHandler.class);
  }
  /**
   * @description override method for the implementing class to override
   * after insert trigger has Trigger.New,Trigger.Old
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  public override void afterInsert() {
    List<FinServ__IdentificationDocument__c> newIdentityDocuments = (List<FinServ__IdentificationDocument__c>) Trigger.new;

    List<FileDTO> fileDtos = new List<FileDTO>();
    for (FinServ__IdentificationDocument__c iDoc : newIdentityDocuments) {
      if (String.isNotBlank(iDoc.PrimaryContentDocumentID__c)) {
        fileDtos.add(new FileDTO(iDoc.PrimaryContentDocumentID__c, iDoc.Id));
      }
      if (String.isNotBlank(iDoc.SecondaryContentDocumentId__c)) {
        fileDtos.add(new FileDTO(iDoc.SecondaryContentDocumentId__c, iDoc.Id));
      }
      if (String.isNotBlank(iDoc.AddressContentDocumentId__c)) {
        fileDtos.add(new FileDTO(iDoc.AddressContentDocumentId__c, iDoc.Id));
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
    List<FinServ__IdentificationDocument__c> newIdentityDocuments = (List<FinServ__IdentificationDocument__c>) Trigger.new;
    Map<Id, FinServ__IdentificationDocument__c> oldIdentityDocumentMap = (Map<Id, FinServ__IdentificationDocument__c>) Trigger.oldMap;

    List<FileDTO> fileDtos = new List<FileDTO>();
    List<Id> contentDocumentIds = new List<Id>();
    for (FinServ__IdentificationDocument__c newIDoc : newIdentityDocuments) {
      FinServ__IdentificationDocument__c oldIDoc = oldIdentityDocumentMap.get(
        newIDoc.Id
      );

      if (
        oldIDoc.PrimaryContentDocumentID__c !=
        newIDoc.PrimaryContentDocumentID__c
      ) {
        if (String.isNotBlank(newIDoc.PrimaryContentDocumentID__c)) {
          fileDtos.add(
            new FileDTO(newIDoc.PrimaryContentDocumentID__c, newIDoc.Id)
          );
        }
        if (String.isNotBlank(oldIDoc.PrimaryContentDocumentID__c)) {
          contentDocumentIds.add(oldIDoc.PrimaryContentDocumentID__c);
        }
      }

      if (
        oldIDoc.SecondaryContentDocumentId__c !=
        newIDoc.SecondaryContentDocumentId__c
      ) {
        if (String.isNotBlank(newIDoc.SecondaryContentDocumentId__c)) {
          fileDtos.add(
            new FileDTO(newIDoc.SecondaryContentDocumentId__c, newIDoc.Id)
          );
        }
        if (String.isNotBlank(oldIDoc.SecondaryContentDocumentId__c)) {
          contentDocumentIds.add(oldIDoc.SecondaryContentDocumentId__c);
        }
      }

      if (
        oldIDoc.AddressContentDocumentId__c !=
        newIDoc.AddressContentDocumentId__c
      ) {
        if (String.isNotBlank(newIDoc.AddressContentDocumentId__c)) {
          fileDtos.add(
            new FileDTO(newIDoc.AddressContentDocumentId__c, newIDoc.Id)
          );
        }
        if (String.isNotBlank(oldIDoc.AddressContentDocumentId__c)) {
          contentDocumentIds.add(oldIDoc.AddressContentDocumentId__c);
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
    for (
      FinServ__IdentificationDocument__c iDoc : (List<FinServ__IdentificationDocument__c>) Trigger.old
    ) {
      if (String.isNotBlank(iDoc.PrimaryContentDocumentID__c)) {
        contentDocumentIds.add(iDoc.PrimaryContentDocumentID__c);
      }

      if (String.isNotBlank(iDoc.SecondaryContentDocumentId__c)) {
        contentDocumentIds.add(iDoc.SecondaryContentDocumentId__c);
      }

      if (String.isNotBlank(iDoc.AddressContentDocumentId__c)) {
        contentDocumentIds.add(iDoc.AddressContentDocumentId__c);
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
