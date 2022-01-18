/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier,PMD.CognitiveComplexity')
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
    log?.fine('Inside reviewInformationSubmit');
    Account application = ApplicationRepository.readApplicationWithApplicants(
      applicationId
    );

    String applicantType = ApexRequest.getApplicantType();

    if (applicantType == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
      // send email to primary and joint
      this.primaryConsumerFlow(application);
    } else if (
      applicantType == ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
    ) {
      // send email to primary on completion
      jointConsumerFlow(application);
    }
    log?.fine('Completed reviewInformationSubmit');
    return application;
  }

  /**
   * @description Primary Review Submit action
   * @author Digital Align Team | 11-12-2021
   * @param account application
   * @return account
   **/
  global virtual Account primaryConsumerFlow(Account application) {
    log?.info('Inside primaryConsumerFlow');
    Applicant__c primaryApplicant;
    List<mflow__Applicant__c> jointApplicants = new List<mflow__Applicant__c>();

    if (application.Applicants__r.isEmpty()) {
      throw new CustomException(System.Label.Applicant_ApplicantNotFound);
    }

    for (Applicant__c applicant : application.Applicants__r) {
      if (
        applicant.RecordType.Name ==
        ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
      ) {
        primaryApplicant = applicant;
      } else if (
        applicant.RecordType.Name ==
        ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
      ) {
        jointApplicants.add(applicant);
      }
    }

    //Mark current primary applicant has SUBMITTED_FOR_REVIEW the application
    primaryApplicant.Status__c = ApplicationConstant.SUBMITTED_FOR_REVIEW;
    Boolean isFlowCompleted = true;
    //check all joint application has completed or If no joint present isFlowCompleted will always true
    for (Applicant__c applicant : jointApplicants) {
      if (applicant.Status__c != ApplicationConstant.SUBMITTED_FOR_REVIEW) {
        isFlowCompleted = false;
      }
    }

    if (isFlowCompleted) {
      //Mark Application to submitted for review
      application.FinServ__Status__c = ApplicationConstant.SUBMITTED_FOR_REVIEW;
      //1. Push Primary applicant to RPA Queue
      // Need to move future thr is dml operation before this
      HttpBuilder.Response response = RpaProcessService.getInstance()
        .scheduleReviewApplication(application);
      if (response.statusCode == 400) {
        application.Stage__c = 'Exception';
        NotificationService.getInstance()
          .dispatchKycNotification(
            'onExceptionKycReviewSubmit',
            application.Id,
            application.Name,
            response.status
          );
      } else {
        application.Stage__c = ApplicationConstant.SUBMITTED_FOR_REVIEW;
        NotificationService.getInstance()
          .dispatchKycNotification(
            'onSuccessKycReviewSubmit',
            application.Id,
            application.Name,
            null
          );
      }
      //2. Send notification Primary applicant with resume link
      CustomerEmailService.getInstance()
        .reviewInformationSubmitted(
          new List<mflow__Applicant__c>{ primaryApplicant },
          'PrimaryReviewInformationSubmitted'
        );
    } else {
      //1. send Email to Primary applicant with resume link
      CustomerEmailService.getInstance()
        .reviewInformationSubmitted(
          new List<mflow__Applicant__c>{ primaryApplicant },
          'PrimaryReviewInformationWaiting'
        );
      //2. Send Email to Joint with resume link
      CustomerEmailService.getInstance()
        .reviewInformationSubmitted(jointApplicants, 'JointStartApplication');
    }

    ApplicationRepository.upsertRecords(application.Applicants__r);
    ApplicationRepository.upsertRecord(application);
    log?.info('Completed primaryConsumerFlow');
    return application;
  }

  /**
   * @description joint Review Submit action , submit for kyv
   * @author Digital Align Team | 11-24-2021
   * @param account application
   * @return virtual
   **/
  global virtual Account jointConsumerFlow(Account application) {
    log?.info('Inside jointConsumerFlow');
    Applicant__c primaryApplicant;
    //Applicant__c currentJointApplicant;
    List<Applicant__c> jointApplicants = new List<Applicant__c>();

    if (application.Applicants__r.isEmpty()) {
      throw new CustomException(System.Label.Applicant_ApplicantNotFound);
    }

    for (Applicant__c applicant : application.Applicants__r) {
      if (
        applicant.RecordType.Name ==
        ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
      ) {
        primaryApplicant = applicant;
      } else if (
        applicant.RecordType.Name ==
        ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
      ) {
        jointApplicants.add(applicant);
        // mark current joint applicant as submitted for review
        if (applicant.Id == ApexRequest.getApplicantId()) {
          applicant.Status__c = ApplicationConstant.SUBMITTED_FOR_REVIEW;
        }
      }
    }

    Boolean isFlowCompleted = true;
    if (
      primaryApplicant.Status__c != ApplicationConstant.SUBMITTED_FOR_REVIEW
    ) {
      isFlowCompleted = false;
    }
    //check all joint application has completed or If no joint present isFlowCompleted will always true
    for (Applicant__c applicant : jointApplicants) {
      if (applicant.Status__c != ApplicationConstant.SUBMITTED_FOR_REVIEW) {
        isFlowCompleted = false;
      }
    }

    if (isFlowCompleted) {
      //Mark Application to submitted for review
      application.FinServ__Status__c = ApplicationConstant.SUBMITTED_FOR_REVIEW;
      // Need to move future thr is dml operation before this
      HttpBuilder.Response response = RpaProcessService.getInstance()
        .scheduleReviewApplication(application);
      if (response.statusCode == 400) {
        application.Stage__c = 'Exception';
        NotificationService.getInstance()
          .dispatchKycNotification(
            'onExceptionKycReviewSubmit',
            application.Id,
            application.Name,
            response.status
          );
      } else {
        application.Stage__c = ApplicationConstant.SUBMITTED_FOR_REVIEW;
        NotificationService.getInstance()
          .dispatchKycNotification(
            'onSuccessKycReviewSubmit',
            application.Id,
            application.Name,
            null
          );
      }
      // Send All Joint Completed Email to Primary and Application under process
      CustomerEmailService.getInstance()
        .primaryReviewInformationCompleted(primaryApplicant);
    }

    ApplicationRepository.upsertRecords(application.Applicants__r);
    ApplicationRepository.upsertRecord(application);
    log?.info('Completed jointConsumerFlow');
    return ApplicationService.getInstance()
      .readApplicationWithChild(application.Id, ApexRequest.getApplicantId());
  }
}
