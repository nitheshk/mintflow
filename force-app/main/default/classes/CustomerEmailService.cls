/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
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
   * @description
   * @author Digital Align | 11-05-2021
   * @param Applicant__c applicant
   * @return virtual
   **/
  global virtual void sendEmailOTP(Applicant__c applicant) {
    string otp = string.valueOf(applicant.EmailOtp__c);
    string expireTime = string.valueOf(
      ApplicationConfiguration__c.getOrgDefaults().OTPExpirationTime__c
    );
    EmailNotificationBuilder.newInstance('OTPVerificationEmail', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(
        new Map<String, String>{
          '{{FirstName}}' => applicant.FirstName__c,
          ' {{LastName}}' => applicant.LastName__c,
          '{{otp}}' => otp,
          '{{expireTime}}' => expireTime
        }
      );
    List<Messaging.SendEmailResult> result = EmailNotificationBuilder.sendEmail();
    if (result != null) {
      if (result[0].success) {
        System.debug('Email sent Successfully');
      } else {
        System.debug('Failed to send Email ');
        throw new customException('email not sent');
      }
    }
  }
}
