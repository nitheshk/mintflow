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
    log?.fine('Inside startApplication -> params -> ' + Json.serialize(params));
    if (String.isNotBlank(params?.get('id'))) {
      // encryption
      // this for start application from existing application
      Id recordId = (ID) params.get('id');
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
      log?.info('startApplication -> Url -> ' + result.get('url'));
    }
    return result;
  }

  /**
   * @description create new house application
   * @author Digital Align Team | 10-05-2021
   * @param Map<String Object> params
   * @return Account
   **/
  global virtual Account createApplication(Map<String, Object> params) {
    // Create init Account Application
    Account application = new Account();
    application.Name = 'Init';
    application.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
      Account.SObjectType,
      ApplicationConstant.ACCOUNT_APPLICATION_RECORDTYPE
    );
    application.FinServ__Status__c = 'Active';
    application.Description = ApplicationServiceHelper.getInstance()
      .getIpAddress();
    ApplicationRepository.upsertRecord(application);
    return application;
  }

  /**
   * @description Read application by parameter passed
   * @author Digital Align Team | 10-21-2021
   * @param Map<String Object> params
   * @return Account
   **/
  global virtual Account readApplication(Map<String, Object> params) {
    return null;
  }

  /**
   * @description
   * @author Digital Align Team | 10-25-2021
   * @param Account application
   * @return virtual
   **/
  global virtual Account saveApplication(Account application) {
    ApplicationRepository.upsertRecord(application);
    //leadObj = ApplicationServiceHelper.getInstance().saveSurvey(leadObj);
    if (application.Applicants__r?.size() > 0) {
      List<dau01__Applicant__c> applicants = ApplicantService.getInstance()
        .saveApplicants(application.Id, application.Applicants__r);

      application = (Account) dau01.SObjectConstructor.getInstance(application)
        .setChildObjects('dau01__Applicants__r', applicants)
        .build();
    }

    if (application.FinServ__HouseholdFinancialAccounts__r?.size() > 0) {
      // same as applicant steps
      log?.info('update financial account here');
    }

    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @param Map<String Object> params
   * @return Object
   **/
  global Account resumeApplication(Map<String, Object> params) {
    return null;
  }
}
