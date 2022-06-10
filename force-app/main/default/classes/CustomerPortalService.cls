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
}
