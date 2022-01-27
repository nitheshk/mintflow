/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicationSubmissionService extends AbstractService {
  @TestVisible
  private static ApplicationSubmissionService serviceInstance;

  public ApplicationSubmissionService() {
    super(ApplicationSubmissionService.class);
  }

  /**
   * @description Provides a singleton instance of ApplicationSubmissionService from which all other class methods can be accessed.
   * @author Digital Align Team | 01/25/2022
   * @return Object  singleton
   **/
  public static ApplicationSubmissionService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicationSubmissionService) getInstance(
        ApplicationSubmissionService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description final application submit
   * @author Digital Align Team | 01-25-2022
   * @param String data
   * @return Account
   **/
  global virtual Account submitApplication(String data) {
    log?.debug('Inside submitApplication');
    Account application = SubmissionRepository.readApplicationWithApplicants(
      ApexRequest.getApplicationId()
    );
    HttpBuilder.Response response = RpaProcessService.getInstance()
      .scheduleApplication(application);
    if (response.statusCode == 400) {
      application.FinServ__Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
      application.Stage__c = 'Exception';
      application.mflow__FlowState__c = '';
    } else {
      application.FinServ__Status__c = ApplicationConstant.SUBMITTED;
      application.Stage__c = 'Submitted';
    }

    for (Applicant__c applicant : application.Applicants__r) {
      if (
        applicant.RecordType.Name ==
        ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
      ) {
        applicant.mflow__Status__c = application.FinServ__Status__c;
        break;
      }
    }
    SubmissionRepository.upsertRecord(application);
    SubmissionRepository.upsertRecords(application.Applicants__r);
    log?.debug('Completed submitApplication');
    return application;
  }
}
