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
