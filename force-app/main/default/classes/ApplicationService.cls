/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicationService extends AbstractService {
  @TestVisible
  private static ApplicationService serviceInstance;

  public ApplicationService() {
    super(ApplicationService.class);
  }

  /**
   * @description Provides a singleton instance of ApplicationService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static ApplicationService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicationService) getInstance(
        ApplicationService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description start application
   * @author Digital Align Team | 09-29-2021
   * @param Map<String String> params
   * @return Object
   **/
  global Object startApplication(Map<String, String> params) {
    // start an application
    Map<String, Object> result = new Map<String, Object>();
    if (String.isNotBlank(params.get('recordId'))) {
      // encryption
      // this for start application from existing application
      Id recordId = (ID) params.get('recordId');
      String sObjectType = recordId.getSObjectType().getDescribe().getName();
      switch on sObjectType {
        when 'Account' {
          system.debug('Inside ' + sObjectType);
        }
        when 'FinanacialAccount' {
          system.debug('Inside ' + sObjectType);
        }
      }
    } else {
      //start new application, redirect to site url
      result.put(
        'url',
        SiteSetting__c.getInstance().OnlineSiteUrl__c +
        SiteSetting__c.getInstance().OnlineAccountOpeningUrl__c
      );
    }
    return result;
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @param Map<String Object> params
   * @return Object
   **/
  global virtual Account createApplication(Map<String, Object> params) {
    // start an application
    //Map<String, Object> result = new Map<String, Object>();
    Account applicationObj = ApplicationServiceHelper.getInstance().createHouseholdApplication(params);
    return applicationObj;
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @param Map<String Object> params
   * @return Object
   **/
  global Object resumeApplication(Map<String, Object> params) {
    // start an application
    Map<String, Object> result = new Map<String, Object>();

    return null;
  }
}
