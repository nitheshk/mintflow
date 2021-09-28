/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class DealerSiteService extends AbstractService {
  @TestVisible
  private static DealerSiteService serviceInstance;

  public DealerSiteService() {
    super(DealerSiteService.class);
  }

  /**
   * @description Provides a singleton instance of DealerSiteService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-22-2021
   * @return Object  singleton
   **/
  public static DealerSiteService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (DealerSiteService) getInstance(
        DealerSiteService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description update lead record with survey
   * @author Digital Align Team | 09-03-2021
   * @param Map<String Object> params
   * @return Lead
   **/
  global virtual Lead updateLeadRecord(Map<String, Object> params) {
    Lead leadRecord = (Lead) JSON.deserialize(
      params.get('leadRecord')?.toString(),
      Lead.class
    );

    String eventType = params.get('eventType')?.toString();

    if (leadRecord != null) {
      leadRecord.NumberOfEmployees = (Integer) leadRecord.NumberOfEmployees;
      if (eventType == 'LeadSubmit') {
        leadRecord.Status = DealerConstants.LEAD_SUBMITTED_STATUS;
      }
      DealerSiteRepository.upsertRecord(leadRecord);

      if (!CollectionUtils.isListEmpty(leadRecord.Surveys__r)) {
        for (Survey__c surveyObj : leadRecord.Surveys__r) {
          surveyObj.Lead__c = leadRecord.Id;
        }
        DealerSiteRepository.upsertRecords(leadRecord.Surveys__r);
      }
      return leadRecord;
    } else {
      throw new customException('Invalid Lead Record');
    }
  }

  /**
   * @description fetch lead and survey record
   * @author Digital Align Team | 08-25-2021
   * @param Map<String Object> params
   * @return virtual
   **/
  global virtual Lead fetchLeadAndSurvey(
    String leadId,
    Map<String, Object> params
  ) {
    String templateName = (String) params.get('templateName');
    leadId = (Boolean) params.get('isEncrypted')
      ? SecurityUtils.decryptBase64Url(leadId)
      : leadId;

    lead leadObj;
    if (String.isBlank(templateName)) {
      leadObj = DealerSiteRepository.fetchLeadAndSurveyByLeadId(leadId);
    } else {
      leadObj = DealerSiteRepository.fetchLeadAndSurveyByLeadId(
        leadId,
        templateName
      );
    }

    if (leadObj == null) {
      throw new customException('Unable to find lead record');
    }

    if (params.get('validateLink') != null) {
      Boolean validateLink = (Boolean) params.get('validateLink');
      if (validateLink && leadObj.LinkExpireTime__c < Datetime.now()) {
        throw new customException('Link has expired, Request for reset link');
      }
    }

    return leadObj;
  }

  /**
   * @description Invite Dealer to Community portal
   * @author Digital Align | 07-16-2021
   * @param Lead dealerRecord
   * @return Lead
   **/
  global virtual Lead inviteDealer(Lead dealerRecord) {
    system.debug('dealerRecord =' + dealerRecord);

    if (dealerRecord == null) {
      throw new CustomException('Invalid Dealer Record');
    }

    dealerRecord.RecordTypeId = SObjectUtils.recordTypeIdByName(
      Lead.SObjectType,
      DealerConstants.DEALER_LEAD_RECORDTYPE
    );
    dealerRecord.Status = DealerConstants.LEAD_INITIAL_STATUS;
    dealerRecord.LinkExpireTime__c = Datetime.now().addHours(24);
    DealerSiteRepository.insertRecord(dealerRecord);

    DealerSiteService.getInstance().createDocumentRequests(dealerRecord.Id);

    DealerEmailService.getInstance().sendDealerRegisterInvitation(dealerRecord);

    return dealerRecord;
  }

  /**
   * @description fetch survey template for dealer
   * @author Digital Align Team | 07-22-2021
   * @return List<Survey__c>
   **/
  global virtual List<Survey__c> fetchSurveyTemplates(
    Map<String, Object> params
  ) {
    String templateName = (String) params.get('templateName');
    return SurveyResolver.getInstance().fetchSurveyByTemplateName(templateName);
  }

  /**
   * @description
   * @author Digital Align Team | 07-01-2021
   * @param
   * @return List<Lead>
   **/
  global virtual List<Lead> fetchPendingRecords(String status) {
    List<Lead> returnRecords = new List<Lead>();

    try {
      returnRecords = DealerSiteRepository.fetchPendingRecords(status);
      system.debug('returnRecord  ' + returnRecords);
      return returnRecords;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description
   * @author Digital Align Team | 07-01-2021
   * @param
   * @return List<Lead>
   **/
  global virtual List<Contact> fetchApprovedRecords(String status) {
    List<Contact> returnRecords = new List<Contact>();

    try {
      returnRecords = DealerSiteRepository.fetchApprovedRecords(status);
      system.debug('returnRecord  ' + returnRecords);
      return returnRecords;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description fetch picklsit value of salesforce field
   * @author Digital Align Team | 09-02-2021
   * @param Map<String Object> params
   * @return Map<String, Map<String, Object>>
   * @example format of parameter
   *  {
        Lead : [
            "LeadSource",
            "Staus" 
        ]
      }
   **/
  global virtual Map<String, Map<String, Object>> fetchPickListValues(
    Map<String, Object> params
  ) {
    Map<String, Map<String, Object>> result = new Map<String, Map<String, Object>>();

    for (String sType : params.keySet()) {
      List<String> fieldNames = (List<String>) JSON.deserialize(
        JSON.serialize(params.get(sType)),
        List<String>.class
      );
      Schema.DescribeSObjectResult sObjectResult = Schema.getGlobalDescribe()
        .get(sType)
        .getDescribe();
      result.put(sType, new Map<String, Object>());
      for (String fieldName : fieldNames) {
        List<Object> picklistValues = new List<Object>();
        for (
          Schema.PicklistEntry picklistEntry : sObjectResult.fields.getMap()
            .get(fieldName)
            .getDescribe()
            .getPicklistValues()
        ) {
          picklistValues.add(
            new Map<String, String>{
              'label' => picklistEntry.getLabel(),
              'value' => picklistEntry.getValue()
            }
          );
        }
        result.get(sType).put(fieldName, picklistValues);
      }
    }
    return result;
  }

  /**
   * @description
   * @author Digital Align | 08-01-2021
   * @param String leadId
   * @return List<DocumentRequest__c>
   **/
  global virtual List<DocumentRequest__c> createDocumentRequests(
    String leadId
  ) {
    if (string.isBlank(leadId) == null) {
      return null;
    }
    List<DocumentRequest__c> documents = new List<DocumentRequest__c>();
    for (
      String name : new List<String>{
        'Tax Identification form',
        'Registration form',
        'Company License'
      }
    ) {
      DocumentRequest__c doc = new DocumentRequest__c();
      doc.name = name;
      doc.Status__c = 'Requested';
      doc.Lead__c = leadId;
      documents.add(doc);
    }
    system.debug('List of documents = ' + documents);
    return (documents != null)
      ? (List<DocumentRequest__c>) DealerSiteRepository.insertRecords(documents)
      : null;
  }
  /**
   * @description
   * @author Digital Align | 08-01-2021
   * @param string leadId
   * @return List<DocumentRequest__c>
   **/
  global virtual List<DocumentRequest__c> fetchDocumentRequests(string leadId) {
    system.debug('leadId =' + leadId);
    if (String.isNotBlank(leadId)) {
      return DealerSiteRepository.fetchDocumentRequestsByLeadId(leadId);
    } else {
      throw new customException('Invalid Lead Id');
    }
  }

  /**
   * @description link content version to entity
   * @author Digital Align Team | 08-23-2021
   * @param Map<String Object> params
   * @return ContentVersion
   **/
  global virtual ContentVersion linkContentVersionToEntity(
    Map<String, Object> params
  ) {
    Id contentVersionId = (Id) params.get('contentVersionId');
    ContentVersion cv = FileService.getInstance()
      .fetchContentVersionById(contentVersionId, false);

    Boolean isFailed = false;
    try {
      if (cv?.ContentSize < 3145728) {
        list<Id> entityIds = (list<Id>) JSON.Deserialize(
          JSON.Serialize(params.get('entityIds')),
          List<Id>.class
        );
        FileService.getInstance()
          .linkContentDocumentWithEntity(cv.ContentDocumentId, entityIds);
      } else {
        throw new customException('File size limit Exceeded');
      }
    } catch (Exception ex) {
      isFailed = true;
      System.debug(ex.getMessage());
      throw new customException(ex.getMessage());
    } finally {
      if (isFailed) {
        FileService.getInstance().deleteContentVersion(cv?.ContentDocumentId);
      }
    }
    return cv;
  }
}
