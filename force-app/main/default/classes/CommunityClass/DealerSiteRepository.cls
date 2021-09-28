/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class DealerSiteRepository extends DatabaseUtils {
  /**
   * @description
   * @author Digital Align Team | 07-16-2021
   * @param Id leadId
   * @return Lead
   **/
  public static Lead fetchLeadAndSurveyByLeadId(Id leadId) {
    return (Lead) getRecord(
      Query.newInstance(Lead.SObjectType)
        .addFields()
        .queryChild('dau01__Surveys__r')
        .addFields()
        .orderBy('dau01__Order__c')
        .run()
        .whereEq('Id', leadId)
        .toString(true)
    );
  }

  /**
   * @description
   * @author Digital Align Team | 08-25-2021
   * @param string leadId
   * @param String templateName
   * @return Lead
   **/
  public static Lead fetchLeadAndSurveyByLeadId(
    Id leadId,
    String templateName
  ) {
    return (Lead) getRecord(
      Query.newInstance(Lead.SObjectType)
        .addFields()
        .queryChild('dau01__Surveys__r')
        .addFields()
        .whereEq('dau01__TemplateName__c', templateName)
        .orderBy('dau01__Order__c')
        .run()
        .whereEq('Id', leadId)
        .toString(true)
    );
  }

  /**
   * @description
   * @author Digital Align | 07-16-2021
   * @param string templateName
   * @return EmailTemplate
   **/
  public static EmailTemplate fetchEmailTemplateByName(string templateName) {
    List<EmailTemplate> returnObjectList = new List<EmailTemplate>();
    return (EmailTemplate) getRecord(
      Query.newInstance(EmailTemplate.SObjectType)
        .addFields()
        .whereEq('Name', templateName)
        .toString(true)
    );
  }

  /**
   * @description
   * @author Digital Align Team | 07-22-2021
   * @return List<lead>
   **/
  public static List<lead> fetchPendingRecords(String status) {
    String recordType = 'Dealer';
    /*Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get('Dealer')
      .getRecordTypeId();*/

    Id recordTypeId = SObjectUtils.recordTypeIdByName(
      Lead.SobjectType,
      recordType
    );
    String queryString = Query.newInstance(Lead.SObjectType)
      .addFields()
      .whereEq('RecordTypeId', recordTypeId)
      .andCon()
      .whereEq('Status', status)
      .toString(true);
    return (List<Lead>) DatabaseUtils.getRecords(queryString);
  }

  /**
   * @description
   * @author Digital Align Team | 07-22-2021
   * @return List<lead>
   **/
  public static List<Contact> fetchApprovedRecords(String status) {
    String recordType = 'IndustriesBusiness';
    /*Id recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get('Dealer')
      .getRecordTypeId();*/
    Id recordTypeId = SObjectUtils.recordTypeIdByDevName(
      Account.SobjectType,
      recordType
    );
    system.debug('recordTypeId::' + recordTypeId);
    String q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .addFields('Account.Name,Account.Website')
      //  .queryLookup('Account')
      //  .addFields('Name,Website')
      .whereEq('Account.RecordTypeId', recordTypeId)
      //   .run()
      .toString(true);
    List<Contact> sl = (List<Contact>) DatabaseUtils.getRecords(q);
    system.debug('acontact::' + sl[0].Account.Website);

    return sl;
    //return (List<Contact>) DatabaseUtils.getRecords(queryString);
  }
  /**
   * @description
   * @author Digital Align | 07-28-2021
   * @param string contentVersionId
   * @return ContentVersion
   **/
  public static ContentVersion fetchContentVersion(string contentVersionId) {
    return (ContentVersion) getRecord(
      Query.newInstance(ContentVersion.SObjectType)
        .addFields('ContentDocumentId')
        .whereEq('Id', contentVersionId)
        .toString(true)
    );
  }
  /**
   * @description
   * @author Digital Align | 08-01-2021
   * @param string leadId
   * @return List<DocumentRequest__c>
   **/
  public static List<DocumentRequest__c> fetchDocumentRequestsByLeadId(
    string leadId
  ) {
    return (List<DocumentRequest__c>) getRecords(
      Query.newInstance(DocumentRequest__c.SObjectType)
        .addFields()
        .whereEq('dau01__Lead__c', leadId)
        .toString(true)
    );
  }
}
