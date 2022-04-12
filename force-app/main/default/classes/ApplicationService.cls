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
      serviceInstance = (ApplicationService) getInstance(ApplicationService.class);
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
    String pid = (String) params.get('pid');
    User currentUser = UserUtils.getCurrentUser();
    String baseUrl, suffixUrl;
    if (
      currentUser.Profile.Name == CommunityConstant.FIN_INST_EMPLOYEE_USER_PROFILE ||
      currentUser.Profile.Name == CommunityConstant.CUSTOMER_COMMUNITY_USER_PROFILE
    ) {
      baseUrl = GenericUtils.fetchLoginURL();
    } else if (UserUtils.isGuestUser()) {
      baseUrl = SiteSetting__c.getInstance().OnlineSiteUrl__c;
    } else {
      baseUrl = GenericUtils.fetchLoginURL() + '/apex';
    }

    if (String.isNotBlank(pid)) {
      suffixUrl = '/OpenAccount?pid=' + pid + '#/home';
    } else {
      suffixUrl = SiteSetting__c.getInstance().OnlineAccountOpeningUrl__c;
    }
    result.put('url', baseUrl + suffixUrl);
    log?.info('startApplication -> Url -> ' + result.get('url'));
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
      User currentUser = UserUtils.getCurrentUser();
      if (String.isNotBlank(currentUser.Channel__c)) {
        application.CreatedChannel__c = currentUser.Channel__c;
        application.LastUsedChannel__c = currentUser.Channel__c;
      } else {
        application.CreatedChannel__c = ApplicationConstant.CHANNEL_VIRTUAL;
        application.LastUsedChannel__c = ApplicationConstant.CHANNEL_VIRTUAL;
      }
    }
    application.ApplicationType__c = 'Deposit'; //Also Decide in Financial Account Creation
    application.IsExistingCustomer__c = false; //Also Decide in Financial Account Creation
    application.Source__c = 'Online';
    application.FlowState__c = ApplicationConstant.GET_STARTED;
    application.FlowType__c = ApplicationConstant.FLOW_TYPE_APPLICATION;
    application.Version__c = ApplicationConfiguration__c.getInstance().PackageVersion__c;
    application.IPAddress__c = ApplicationServiceHelper.getInstance().getIpAddress();
    application = ApplicationServiceHelper.getInstance().resolveBranchLocation(application);
    ApplicationRepository.upsertRecord(application);
    /*** */
    /*** Create Empty Primary Applicant   */
    Applicant__c applicant = ApplicantService.getInstance().createInitialPrimaryApplicant(application);
    /***   */
    /*** Create Financial Account Base on Param */
    FinancialAccountService.getInstance().createInitialFinancialAccount(application);
    /***  */

    applicant = ApplicantRepository.readApplicantWithApplication(applicant.Id);

    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicantId(applicant.id);
    ApexRequest.setFlowType('ApplicationFlow');
    ApexRequest.setApplicantType(ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE);

    applicant = SecurityUtils.createSessionForApplicant(applicant);
    ApplicationRepository.upsertRecord(applicant);

    application = this.readApplicationWithChild(application.id);

    params.put('applicationId', ApexRequest.getApplicationId());
    params.put('applicantId', ApexRequest.getApplicantId());
    params.put('applicantType', ApexRequest.getApplicantType());
    params.put('flowType', ApexRequest.getFlowType());
    params.put('channel', application.LastUsedChannel__c);
    params.put('applicationNumber', application.Name);
    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 04-11-2022
   * @return Application__c
   **/
  global virtual Application__c readApplicationWithChild() {
    Application__c application;
    if (ApexRequest.getApplicantType() == 'Primary') {
      application = this.readApplicationWithChild(ApexRequest.getApplicationId());
    } else if (ApexRequest.getApplicantType() == 'Joint') {
      application = this.readApplicationWithChild(ApexRequest.getApplicationId(), ApexRequest.getApplicantId());
    } else {
      throw new CustomException(System.Label.Applicant_ApplicantTypeNotFound);
    }
    return application;
  }

  /**
   * @description Read application by parameter passed
   * @author Digital Align Team | 10-21-2021
   * @param Map<String Object> params
   * @return Application__c
   **/
  global virtual Application__c readApplicationWithChild(Id applicationId) {
    Application__c application = ApplicationRepository.readApplicationWithChild(applicationId);

    List<Applicant__c> applicants = ApplicantService.getInstance().readApplicantsWithChild(application.Applicants__r);
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
  global virtual Application__c readApplicationWithChild(Id applicationId, Id applicantId) {
    Application__c application = ApplicationRepository.readApplicationWithChild(applicationId, applicantId);

    Applicant__c applicant = ApplicantService.getInstance().readApplicantWithChild(applicantId);
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
  global virtual Map<String, Object> resumeApplication(Map<String, Object> params) {
    log?.fine('Inside resumeApplication');
    String vmf = (String) params.get('vmf');
    params.remove('vmf');
    //decrypt the url
    SecurityUtils.CipherDTO cipher;
    try {
      cipher = SecurityUtils.extractToken(vmf);
    } catch (Exception ex) {
      throw new CustomException(System.Label.Resume_TheSpecifiedUrlWasCorrupted);
    }
    if (cipher.edt < Datetime.now()) {
      throw new CustomException(System.Label.Resume_TheSpecifiedUrlWasExpired);
    }

    params.put('applicantType', cipher.aplType);
    params.put('channel', cipher.ch);
    params.put('applicationId', cipher.appId);
    params.put('applicantId', cipher.aplId);
    params.put('flowType', cipher.flw);

    Applicant__c applicant = ApplicantRepository.readApplicantWithApplication(cipher.aplId);
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
      application = ApplicationService.getInstance().readApplicationWithChild(ApexRequest.getApplicationId());
    } else if (ApexRequest.getApplicantType() == 'Joint') {
      application = ApplicationService.getInstance()
        .readApplicationWithChild(ApexRequest.getApplicationId(), ApexRequest.getApplicantId());
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
      return ApplicationPersistService.getInstance().saveApplication(application);
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
  global virtual Application__c preserveApplication(Application__c application) {
    //current applicant
    Applicant__c currentApplicant;
    if (ApexRequest.getApplicantType() == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
      application.Status__c = ApplicationConstant.SAVED;
      for (Applicant__c applicant : application.Applicants__r) {
        if (applicant.ApplicantType__c == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
          currentApplicant = applicant;
          applicant.mflow__Status__c = ApplicationConstant.SAVED;
          break;
        }
      }
    } else if (ApexRequest.getApplicantType() == ApplicationConstant.APPLICANT_JOINT_RECORDTYPE) {
      for (Applicant__c applicant : application.Applicants__r) {
        if (applicant.ApplicantType__c.Contains(ApplicationConstant.APPLICANT_JOINT_RECORDTYPE)) {
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
      if (String.isBlank(ApexRequest.getRequest().currentPage)) {
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
        Application__c application = new Application__c(Id = Apexrequest.getApplicationId());
        return helper.updateFlowState(application, applicants);
      } else if (entity instanceof Applicant__c) {
        Applicant__c applicant = (Applicant__c) entity;
        Application__c application = new Application__c(Id = Apexrequest.getApplicationId());
        return helper.updateFlowState(application, new List<Applicant__c>{ applicant });
      } else if (entity instanceof List<FinancialAccount__c>) {
        //List<FinancialAccount__c> finAccounts = (List<FinancialAccount__c>) entity;
        Application__c application = ApplicationRepository.readApplicationWithPrimary(ApexRequest.getApplicationId());
        return helper.updateFlowState(application, application.Applicants__r);
      }
    } catch (Exception ex) {
      log?.error(ex);
      log?.error('Exception Has Ignored');
    }
    return entity;
  }

  /**
   * @description Clone existing app to create new application based on product
   * @author Digital Align Team | 09-29-2021
   * @return String
   **/
  global virtual String startReferralApplication() {
    log?.fine('Inside startReferralApplication');
    String cvmf = PageUtils.getCurrentPageParameters('cvmf');
    Map<String, Object> params;
    try {
      params = (Map<String, Object>) JSON.deserializeUntyped(SecurityUtils.decryptBase64(cvmf));
    } catch (Exception ex) {
      throw new CustomException(System.Label.Resume_TheSpecifiedUrlWasCorrupted);
    }
    Datetime edt = DateUtils.convertJsonStringToDateTime(params.get('edt'));
    if (edt < Datetime.now()) {
      throw new CustomException(System.Label.Resume_TheSpecifiedUrlWasExpired);
    }
    Application__c application;
    Savepoint sp = Database.setSavepoint();
    try {
      application = ApplicationServiceHelper.getInstance().cloneApplicationRecord(params);
    } catch (Exception ex) {
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
    //Create new Token For Reusme Application Immediatly
    SecurityUtils.CipherDTO cipher = new SecurityUtils.CipherDTO();
    cipher.aplType = ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE;
    cipher.flw = 'ApplicationFlow';
    cipher.appId = application.Id;
    cipher.aplId = ApexRequest.getApplicantId();
    cipher.ch = application.CreatedChannel__c;
    cipher.edt = Datetime.now()
      .addHours((Integer) ApplicationConfiguration__c.getInstance().EmailLinkExpirationTime__c);
    String vmf = SecurityUtils.encryptBase64(JSON.serialize(cipher, true));
    log?.fine('Exit StartReferralApplication');
    return vmf;
  }
}
