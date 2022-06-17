/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class CustomerPortalService extends AbstractService {
  @TestVisible
  private static CustomerPortalService serviceInstance;

  public CustomerPortalService() {
    super(CustomerPortalService.class);
  }

  /**
   * @description Provides a singleton instance of CustomerPortalService from which all other class methods can be accessed.
   * @author Digital Align Team | 02/11/2022
   * @return Object  singleton
   **/
  public static CustomerPortalService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (CustomerPortalService) getInstance(CustomerPortalService.class);
    }
    return serviceInstance;
  }
  /**
   * @description
   * @author Digital Align Team | 02-14-2022
   * @param map<string object> params
   * @return List<Application__c>
   **/
  global virtual List<Application__c> authorize(map<string, object> params) {
    Applicant__c applicant = (Applicant__c) JSON.deserialize(
      JSON.serialize(params.get('applicant')),
      Applicant__c.class
    );
    List<Application__c> applications = CustomerPortalRepository.fetchApplicationByApplicantDetails(
      applicant.mflow__LastFourDigitsofSSN__c,
      applicant.mflow__Email__c,
      applicant.mflow__LastName__c
    );
    log?.debug('Applications =' + applications);
    return applications;
  }

  /**
   * @description Fetch application by logged in applicant
   * @author Digital Align Team | 06-09-2022
   * @return List<Application__c>
   **/
  global virtual List<Application__c> fetchMyApplication() {
    Applicant__c applicant = ApplicantRepository.fetchSession(ApexRequest.getSessionId())?.mflow__Applicant__r;
    return CustomerPortalRepository.readMyApplication(applicant);
  }

  /**
   * @description read application with child record
   * @author Digital Align Team | 06-10-2022
   * @return Application__c
   **/
  global virtual Application__c readApplicationWithChild(Map<String, Object> params) {
    Id applicationId = (Id) params.get('applicationId');
    Application__c application = CustomerPortalRepository.readApplicationWithChild(applicationId);
    List<Applicant__c> applicants = CustomerPortalRepository.readApplicantsWithChild(
      new Map<Id, SObject>(application.Applicants__r).keySet()
    );
    List<FinancialAccount__c> financialAccounts = CustomerPortalRepository.readFinancialAccountsWithChild(
      new Map<Id, SObject>(application.mflow__FinancialAccounts__r).keySet()
    );
    //Combine result into single application object
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObjects('mflow__Applicants__r', applicants);
    builder.setChildObjects('mflow__FinancialAccounts__r', financialAccounts);
    return (Application__c) builder.build();
  }

  /**
   * @description
   * @author Digital Align Team | 06-16-2022
   * @param Map<String Object> params
   * @return Object
   **/
  global virtual Object resumeApplication(Map<String, Object> params) {
    Id applicationId = (Id) params.get('applicationId');
    Id applicantId = (Id) params.get('applicantId');
    String resumeType = (String) params.get('resumeType');
    Applicant__c applicant;
    if (String.isNotBlank(applicationId) && String.isBlank(applicantId)) {
      applicant = CustomerPortalRepository.readPrimaryApplicant(applicationId);
    } else if (String.isNotBlank(applicationId) && String.isNotBlank(applicantId)) {
      applicant = CustomerPortalRepository.readApplicantById(applicationId, applicantId);
    }

    if (applicant == null) {
      throw new CustomException(System.Label.Applicant_ApplicantNotFound);
    }

    if (resumeType == 'Url') {
      Map<String, String> paramsEncrypt = new Map<String, String>();
      if (applicant.ApplicantType__c == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        paramsEncrypt.put('flw', 'ApplicationFlow');
        paramsEncrypt.put('urlSuffix', '/savings/main-app/otp');
        paramsEncrypt.put('aplType', ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE);
      } else {
        paramsEncrypt.put('flw', 'JointFlow');
        paramsEncrypt.put('urlSuffix', '/savings/joint-app/otp');
        paramsEncrypt.put('aplType', ApplicationConstant.APPLICANT_JOINT_RECORDTYPE);
      }
      paramsEncrypt.put('appId', applicant.application__c);
      paramsEncrypt.put('aplId', applicant.Id);
      paramsEncrypt.put('ch', 'Virtual');
      return CustomerEmailService.getInstance().generateUrl(paramsEncrypt);
    } else if (resumeType == 'Email') {
      CustomerEmailService.getInstance().resumeApplication(applicant);
      return 'Email Sent Successfully';
    }
    return null;
  }
}
