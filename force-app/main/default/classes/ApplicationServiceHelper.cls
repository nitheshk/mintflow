/**
 * Copyright (c) 2021 Digital Align
 * @group Helper
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class ApplicationServiceHelper extends AbstractService {
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
      serviceInstance = (ApplicationServiceHelper) getInstance(ApplicationServiceHelper.class);
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
        ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
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
   * @description resolve branch location
   * @author Digital Align Team | 12-03-2021
   * @param Application__c application
   * @return Application__c
   **/
  global virtual Application__c resolveBranchLocation(Application__c application) {
    application.BranchCode__c = '0001';
    application.BranchName__c = 'Main Branch';
    return application;
  }

  /**
   * @description update application flow state
   * @author Digital Align Team | 01-13-2022
   * @param Application__c application
   * @param Applicant__c applicant
   * @return Application__c
   **/
  global virtual Application__c updateFlowState(Application__c application, List<Applicant__c> applicants) {
    if (ApexRequest.getApplicantType() == 'Primary') {
      for (Applicant__c applicant : applicants) {
        if (applicant.mflow__ApplicantType__c == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
          applicant.FlowState__c = (String) ApexRequest.getParams('flowState');
          applicant.FlowType__c = ApexRequest.getFlowType();
          applicant.sessionExpireTime__c = Datetime.now()
            .addMinutes((Integer) ApplicationConfiguration__c.getOrgDefaults().SessionExpirationTime__c);
          ApplicationRepository.UpsertRecord(applicant);
          break;
        }
      }
      application.FlowState__c = (String) ApexRequest.getParams('flowState');
      application.FlowType__c = ApexRequest.getFlowType();
      ApplicationRepository.UpsertRecord(application);
    } else if (ApexRequest.getApplicantType() == 'Joint') {
      for (Applicant__c applicant : applicants) {
        if (applicant.Id == ApexRequest.getApplicantId()) {
          applicant.FlowState__c = (String) ApexRequest.getParams('flowState');
          applicant.FlowType__c = ApexRequest.getFlowType();
          applicant.sessionExpireTime__c = Datetime.now()
            .addMinutes((Integer) ApplicationConfiguration__c.getOrgDefaults().SessionExpirationTime__c);
          ApplicationRepository.UpsertRecord(applicant);
          break;
        }
      }
    }
    return application;
  }
}
