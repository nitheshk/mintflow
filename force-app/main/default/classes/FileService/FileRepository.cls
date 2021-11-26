/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class FileRepository extends DatabaseUtils {
  /**
   * @description fetch content version by content version id
   * @author Digital Align Team | 07-30-2021
   * @param Id contentVersionId
   * @param Boolean ignoreVersionData
   * @return ContentVersion
   **/
  public static ContentVersion fetchContentVersionById(
    Id contentVersionId,
    Boolean ignoreVersionData
  ) {
    Query q = Query.newInstance(ContentVersion.SObjectType).addFields();
    if (ignoreVersionData) {
      q.removeFields('VersionData');
    }
    return (ContentVersion) getRecord(
      q.whereEq('Id', contentVersionId).toString()
    );
  }

  /**
   * @description fetch content version by content version ids
   * @author Digital Align Team | 07-30-2021
   * @param List<Id> contentVersionIds
   * @param Boolean ignoreVersionData
   * @return List<ContentVersion>
   **/
  public static List<ContentVersion> fetchContentVersionsByIds(
    List<Id> contentVersionIds,
    Boolean ignoreVersionData
  ) {
    Query q = Query.newInstance(ContentVersion.SObjectType).addFields();
    if (ignoreVersionData) {
      q.removeFields('VersionData');
    }
    return (List<ContentVersion>) getRecords(
      q.whereIn('Id', contentVersionIds).toString()
    );
  }

  /**
   * @description fetch content versions by content document id
   * @author Digital Align Team | 08-02-2021
   * @param Id contentDocumentId
   * @param Boolean ignoreVersionData
   * @return ContentVersion
   **/
  public static ContentVersion fetchContentVersionByCD(
    Id contentDocumentId,
    Boolean ignoreVersionData
  ) {
    Query q = Query.newInstance(ContentVersion.SObjectType).addFields();
    if (ignoreVersionData) {
      q.removeFields('VersionData');
    }
    return (ContentVersion) getRecord(
      q.whereEq('ContentDocumentId', contentDocumentId).toString()
    );
  }

  /**
   * @description fetch content versions by content document ids
   * @author Digital Align Team | 08-02-2021
   * @param List<Id> contentDocumentIds
   * @param Boolean ignoreVersionData
   * @return List<ContentVersion>
   **/
  public static List<ContentVersion> fetchContentVersionsByCD(
    List<Id> contentDocumentIds,
    Boolean ignoreVersionData
  ) {
    Query q = Query.newInstance(ContentVersion.SObjectType).addFields();
    if (ignoreVersionData) {
      q.removeFields('VersionData');
    }
    return (List<ContentVersion>) getRecords(
      q.whereIn('ContentDocumentId', contentDocumentIds).toString(true)
    );
  }

  /**
   * @description fetch content version by content document id, content type and content sub type
   * @author Digital Align Team | 08-02-2021
   * @param List<Id> contentDocumentIds
   * @param String contentType
   * @param String contentSubType
   * @param Boolean ignoreVersionData
   * @return List<ContentVersion>
   **/
  public static List<ContentVersion> fetchContentVersions(
    List<Id> contentDocumentIds,
    String contentType,
    String contentSubType,
    Boolean ignoreVersionData
  ) {
    Query q = Query.newInstance(ContentVersion.SObjectType).addFields();
    if (ignoreVersionData) {
      q.removeFields('VersionData');
    }
    return (List<ContentVersion>) getRecords(
      q.whereIn('ContentDocumentId', contentDocumentIds)
        .andCon()
        .whereEq('mflow__ContentType__c', contentType)
        .andCon()
        .whereEq('mflow__ContentSubType__c', contentSubType)
        .toString()
    );
  }

  /**
   * @description fetch content Document links by linked entity id
   * @author Digital Align Team | 08-02-2021
   * @param Id entityId
   * @return List<ContentDocumentLink>
   **/
  public static List<ContentDocumentLink> fetchContentDocumentLinks(
    Id entityId
  ) {
    return (List<ContentDocumentLink>) getRecords(
      Query.newInstance(ContentDocumentLink.SObjectType)
        .addFields('ContentDocumentId')
        .whereEq('LinkedEntityId', entityId)
        .toString(true)
    );
  }

  /**
   * @description Used to delete Content version
   * @author Digital Align Team | 08-02-2021
   * @param List<Id> contentDocumentIds
   * @return List<ContentDocument>
   **/
  public static List<ContentDocument> fetchContentDocument(
    List<Id> contentDocumentIds
  ) {
    return (List<ContentDocument>) getRecords(
      Query.newInstance(ContentDocument.SObjectType)
        .whereIn('Id', contentDocumentIds)
        .toString(true)
    );
  }

  /**
   * @description fetch Document Id By document DeveloperName
   * @author Digital Align Team | 08-18-2021
   * @param String developerName
   * @return Document
   **/
  public static Document fetchDocumentIdByDeveloperName(String developerName) {
    return (Document) getRecord(
      Query.newInstance(Document.SObjectType)
        .whereEq('DeveloperName', developerName)
        .addLimit(1)
        .toString(true)
    );
  }

  /**
   * @description Fetch Content Distribution By Id
   * @author Digital Align Team | 09-13-2021
   * @param Id contentDistributionId
   * @return ContentDistribution
   **/
  public static ContentDistribution fetchContentDistributionById(
    Id contentDistributionId
  ) {
    return (ContentDistribution) getRecord(
      Query.newInstance(ContentDistribution.SObjectType)
        .addFields()
        .whereEq('Id', contentDistributionId)
        .addLimit(1)
        .toString(true)
    );
  }

  /**
   * @description  fetch Content Distributions By content version Id
   * @author Digital Align Team | 09-13-2021
   * @param Id contentVersionId
   * @return List<ContentDistribution>
   **/
  public static List<ContentDistribution> fetchContentDistributionsById(
    Id contentVersionId
  ) {
    return (List<ContentDistribution>) getRecords(
      Query.newInstance(ContentDistribution.SObjectType)
        .whereEq('ContentVersionId', contentVersionId)
        .toString(true)
    );
  }
}
