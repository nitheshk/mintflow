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
        when 'Account' {
          System.debug('Inside ' + sObjectType);
        }
        when 'FinancialAccount' {
          System.debug('Inside ' + sObjectType);
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
    application.FinServ__Status__c = ApplicationConstant.IN_PROGRESS;
    if (params.get('channel') != null) {
      application.CreatedChannel__c = (String) params.get('channel');
      application.FinServ__LastUsedChannel__c = (String) params.get('channel');
    } else {
      application.CreatedChannel__c = ApplicationConstant.CHANNEL_VIRTUAL;
      application.FinServ__LastUsedChannel__c = ApplicationConstant.CHANNEL_VIRTUAL;
    }
    // #pending  value need to decide based on the parameter
    application.FinServ__CustomerType__c = 'Consumer';
    application.mflow__isMemberFlow__c = true;
    application.UserAccountType__c = 'CustomerApplication';
    application.FlowState__c = 'GetStarted';
    application.FlowType__c = 'ApplicationFlow';
    application.IPAddress__c = ApplicationServiceHelper.getInstance()
      .getIpAddress();
    // #pending update version from custom setting
    application.Version__c = 'V1.0.1';
    application = ApplicationServiceHelper.getInstance()
      .resolveBranchLocation(application);
    // #info
    // Added for customer community user license only
    // Work for Cusotmer Community plus user without owner assingment
    application.OwnerId = UserUtils.getCurrentUser().CreatedById;
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
      .readFinancialAccountsWithChild(application.mflow__FinancialAccounts__r);

    //Combine result into single application object
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObjects('mflow__Applicants__r', applicants);
    builder.setChildObjects('mflow__FinancialAccounts__r', financialAccounts);
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

    Applicant__c applicant = ApplicantService.getInstance()
      .readApplicantWithChild(applicantId);
    List<FinServ__FinancialAccount__c> financialAccounts = FinancialAccountService.getInstance()
      .readFinancialAccountsWithChild(application.mflow__FinancialAccounts__r);

    //Combine result into single application object
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObject('mflow__Applicants__r', applicant);
    builder.setChildObjects('mflow__FinancialAccounts__r', financialAccounts);
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

    Applicant__c applicant = ApplicantRepository.readApplicantById(
      cipher.aplId
    );
    if (applicant == null) {
      throw new CustomException(System.Label.Applicant_ApplicantNotFound);
    }
    params.put(
      'maskedEmail',
      applicant.Email__c.replaceAll('(^[^@]{2}|(?!^)\\G)[^@]', '$1*')
    );
    params.put('maskedPhone', applicant.Phone__c.replaceAll('.(?=.{4})', '*'));
    params.put('fullName', applicant.Name);
    AuthenticationService.getInstance().generateOTP(cipher.aplId);
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
    String sessionToken = PageUtils.getCookie('token').getValue();
    try {
      sessionToken = sessionToken.replace(' ', '+');
      ApexRequest.setToken(sessionToken);
      SecurityUtils.validateSession();
    } catch (Exception ex) {
      throw new CustomException(System.Label.Session_InvalidSessionToken);
    }

    Account application;
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
   * @description Create Financial MemberShip account and Primary Account
   * @author Digital Align Team | 12-02-2021
   * @param String resultJson
   * @return Account
   **/
  global virtual Account processMembershipKYC(String resultJson) {
    ApplicationSubmissionResponse.KYCResult kycResult = (ApplicationSubmissionResponse.KYCResult) JSON.deserialize(
      resultJson,
      ApplicationSubmissionResponse.KYCResult.class
    );
    // When result is null
    if (kycResult == null) {
      throw new CustomException('Unable to process the empty request');
    }
    Account application = ApplicationRepository.readApplicationForKYC(
      kycResult.ApplicationId
    );
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicationName(application.ApplicationNumber__c);

    if (application.FinServ__KYCStatus__c == ApplicationConstant.KYC_PASSED) {
      throw new CustomException('Kyc has already passed for the application ');
    }

    //chatter post on record level
    NotificationBuilder.chatterMessagePost(
      application.Id,
      'Kyc Result : ' + resultJson
    );

    // roll back whole transaction on failure
    Savepoint sp = Database.setSavepoint();
    try {
      // Primary is Existing Customer
      if (kycResult.IsExistingCustomer == true) {
        return KycReviewService.getInstance()
          .processExistingMember(application, kycResult);
      }

      // Primary Kyc is Approved/Failed and Joint KYC is Approved/Failed
      // update Applicant detail accordingly
      application = KycReviewService.getInstance()
        .updateApplicationKycDetails(application, kycResult);

      // if Application kyc status is approved, then proceed with creating Account & Contact for primary
      // And Open Membership Financial Account and relation with applicant

      if (application.FinServ__KYCStatus__c == ApplicationConstant.KYC_PASSED) {
        ApplicantService.getInstance().createMemberAccount(application);

        application = FinancialAccountService.getInstance()
          .createMembershipFinancialAccount(application);

        //Send Funding Email Link to primary
        CustomerEmailService.getInstance()
          .fundingLinkOnKycApproval(application);
        NotificationService.getInstance()
          .dispatchKycNotification(
            'onSuccessKycProcess',
            application.Id,
            application.Name,
            null
          );
      } else {
        NotificationService.getInstance()
          .dispatchKycNotification(
            'onReviewKycProcess',
            application.Id,
            application.Name,
            null
          );
      }
      return application;
    } catch (Exception ex) {
      NotificationService.getInstance()
        .dispatchKycNotification(
          'onExceptionKycProcess',
          ApexRequest.getApplicantId(),
          ApexRequest.getApplicationName(),
          ex.getStackTraceString()
        );
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
  }

  /**
   * @description
   * @author Digital Align Team | 01-12-2022
   * @param Account application
   * @return Account
   **/
  global virtual Account updateApplicationFlowState(Account application) {
    if (!ApexRequest.getParams().containsKey('flowState')) {
      return application;
    }
    return helper.updateApplicationFlowState(application);
  }
}
