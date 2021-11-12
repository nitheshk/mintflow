/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Contains email notification related customer
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class CustomerEmailService extends AbstractService {
  @TestVisible
  private static CustomerEmailService serviceInstance;

  public CustomerEmailService() {
    super(CustomerEmailService.class);
  }

  /**
   * @description Provides a singleton instance of CustomerEmailService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-12-2021
   * @return Object  singleton
   **/
  public static CustomerEmailService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (CustomerEmailService) getInstance(
        CustomerEmailService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description Dispatch email notification to OTP to Applicant
   * @author Digital Align | 11-05-2021
   * @param Applicant__c applicant
   **/
  global virtual void sendEmailOTP(Applicant__c applicant) {
    String expireTime = string.valueOf(
      (Integer) ApplicationConfiguration__c.getOrgDefaults()
        .OTPExpirationTime__c
    );
    //applicant.OTPExpireTime__c.format('MM/dd/yyyy HH:mm:ss')
    EmailNotificationBuilder.newInstance('OTPVerificationEmail', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(
        new Map<String, String>{
          '{FirstName}' => applicant.FirstName__c,
          '{LastName}' => applicant.LastName__c,
          '{OTP}' => applicant.EmailOtp__c,
          '{ExpireTime}' => expireTime
        }
      );
    List<Messaging.SendEmailResult> result = EmailNotificationBuilder.sendEmail();
    if (!CollectionUtils.isListEmpty(result)) {
      if (result[0].success) {
        log?.debug('Email sent Successfully');
      } else {
        log?.debug('Failed to send Email ');
        throw new customException('email not sent');
      }
    }
  }

  /**
   * @description Notification to family member on reference
   * @author Digital Align Team | 11-10-2021
   * @param List<Applicant__c> applicants
   **/
  global virtual void notifyFamilyMember(List<Applicant__c> applicants) {
    Applicant__c primaryApplicant;
    List<Applicant__c> familyMembers = new List<Applicant__c>();

    for (Applicant__c applicant : applicants) {
      Set<String> applicantTypes = new Set<String>(
        applicant.ApplicantType__c.split(';')
      );
      if (applicantTypes.contains('Primary')) {
        primaryApplicant = applicant;
      } else if (applicantTypes.contains('Family Member')) {
        familyMembers.add(applicant);
      }
    }

    for (Applicant__c applicant : familyMembers) {
      EmailNotificationBuilder.newInstance(
          'NotificationToFamilyMember',
          applicant.Id
        )
        .setToAddresses(applicant.Email__c)
        .setCcAddresses(primaryApplicant.Email__c)
        .setSubstitute(
          new Map<String, String>{
            '{primaryFirstName}' => primaryApplicant.FirstName__c,
            '{primaryLastName}' => primaryApplicant.LastName__c,
            '{productName}' => 'Membership Account',
            '{applicationNumber}' => ApexRequest.getApplicationName()
          }
        );
    }

    List<Messaging.SendEmailResult> result = EmailNotificationBuilder.sendEmail();
    if (!CollectionUtils.isListEmpty(result)) {
      if (result[0].success) {
        log?.debug('Email sent Successfully');
      } else {
        log?.debug('Failed to send Email ');
        throw new customException('email not sent');
      }
    }
  }

  /**
   * @description
   * @author Digital Align | 11-12-2021
   * @param Applicant__c applicant
   * @return virtual
   **/
  global virtual void resumeAppAfterKycPassed(Applicant__c applicant) {
    String portalUrl = 'portalUrl';

    EmailNotificationBuilder.newInstance('KycPassedResumeApp', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(
        new Map<String, String>{
          '{firstName}' => applicant.FirstName__c,
          '{lastName}' => applicant.LastName__c,
          '{url}' => portalUrl
        }
      );
    List<Messaging.SendEmailResult> result = EmailNotificationBuilder.sendEmail();
    if (!CollectionUtils.isListEmpty(result)) {
      if (result[0].success) {
        log?.debug('Email sent Successfully');
      } else {
        log?.debug('Failed to send Email ');
        throw new customException('email not sent');
      }
    }
  }

  /**
   * @description
   * @author Digital Align | 11-12-2021
   * @param Applicant__c applicant
   * @return virtual
   **/
  global virtual void resumeApplication(Applicant__c applicant) {
    String portalUrl = 'portalUrl';

    EmailNotificationBuilder.newInstance('ResumeApplicationEmail', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(
        new Map<String, String>{
          '{firstName}' => applicant.FirstName__c,
          '{lastName}' => applicant.LastName__c,
          '{url}' => portalUrl
        }
      );
    List<Messaging.SendEmailResult> result = EmailNotificationBuilder.sendEmail();
    if (!CollectionUtils.isListEmpty(result)) {
      if (result[0].success) {
        log?.debug('Email sent Successfully');
      } else {
        log?.debug('Failed to send Email ');
        throw new customException('email not sent');
      }
    }
  }

  /* @description send review submit email to applicants
   * @author Digital Align Team | 11-12-2021
   * @param List<Applicant__c> applicants
   * @param String eventName
   **/
  global virtual void reviewInformationSubmitted(
    List<Applicant__c> applicants,
    String notificationName
  ) {
    for (Applicant__c applicant : applicants) {
      String link = SiteSetting__c.getInstance().OnlineSiteUrl__c;
      String flowType = '';
      if (
        notificationName == 'PrimaryReviewInformationSubmitted' ||
        notificationName == 'PrimaryReviewInformationWaiting'
      ) {
        flowType = 'Primary';
      }
      if (notificationName == 'JointStartApplication') {
        flowType = 'Joint';
      }

      Map<String, String> urlMap = new Map<String, String>{
        'applicantId' => applicant.Id,
        'flowType' => flowType
      };

      link = link + '/mf=' + SecurityUtils.encryptUrl(JSON.serialize(urlMap));

      EmailNotificationBuilder.newInstance(notificationName, applicant.Id)
        .setToAddresses(applicant.Email__c)
        .setSubstitute(
          new Map<String, String>{
            '{FirstName}' => applicant.FirstName__c,
            '{LastName}' => applicant.LastName__c,
            '{ApplicationNumber}' => ApexRequest.getApplicationName(),
            '{url}' => link
          }
        );
    }

    List<Messaging.SendEmailResult> result = EmailNotificationBuilder.sendEmail();
    if (!CollectionUtils.isListEmpty(result)) {
      if (result[0].success) {
        log?.debug('Email sent Successfully');
      } else {
        log?.debug('Failed to send Email ');
        throw new customException('email not sent');
      }
    }
  }
}
