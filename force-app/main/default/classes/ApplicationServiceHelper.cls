/**
 * Copyright (c) 2021 Digital Align
 * @group Helper
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicationServiceHelper extends AbstractService {
  @TestVisible
  private static ApplicationServiceHelper serviceInstance;

  public ApplicationServiceHelper() {
    super(ApplicationServiceHelper.class);
  }

  /**
   * @description Provides a singleton instance of ApplicationServiceHelper from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static ApplicationServiceHelper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicationServiceHelper) getInstance(
        ApplicationServiceHelper.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description get current ipaddress
   * @author Digital Align Team | 10-11-2021
   * @return String
   **/
  global virtual String getIpAddress() {
    String ipAddress;
    //System.auth.SessionManagement.getCurrentSession().get('SourceIp');

    if (ApexPages.currentPage() != null && String.isBlank(ipAddress)) {
      ipAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
      // X-Salesforce-SIP has the value when no caching integration or via secure URL.
      if (String.isBlank(ipAddress)) {
        ipAddress = ApexPages.currentPage()
          .getHeaders()
          .get('X-Salesforce-SIP');
      }
      // get IP address when no caching (sandbox, dev, secure urls)
      if (String.isBlank(ipAddress)) {
        ipAddress = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
      }
    }
    log?.info('getIpAddress -> IP address -> ' + ipAddress);
    return ipAddress;
  }

  /**
   * @description save survey record
   * @author Digital Align Team | 10-11-2021
   * @param Lead leadObj
   * @return Lead
   **/
  global virtual Lead saveSurvey(Lead leadObj) {
    //when survey is empty
    if (CollectionUtils.isListEmpty(leadObj.Surveys__r)) {
      return leadObj;
    }
    List<Survey__c> toBeDelete = new List<Survey__c>();
    List<Survey__c> toBeSave = new List<Survey__c>();
    for (Survey__c surveyObj : leadObj.Surveys__r) {
      if (surveyObj.deleteRecord__c == true) {
        toBeDelete.add(surveyObj);
      } else {
        toBeSave.add(surveyObj);
      }
    }
    ApplicationRepository.deleteRecords(toBeDelete);
    ApplicationRepository.upsertRecords(toBeSave);

    return (Lead) SObjectConstructor.getInstance(leadObj)
      .setChildObjects('dau01__Surveys__r', toBeSave)
      .build();
  }
}
