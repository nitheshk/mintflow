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
    log?.fine('Inside createApplication');
    // Create init Account Application
    Account application = new Account();
    application.Name = 'Mint';
    application.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
      Account.SObjectType,
      ApplicationConstant.ACCOUNT_APPLICATION_RECORDTYPE
    );
    application.FinServ__Status__c = 'Active';
    if (params.get('channel') != null) {
      application.CreatedChannel__c = (String) params.get('channel');
      application.FinServ__LastUsedChannel__c = (String) params.get('channel');
    } else {
      application.CreatedChannel__c = ApplicationConstant.CHANNEL_VIRTUAL;
      application.FinServ__LastUsedChannel__c = ApplicationConstant.CHANNEL_VIRTUAL;
    }

    application.Description = ApplicationServiceHelper.getInstance()
      .getIpAddress();
    ApplicationRepository.upsertRecord(application);

    application = ApplicationRepository.readApplicationById(application.Id);
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setFlowType('ApplicationFlow');
    application = SecurityUtils.createSessionForApplication(application);
    application.Name = application.ApplicationNumber__c;
    ApplicationRepository.upsertRecord(application);
    params.put('applicationId', ApexRequest.getApplicationId());
    params.put('applicantType', ApexRequest.getApplicantType());
    params.put('flowType', ApexRequest.getFlowType());
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
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObjects('dau01__Applicants__r', applicants);
    builder.setChildObjects(
      'FinServ__HouseholdFinancialAccounts__r',
      financialAccounts
    );
    return (Account) builder.build();
  }

  /**
   * @description Read application with specific applicant
   * @author Digital Align Team | 11-19-2021
   * @param Id applicationId
   * @param Id applicantId
   * @return Account
   **/
  global virtual Account readApplicationWithChild(
    Id applicationId,
    Id applicantId
  ) {
    Account application = ApplicationRepository.readApplicationWithChild(
      applicationId,
      applicantId
    );

    List<Applicant__c> applicants = ApplicantService.getInstance()
      .readApplicantsWithChild(application.Applicants__r);
    List<FinServ__FinancialAccount__c> financialAccounts = FinancialAccountService.getInstance()
      .readFinancialAccountsWithChild(
        application.FinServ__HouseholdFinancialAccounts__r
      );

    //Combine result into single application object
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
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
  global virtual Map<String, Object> resumeApplication(
    Map<String, Object> params
  ) {
    log?.fine('Inside resumeApplication');
    String vmf = (String) params.get('vmf');
    //params.remove('vmf');
    //decrypt the url
    SecurityUtils.CipherDTO cipher;
    try {
      cipher = SecurityUtils.extractToken(vmf);
    } catch (Exception ex) {
      throw new CustomException('The specified URL was corrupted');
    }
    if (cipher.edt < Datetime.now()) {
      throw new CustomException('The specified URL was Expired');
    }

    params.put('applicantType', cipher.aplType);
    params.put('channel', cipher.ch);
    params.put('applicationId', cipher.appId);
    params.put('applicantId', cipher.aplId);

    Applicant__c applicant = ApplicantRepository.readApplicantbyId(
      cipher.aplId
    );
    if (applicant == null) {
      throw new CustomException('Applicant not found');
    }
    params.put(
      'maskedEmail',
      applicant.Email__c.replaceAll('(^[^@]{2}|(?!^)\\G)[^@]', '$1*')
    );
    params.put('maskedPhone', applicant.Phone__c.replaceAll('.(?=.{4})', '*'));
    //AuthenticationService.getInstance().generateOTP(cipher.aplId);
    return params;
  }

  /**
   * @description Handle Page Refresh
   * @author Digital Align Team | 11-22-2021
   * @param Map<String Object> params
   * @return Account
   **/
  global virtual Account refreshPage(Map<String, Object> params) {
    log?.fine('Inside refreshPage');
    //get existing token from cookie
    Cookie pageToken = PageUtils.getCookie('token');
    SecurityUtils.CipherDTO cipher;
    try {
      cipher = SecurityUtils.extractToken(pageToken.getValue());
    } catch (Exception ex) {
      throw new CustomException('Invalid session token');
    }
    if (cipher.edt < Datetime.now()) {
      throw new CustomException('Session has Expired');
    }

    Account application;
    if (cipher.aplType == 'Primary') {
      application = ApplicationService.getInstance()
        .readApplicationWithChild(cipher.appId);
    } else if (cipher.aplType == 'Joint') {
      application = ApplicationService.getInstance()
        .readApplicationWithChild(cipher.appId, cipher.aplId);
    } else {
      throw new customException('Applicant Type Not Found');
    }

    params.put('applicantType', cipher.aplType);
    params.put('channel', cipher.ch);
    params.put('applicationId', cipher.appId);
    params.put('applicantId', cipher.aplId);
    return application;
  }

  /**
   * @description Save Application
   * @author Digital Align Team | 11-20-2021
   * @param Account application
   * @return Account
   **/
  global virtual Account saveApplication(Account application) {
    //before save
    //save point count against DML operation
    Savepoint sp = Database.setSavepoint();
    try {
      return ApplicationPersistService.getInstance()
        .saveApplication(application);
    } catch (Exception ex) {
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
    //after save
  }

  /**
   * @description  delete object by Id
   * @author Digital Align Team | 11-10-2021
   * @param Id recordId
   * @return Boolean
   **/
  global virtual Boolean deleteEntity(Id recordId) {
    Savepoint sp = Database.setSavepoint();
    try {
      return ApplicationPersistService.getInstance().deleteEntity(recordId);
    } catch (Exception ex) {
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
  }
}
