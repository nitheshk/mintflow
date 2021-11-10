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

    for (Applicant__c applicant : applicants) {
      Set<String> applicantTypes = new Set<String>(
        applicant.ApplicantType__c.split(';')
      );
      if (applicantTypes.contains('Primary')) {
        primaryApplicant = applicant;
      }
    }

    for (Applicant__c applicant : applicants) {
      Set<String> applicantTypes = new Set<String>(
        applicant.ApplicantType__c.split(';')
      );
      if (applicantTypes.contains('Family Member')) {
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
              '{applicationNumber}' => 'APP-001'
            }
          );
      }
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
