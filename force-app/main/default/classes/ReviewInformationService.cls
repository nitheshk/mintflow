/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ReviewInformationService extends AbstractService {
  @TestVisible
  private static ReviewInformationService serviceInstance;

  public ReviewInformationService() {
    super(ReviewInformationService.class);
  }

  /**
   * @description Provides a singleton instance of ReviewInformationService from which all other class methods can be accessed.
   * @author Digital Align Team | 11/12/2021
   * @return Object  singleton
   **/
  public static ReviewInformationService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ReviewInformationService) getInstance(
        ReviewInformationService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description Submit the application review by Primary/Joint
   * @author Digital Align Team | 11-12-2021
   * @param Id applicationId
   * @return Account
   **/
  global virtual Account reviewSubmit(Id applicationId) {
    Account application = ApplicationService.getInstance()
      .readApplicationWithChild(applicationId);

    String flowType = ApexRequest.getRequest().flowType;
    String applicantId = ApexRequest.getRequest().applicantId;

    switch on application.FinServ__CustomerType__c {
      when 'Consumer' {
        if (flowType == 'PrimaryFlow') {
          // send email to primary and joint
          primaryConsumerFlow(application);
        } else if (flowType == 'JointFlow') {
          // send email to primary  on completion
        }
      }
    }

    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 11-12-2021
   * @param account application
   * @return account
   **/
  global virtual account primaryConsumerFlow(account application) {
    Applicant__c primaryApplicant;
    List<dau01__Applicant__c> jointApplicants = new List<dau01__Applicant__c>();

    for (Applicant__c applicant : application.Applicants__r) {
      Set<String> applicantTypes = new Set<String>(
        applicant.ApplicantType__c.split(';')
      );
      if (applicantTypes.contains('Primary')) {
        primaryApplicant = applicant;
      } else if (applicantTypes.contains('Joint')) {
        jointApplicants.add(applicant);
      }
    }

    if (jointApplicants.isEmpty()) {
      //1. Send notification Primary applicant with resume link
      //2. Push Primary applicant to RPA Queue
    } else {
      //1. send Email to Primary applicant with resume link
      //2. Send Email to Joint with resume link
    }
    return application;
  }
}
