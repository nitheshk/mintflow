/**
 * Copyright (c) 2021 Digital Align
 * @group Helper
 * @author Digital Align Team
 * @reference
 * @description Application service helper
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class ApplicantServiceHelper extends AbstractService {
  @TestVisible
  private static ApplicantServiceHelper serviceInstance;

  public ApplicantServiceHelper() {
    super(ApplicantServiceHelper.class);
  }

  /**
   * @description Provides a singleton instance of ApplicantServiceHelper from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  global static ApplicantServiceHelper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicantServiceHelper) getInstance(ApplicantServiceHelper.class);
    }
    return serviceInstance;
  }

  /**
   * @description  Send Email to reference person on family connect
   * @author Digital Align Team | 11-09-2021
   **/
  global virtual void notifyFamilyConnectReference() {
    log?.debug('inside notifyFamilyConnectReference');
    try {
      List<Applicant__c> applicants = ApplicantRepository.readApplicantsByApplicationId(ApexRequest.getApplicationId());
      CustomerEmailService.getInstance().notifyFamilyMember(applicants);
    } catch (exception ex) {
      log?.error(ex);
    }
  }
}
