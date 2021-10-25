/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicantService extends AbstractService {
  @TestVisible
  private static ApplicantService serviceInstance;

  public ApplicantService() {
    super(ApplicantService.class);
  }

  /**
   * @description Provides a singleton instance of ApplicantService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static ApplicantService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicantService) getInstance(ApplicantService.class);
    }
    return serviceInstance;
  }

  /**
   * @description Save applicants
   * @author Digital Align Team | 10-25-2021
   * @param String applicationId
   * @param List<dau01__Applicant__c> applicants
   * @return virtual
   **/
  global virtual List<dau01__Applicant__c> saveApplicants(
    String applicationId,
    List<dau01__Applicant__c> applicants
  ) {
    log?.fine('Inside save applicants');
    List<dau01__Applicant__c> applicantToUpdate = new List<dau01__Applicant__c>();
    List<dau01__Applicant__c> applicantToDelete = new List<dau01__Applicant__c>();

    if (applicants?.size() > 0) {
      for (Applicant__c applicant : applicants) {
        if (
          applicant.dau01__DeleteRecord__c == true &&
          String.isBlank(applicant.Id)
        ) {
          applicantToDelete.add(applicant);
        } else {
          if (String.isNotBlank(applicant.dau01__Application__c)) {
            applicant.dau01__Application__c = applicationId;
          }
          applicantToUpdate.add(applicant);
        }
      }
    }

    ApplicantRepository.upsertRecords(applicantToUpdate);

    log?.fine('Finish save applicants');
    return applicantToUpdate;
  }

  /**
   * @description
   * @author Digital Align Team | 10-25-2021
   * @param List<dau01__Applicant__c> applicants
   * @return Boolean
   **/
  global virtual Boolean deleteApplicants(
    List<dau01__Applicant__c> applicants
  ) {
    if (!applicants.isEmpty()) {
      ApplicantRepository.deleteRecords(applicants);
      // need to delete child records
    }
    return true;
  }
}
