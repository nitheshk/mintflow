/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description functionality related dealer LWC components
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class LWCDealerSiteController {
  /**
   * @description update lead and survey record enter by dealer
   * @author Digital Align | 07-16-2021
   * @param Lead dealerRecord
   * @param String surveyRecord
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse updateLeadAndSurveyRecords(
    Map<String, Object> params
  ) {
    try {
      // Upsert dealer record
      return ApexResponse.ok(
        DealerSiteService.getInstance().updateLeadRecord(params)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description fetch lead and survey child records
   * @author Digital Align Team | 08-24-2021
   * @param String leadId
   * @param boolean isEncrypted
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchLeadAndSurvey(
    String leadId,
    Map<String, Object> params
  ) {
    try {
      return ApexResponse.ok(
        DealerSiteService.getInstance().fetchLeadAndSurvey(leadId, params)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description create new lead on invite of dealer
   * @author Digital Align | 07-16-2021
   * @param String newDealerRecord
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse inviteDealer(String newDealerRecord) {
    try {
      lead leadObj = (Lead) JSON.deserialize(newDealerRecord, Lead.class);
      DealerSiteService.getInstance().inviteDealer(leadObj);
      return ApexResponse.ok(leadObj);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description generate survey template for dealer
   * @author Digital Align Team | 07-22-2021
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse fetchSurveyTemplates(Map<String, Object> params) {
    try {
      return ApexResponse.ok(
        DealerSiteService.getInstance().fetchSurveyTemplates(params)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description create dealer employee
   * @author Digital Align | 07-22-2021
   * @param user userData
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse createDealerEmployee(Map<String, Object> params) {
    return UserAccountManagementController.createDealerEmployeeAccount(params);
  }

  /**
   * @description
   * @author Digital Align | 08-02-2021
   * @param String objectType
   * @param List<string> picklistFields
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchPickListValues(Map<String, Object> params) {
    try {
      return ApexResponse.ok(
        DealerSiteService.getInstance().fetchPickListValues(params)
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Delete Files By Entity Id
   * @author Digital Align | 08-03-2021
   * @param Id entityId
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse deleteFilesByEntityId(Id entityId) {
    try {
      system.debug('entityId' + entityId);
      FileService.getInstance().deleteContentVersionByEntityId(entityId);
      return ApexResponse.ok();
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description
   * @author Digital Align | 08-01-2021
   * @param string leadId
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchDocumentRequests(string leadId) {
    List<DocumentRequest__c> doc = DealerSiteService.getInstance()
      .fetchDocumentRequests(leadId);
    if (doc == null) {
      return ApexResponse.fail(doc);
    } else {
      return ApexResponse.ok(doc);
    }
  }

  /**
   * @description link content version to entity
   * @author Digital Align Team | 08-23-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse linkContentVersionToEntity(
    Map<String, Object> params
  ) {
    try {
      return ApexResponse.ok(
        DealerSiteService.getInstance().linkContentVersionToEntity(params)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description
   * @author Digital Align | 08-24-2021
   * @param string recordId
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchDealerEmployeeActiveStatus(string recordId) {
    return UserAccountManagementController.fetchDealerEmployeeActiveStatus(
      recordId
    );
  }
  /**
   * @description
   * @author Digital Align | 08-24-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse updateDealerEmployeeActiveStatus(
    Map<String, Object> params
  ) {
    return UserAccountManagementController.updateDealerEmployeeActiveStatus(
      params
    );
  }

  /**
   * @description
   * @author Digital Align | 09-01-2021
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchLoggedinUserContactDetails() {
    return UserAccountManagementController.fetchLoggedinUserContactDetails();
  }

  /**
   * @description send OTP Message to Dealer
   * @author Digital Align | 07-22-2021
   * @param String dealerPhone
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse sendOTPMessage(Map<String, Object> params) {
    try {
      return ApexResponse.ok(
        NotificationService.getInstance().sendOTPMessage(params)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }
}
