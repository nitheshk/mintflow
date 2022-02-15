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
      serviceInstance = (CustomerPortalService) getInstance(
        CustomerPortalService.class
      );
    }
    return serviceInstance;
  }
  /**
   * @description
   * @author Digital Align Team | 02-14-2022
   * @param map<string object> params
   * @return virtual
   **/
  global virtual List<Account> authorize(map<string, object> params) {
    Applicant__c applicant = (Applicant__c) JSON.deserialize(
      JSON.serialize(params.get('applicant')),
      Applicant__c.class
    );
    List<Account> applications = CustomerPortalRepository.fetchApplicationByApplicantDetails(
      applicant.mflow__LastFourDigitsofSSN__c,
      applicant.mflow__Email__c,
      applicant.mflow__LastName__c
    );
    log?.debug('Applications =' + applications);
    return applications;
  }
}
