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
  global virtual Account reviewInformationSubmit(Id applicationId) {
    Account application = ApplicationRepository.readApplicationWithApplicants(
      applicationId
    );

    String applicantType = ApexRequest.getApplicantType();

    if (applicantType == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
      // send email to primary and joint
      primaryConsumerFlow(application);
    } else if (
      applicantType == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
    ) {
      // send email to primary on completion
      jointConsumerFlow(application);
    }

    return application;
  }

  /**
   * @description Primary Review Submit action
   * @author Digital Align Team | 11-12-2021
   * @param account application
   * @return account
   **/
  global virtual account primaryConsumerFlow(account application) {
    log?.info('Inside primaryConsumerFlow');
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

    //Mark currrent primary applicant has submitted the application
    primaryApplicant.Status__c = ApplicationConstant.SUBMITTED;
    ApplicantRepository.upsertRecord(primaryApplicant);

    if (jointApplicants.isEmpty()) {
      //1. Send notification Primary applicant with resume link
      CustomerEmailService.getInstance()
        .reviewInformationSubmitted(
          new List<dau01__Applicant__c>{ primaryApplicant },
          'PrimaryReviewInformationSubmitted'
        );
      //2. Push Primary applicant to RPA Queue
      //#pending
      //#RPA
    } else {
      //1. send Email to Primary applicant with resume link
      CustomerEmailService.getInstance()
        .reviewInformationSubmitted(
          new List<dau01__Applicant__c>{ primaryApplicant },
          'PrimaryReviewInformationWaiting'
        );
      //2. Send Email to Joint with resume link
      CustomerEmailService.getInstance()
        .reviewInformationSubmitted(jointApplicants, 'JointStartApplication');
    }
    log?.info('Completed primaryConsumerFlow');
    return application;
  }

  /**
   * @description joint Review Submit action , submit for kyv
   * @author Digital Align Team | 11-24-2021
   * @param account application
   * @return virtual
   **/
  global virtual account jointConsumerFlow(account application) {
    log?.info('Inside jointConsumerFlow');
    Applicant__c primaryApplicant;
    Applicant__c currentJointApplicant;
    List<Applicant__c> jointApplicants = new List<Applicant__c>();

    if (application.Applicants__r.isEmpty()) {
      throw new customException('Applicant Not Found');
    }

    //Mark currrent Joint applicant has submitted the application
    currentJointApplicant = (new Map<Id, Applicant__c>(
        application.Applicants__r
      ))
      .get(ApexRequest.getApplicantId());
    currentJointApplicant.Status__c = ApplicationConstant.SUBMITTED;
    ApplicantRepository.upsertRecord(currentJointApplicant);

    Boolean isFlowCompleted = true;
    for (Applicant__c applicant : application.Applicants__r) {
      Set<String> applicantTypes = new Set<String>(
        applicant.ApplicantType__c.split(';')
      );
      if (applicantTypes.contains('Primary')) {
        primaryApplicant = applicant;
      } else if (applicantTypes.contains('Joint')) {
        jointApplicants.add(applicant);
      }

      if (applicant.Status__c != ApplicationConstant.SUBMITTED) {
        isFlowCompleted = false;
      }
    }

    if (isFlowCompleted) {
      // Send All Joint Completed Email to Primary and Application under process
      CustomerEmailService.getInstance()
        .primaryReviewInformationCompleted(primaryApplicant);
      //#RPA #pending
      //Add Application to Review Queue of rpa
    }

    return application;
  }
}
