/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class ApplicationService extends AbstractService {
  @TestVisible
  private static ApplicationService serviceInstance;
  private ApplicationServiceHelper helper = ApplicationServiceHelper.getInstance();
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
    log?.fine('Inside startApplication -> params -> ' + JSON.serialize(params));

    String recordId = (String) params?.get('recordId');
    if (String.isNotBlank(recordId)) {
      // encryption
      // this for start application from existing application
      String sObjectType = ((Id) recordId)
        .getSobjectType()
        .getDescribe()
        .getName();
      switch on sObjectType {
        when 'Application__c' {
          System.debug('Inside ' + sObjectType);
        }
        when 'FinancialAccount' {
          System.debug('Inside ' + sObjectType);
        }
      }
    } else {
      //start new application from online community page, redirect to site url
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
   * @return Application__c
   **/
  global virtual Application__c createApplication(Map<String, Object> params) {
    log?.fine('Inside createApplication');
    /**** Create init Application */
    Application__c application = new Application__c();
    application.Status__c = ApplicationConstant.IN_PROGRESS;
    if (params.get('ch') != null) {
      application.CreatedChannel__c = (String) params.get('ch');
      application.LastUsedChannel__c = (String) params.get('ch');
    } else {
      application.CreatedChannel__c = ApplicationConstant.CHANNEL_VIRTUAL;
      application.LastUsedChannel__c = ApplicationConstant.CHANNEL_VIRTUAL;
    }
    //#pending  value need to decide based on the parameter
    application.ApplicationType__c = 'Consumer';
    //#pending this true when no product is Present
    application.isMemberFlow__c = true;
    application.FlowState__c = 'GetStarted';
    application.FlowType__c = 'ApplicationFlow';
    // #pending update version from custom setting
    application.Version__c = ApplicationConfiguration__c.getInstance()
      .PackageVersion__c;
    application.IPAddress__c = ApplicationServiceHelper.getInstance()
      .getIpAddress();
    application = ApplicationServiceHelper.getInstance()
      .resolveBranchLocation(application);
    ApplicationRepository.upsertRecord(application);
    /*** */
    /*** Create Empty Primary Applicant   */
    Applicant__c applicant = new Applicant__c();
    applicant.ApplicantType__c = ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE;
    applicant.RecordTypeId = SObjectUtils.recordTypeIdByName(
      Applicant__c.SObjectType,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
    );
    applicant.Status__c = ApplicationConstant.IN_PROGRESS;
    applicant.Application__c = application.Id;
    ApplicationRepository.upsertRecord(applicant);
    applicant = ApplicantRepository.readApplicantWithApplication(applicant.Id);
    /***   */

    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicantId(applicant.id);
    ApexRequest.setFlowType('ApplicationFlow');
    ApexRequest.setApplicantType(
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
    );

    applicant = SecurityUtils.createSessionForApplicant(applicant);
    ApplicationRepository.upsertRecord(applicant);

    application = ApplicationRepository.readApplicationWithApplicants(
      application.Id
    );

    params.put('applicationId', ApexRequest.getApplicationId());
    params.put('applicantId', ApexRequest.getApplicantId());
    params.put('applicantType', ApexRequest.getApplicantType());
    params.put('flowType', ApexRequest.getFlowType());
    params.put('channel', application.LastUsedChannel__c);
    params.put('applicationNumber', application.Name);
    return application;
  }

  /**
   * @description Read application by parameter passed
   * @author Digital Align Team | 10-21-2021
   * @param Map<String Object> params
   * @return Application__c
   **/
  global virtual Application__c readApplicationWithChild(Id applicationId) {
    Application__c application = ApplicationRepository.readApplicationWithChild(
      applicationId
    );

    List<Applicant__c> applicants = ApplicantService.getInstance()
      .readApplicantsWithChild(application.Applicants__r);
    List<FinancialAccount__c> financialAccounts = FinancialAccountService.getInstance()
      .readFinancialAccountsWithChild(application.mflow__FinancialAccounts__r);

    //Combine result into single application object
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObjects('mflow__Applicants__r', applicants);
    builder.setChildObjects('mflow__FinancialAccounts__r', financialAccounts);
    return (Application__c) builder.build();
  }

  /**
   * @description Read application with specific applicant
   * @author Digital Align Team | 11-19-2021
   * @param Id applicationId
   * @param Id applicantId
   * @return Application__c
   **/
  global virtual Application__c readApplicationWithChild(
    Id applicationId,
    Id applicantId
  ) {
    Application__c application = ApplicationRepository.readApplicationWithChild(
      applicationId,
      applicantId
    );

    Applicant__c applicant = ApplicantService.getInstance()
      .readApplicantWithChild(applicantId);
    List<FinancialAccount__c> financialAccounts = FinancialAccountService.getInstance()
      .readFinancialAccountsWithChild(application.mflow__FinancialAccounts__r);

    //Combine result into single application object
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObject('mflow__Applicants__r', applicant);
    builder.setChildObjects('mflow__FinancialAccounts__r', financialAccounts);
    return (Application__c) builder.build();
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
    params.remove('vmf');
    //decrypt the url
    SecurityUtils.CipherDTO cipher;
    try {
      cipher = SecurityUtils.extractToken(vmf);
    } catch (Exception ex) {
      throw new CustomException(
        System.Label.Resume_TheSpecifiedUrlWasCorrupted
      );
    }
    if (cipher.edt < Datetime.now()) {
      throw new CustomException(System.Label.Resume_TheSpecifiedUrlWasExpired);
    }

    params.put('applicantType', cipher.aplType);
    params.put('channel', cipher.ch);
    params.put('applicationId', cipher.appId);
    params.put('applicantId', cipher.aplId);
    params.put('flowType', cipher.flw);

    Applicant__c applicant = ApplicantRepository.readApplicantWithApplication(
      cipher.aplId
    );
    if (applicant == null) {
      throw new CustomException(System.Label.Applicant_ApplicantNotFound);
    }
    // params.put(
    //   'maskedEmail',
    //   applicant.Email__c.replaceAll('(^[^@]{2}|(?!^)\\G)[^@]', '$1*')
    // );
    // params.put('maskedPhone', applicant.Phone__c.replaceAll('.(?=.{4})', '*'));
    params.put('fullName', applicant.ApplicantName__c);
    params.put('applicationNumber', applicant.Application__r.Name);
    AuthenticationService.getInstance().generateOTP(cipher.aplId);
    return params;
  }

  /**
   * @description Handle Page Refresh
   * @author Digital Align Team | 11-22-2021
   * @param Map<String Object> params
   * @return Application__c
   **/
  global virtual Application__c refreshPage(Map<String, Object> params) {
    log?.fine('Inside refreshPage');
    //get existing token from cookie
    String sessionToken = PageUtils.getCookie('token').getValue();
    try {
      sessionToken = sessionToken.replace(' ', '+');
      ApexRequest.setToken(sessionToken);
      SecurityUtils.validateSession();
      SecurityUtils.refreshToken();
    } catch (Exception ex) {
      throw new CustomException(System.Label.Session_InvalidSessionToken);
    }

    Application__c application;
    if (ApexRequest.getApplicantType() == 'Primary') {
      application = ApplicationService.getInstance()
        .readApplicationWithChild(ApexRequest.getApplicationId());
    } else if (ApexRequest.getApplicantType() == 'Joint') {
      application = ApplicationService.getInstance()
        .readApplicationWithChild(
          ApexRequest.getApplicationId(),
          ApexRequest.getApplicantId()
        );
    }

    params.put('applicantType', ApexRequest.getApplicantType());
    //params.put('channel', cipher.ch);
    params.put('applicationId', ApexRequest.getApplicationId());
    params.put('applicantId', ApexRequest.getApplicantId());
    params.put('flowType', ApexRequest.getFlowType());
    params.put('applicationNumber', application.Name);
    return application;
  }

  /**
   * @description Save Application
   * @author Digital Align Team | 11-20-2021
   * @param Application__c application
   * @return Application__c
   **/
  global virtual Application__c saveApplication(Application__c application) {
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
   * @description preserve Application
   * @author Digital Align Team | 02-07-2022
   * @param Application__c application
   * @return Application__c
   **/
  global virtual Application__c preserveApplication(
    Application__c application
  ) {
    //current applicant
    Applicant__c currentApplicant;
    if (
      ApexRequest.getApplicantType() ==
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
    ) {
      application.Status__c = ApplicationConstant.SAVED;
      for (Applicant__c applicant : application.Applicants__r) {
        if (
          applicant.ApplicantType__c ==
          ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
        ) {
          currentApplicant = applicant;
          applicant.mflow__Status__c = ApplicationConstant.SAVED;
          break;
        }
      }
    } else if (
      ApexRequest.getApplicantType() ==
      ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
    ) {
      for (Applicant__c applicant : application.Applicants__r) {
        if (
          applicant.ApplicantType__c.Contains(
            ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
          )
        ) {
          currentApplicant = applicant;
          applicant.mflow__Status__c = ApplicationConstant.SAVED;
          break;
        }
      }
    }
    application = this.saveApplication(application);
    //send saved email to resume
    CustomerEmailService.getInstance().savedApplication(currentApplicant);
    return application;
  }

  /**
   * @description  delete object by Id
   * @author Digital Align Team | 11-10-2021
   * @param Id recordId
   * @return Boolean
   **/
  global virtual Boolean deleteEntities(List<Id> recordIds) {
    Savepoint sp = Database.setSavepoint();
    try {
      for (Id recordId : recordIds) {
        ApplicationPersistService.getInstance().deleteEntity(recordId);
      }
      return true;
    } catch (Exception ex) {
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
  }

  /**
   * @description
   * @author Digital Align Team | 02-04-2022
   * @param Object entity
   * @return Object
   **/
  global virtual Object updateFlowState(Object entity) {
    try {
      log?.fine('Inside updateFlowState');
      if (!ApexRequest.getParams().containsKey('flowState')) {
        return entity;
      }
      if (entity instanceof Application__c) {
        Application__c application = (Application__c) entity;
        if (application.Applicants__r != null) {
          return helper.updateFlowState(application, application.Applicants__r);
        } else {
          return helper.updateFlowState(application, new List<Applicant__c>());
        }
      } else if (entity instanceof List<Applicant__c>) {
        List<Applicant__c> applicants = (List<Applicant__c>) entity;
        Application__c application = new Application__c(
          Id = Apexrequest.getApplicationId()
        );
        return helper.updateFlowState(application, applicants);
      } else if (entity instanceof Applicant__c) {
        Applicant__c applicant = (Applicant__c) entity;
        Application__c application = new Application__c(
          Id = Apexrequest.getApplicationId()
        );
        return helper.updateFlowState(
          application,
          new List<Applicant__c>{ applicant }
        );
      } else if (entity instanceof List<FinancialAccount__c>) {
        //List<FinancialAccount__c> finAccounts = (List<FinancialAccount__c>) entity;
        Application__c application = ApplicationRepository.readApplicationWithPrimary(
          ApexRequest.getApplicationId()
        );
        return helper.updateFlowState(application, application.Applicants__r);
      }
    } catch (Exception ex) {
      log?.error(ex);
      log?.error('Exception Has Ignored');
    }
    return entity;
  }
}
