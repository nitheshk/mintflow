/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class AlloyService extends AbstractService {
  @TestVisible
  private static AlloyService serviceInstance;

  public AlloyService() {
    super(AlloyService.class);
  }

  /**
   * @description Provides a singleton instance of AlloyService from which all other class methods can be accessed.
   * @author Digital Align Team | 03/28/2022
   * @return Object  singleton
   **/
  public static AlloyService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (AlloyService) getInstance(AlloyService.class);
    }
    return serviceInstance;
  }

  /**
   * @description to verify KYC of the applicant using alloy provider
   * @author Digital Align Team | 03-08-2022
   * @param Application__c application
   * @return Applicant__c
   **/
  global List<Applicant__c> verifyKYC(Map<String, Object> params) {
    AlloyProvider provider = new AlloyProvider();
    try {
      Flow.initialize(ApexRequest.getApplicationId());
      Flow.setFlow('Alloy KYC');
      Flow.setSubFlow(APINames.AlloyKYC.name(), ApexRequest.getApplicationId());
      List<Applicant__c> applicants = (lIST<Applicant__c>) params.get('Applicants');
      if (applicants.size() > 0) {
        provider.doIDVVerification(applicants[0], params);
        Flow.setSubFlowPassed('Passed'); //TODO: to change later
      } else {
        Flow.setSubFlowFailed('Failed'); //TODO: to change later
        throw new customException('Unable to find any applicant for KYC');
      }
      return applicants;
    } catch (exception ex) {
      throw new customException('Unable to do KYC for the applicant');
    }
  }
}
