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
  global Object startApplication(Map<String, Object> params) {
    // start an application
    Map<String, Object> result = new Map<String, Object>();
    log?.fine('Inside startApplication -> params -> ' + Json.serialize(params));

    String recordId = (String) params?.get('recordId');

    if (String.isNotBlank(recordId)) {
      // encryption
      // this for start application from existing application
      String sObjectType = ((ID) recordId)
        .getSObjectType()
        .getDescribe()
        .getName();
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
  global virtual Account readApplicationWithChild(Id applicationId) {
    Account application = ApplicationRepository.readApplicationWithChild(
      applicationId
    );

    List<Applicant__c> applicants = ApplicantService.getInstance()
      .readApplicantsWithChild(application.Applicants__r);
    List<FinServ__FinancialAccount__c> financialAccounts = FinancialAccountService.getInstance()
      .readFinancialAccountsWithChild(
        application.FinServ__HouseholdFinancialAccounts__r
      );

    //Combine result into single application object
    dau01.SObjectConstructor builder = dau01.SObjectConstructor.getInstance(
      application
    );
    builder.setChildObjects('dau01__Applicants__r', applicants);
    builder.setChildObjects(
      'FinServ__HouseholdFinancialAccounts__r',
      financialAccounts
    );
    return (Account) builder.build();
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
