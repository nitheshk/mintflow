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
    String expireTime = String.valueOf(
      (Integer) ApplicationConfiguration__c.getOrgDefaults()
        .OTPExpirationTime__c
    );
    //applicant.OTPExpireTime__c.format('MM/dd/yyyy HH:mm:ss')
    // #pending remove SMS OTP From Email
    EmailNotificationBuilder.newInstance('OTPVerificationEmail', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(
        new Map<String, String>{
          '{FirstName}' => applicant.FirstName__c,
          '{LastName}' => applicant.LastName__c,
          '{OTP}' => applicant.SmsOtp__c +
          ' ' +
          applicant.EmailOtp__c,
          '{ExpireTime}' => expireTime
        }
      );
    sendEmail();
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
    sendEmail();
  }

  /**
   * @description
   * KycPassedResumeApp -> KYC passed notification with resume application link for primary applicant
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
    sendEmail();
  }

  /**
   * @description
   * ResumeApplicationEmail -> resume application email to primary applicant
   * @author Digital Align | 11-12-2021
   * @param Applicant__c applicant
   * @return virtual
   **/
  global virtual void resumeApplication(Applicant__c applicant) {
    String portalUrl = 'portalUrl';
    Map<String, String> params = new Map<String, String>();
    if (
      applicant.ApplicantType__c ==
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
    ) {
      params.put('flw', 'ApplicationFlow');
      params.put(
        'urlSuffix',
        '/membership/application/' + applicant.FlowState__c
      );
    } else {
      params.put('flw', 'JointFlow');
      params.put('urlSuffix', '/membership/joints/' + applicant.FlowState__c);
    }
    params.put('aplType', applicant.ApplicantType__c);
    params.put('aplId', applicant.Id);
    params.put('ch', 'Virtual');
    String link = generateUrl(params);
    EmailNotificationBuilder.newInstance('ResumeApplicationEmail', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(
        new Map<String, String>{
          '{firstName}' => applicant.FirstName__c,
          '{lastName}' => applicant.LastName__c,
          '{url}' => link
        }
      );
    sendEmail();
  }

  /* @description send review submit email to applicants
   * PrimaryReviewInformationSubmitted -> Application submitted email to primary applicant.
   * PrimaryReviewInformationWaiting -> Application submitted email to primary applicant and
   * notify waiting for joint applicant  application submission
   * JointStartApplication -> To complete application for joint applicants
   * @author Digital Align Team | 11-12-2021
   * @param List<Applicant__c> applicants
   * @param String eventName
   **/
  global virtual void reviewInformationSubmitted(
    List<Applicant__c> applicants,
    String notificationName
  ) {
    for (Applicant__c applicant : applicants) {
      String link;
      switch on notificationName {
        when 'PrimaryReviewInformationSubmitted',
          'PrimaryReviewInformationWaiting' {
          link = generateUrl(
            new Map<String, String>{
              'aplType' => 'Primary',
              'flw' => 'ApplicationFlow',
              'urlSuffix' => '/membership/application/get-started',
              'aplId' => applicant.Id,
              'ch' => 'Virtual'
            }
          );
        }
        when 'JointStartApplication' {
          link = generateUrl(
            new Map<String, String>{
              'aplType' => 'Joint',
              'flw' => 'JointFlow',
              'urlSuffix' => '/membership/joints/welcome',
              'aplId' => applicant.Id,
              'ch' => 'Virtual'
            }
          );
        }
      }

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
    sendEmail();
  }

  /**
   * @description
   * PrimaryReviewInformationCompleted -> Application Completed email to primary applicant.
   * Notify Primary applicant that joint applicant completed application.
   * @author Digital Align | 11-12-2021
   * @param Applicant__c applicant
   * @return virtual
   **/
  global virtual void primaryReviewInformationCompleted(
    Applicant__c applicant
  ) {
    EmailNotificationBuilder.newInstance(
        'PrimaryReviewInformationCompleted',
        applicant.Id
      )
      .setToAddresses(applicant.Email__c)
      .setSubstitute(
        new Map<String, String>{
          '{FirstName}' => applicant.FirstName__c,
          '{LastName}' => applicant.LastName__c,
          '{ApplicationNumber}' => ApexRequest.getApplicationName()
        }
      );
    sendEmail();
  }

  /**
   * @description
   * AccountOpened -> Notify Primary applicant that account is opened
   * @author Digital Align | 11-12-2021
   * @param Applicant__c applicant
   * @return virtual
   **/
  global virtual void accountOpened(
    Applicant__c applicant,
    FinServ__FinancialAccount__c finAcc
  ) {
    EmailNotificationBuilder.newInstance('AccountOpened', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(
        new Map<String, String>{
          '{FirstName}' => applicant.FirstName__c,
          '{LastName}' => applicant.LastName__c,
          '{productName}' => 'Member Account',
          '{accountNumber}' => finAcc.FinServ__FinancialAccountNumber__c,
          '{customerNumber}' => applicant.CustomerNumber__c
        }
      );
    sendEmail();
  }
  /**
   * @description Notify Primary applicant that account is approved
   * @author Digital Align | 12-15-2021
   * @param Applicant__c applicant
   * @return virtual
   **/
  global virtual void fundingLinkOnKycApproval(Account application) {
    for (Applicant__c applicant : application.Applicants__r) {
      if (
        applicant.RecordType.Name ==
        ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
      ) {
        String link = generateUrl(
          new Map<String, String>{
            'aplType' => 'Primary',
            'flw' => 'FundingFlow',
            'urlSuffix' => '/membership/funding/funding',
            'aplId' => applicant.Id,
            'ch' => 'Virtual'
          }
        );
        EmailNotificationBuilder.newInstance(
            'FundingLinkOnKycApproval',
            applicant.Id
          )
          .setToAddresses(applicant.Email__c)
          .setSubstitute(
            new Map<String, String>{
              '{FirstName}' => applicant.FirstName__c,
              '{LastName}' => applicant.LastName__c,
              '{ApplicationNumber}' => ApexRequest.getApplicationName(),
              '{url}' => link
            }
          );
        break;
      }
    }
    sendEmail();
  }
  /**
   * @description Notify support team about incorrect employment information of an applicant
   * @author Digital Align | 12-15-2021
   * @param Applicant__c applicant
   * @param string information
   * @return virtual
   **/
  global virtual void notifyAboutEmploymentReport(
    Applicant__c applicant,
    String information
  ) {
    EmailNotificationBuilder.newInstance(
        'employmentReportInformation',
        applicant.Id
      )
      .setToAddresses(
        (String) ApplicationConfiguration__c.getOrgDefaults()
          .SupportTeamEmail__c
      )
      .setSubstitute(
        new Map<String, String>{
          '{ApplicationNumber}' => ApexRequest.getApplicationName(),
          '{ApplicantName}' => applicant.Name,
          '{Information}' => information
        }
      );
    sendEmail();
  }

  /**
   * @description
   * Method to send email
   * @author Digital Align | 11-12-2021
   * @return virtual
   **/
  global virtual void sendEmail() {
    List<Messaging.SendEmailResult> results = EmailNotificationBuilder.sendEmail();
    Boolean isSuccess = true;
    if (!CollectionUtils.isListEmpty(results)) {
      for (Messaging.SendEmailResult result : results) {
        if (!result.isSuccess()) {
          log?.error(result.getErrors());
          isSuccess = false;
        }
      }
      if (isSuccess) {
        log?.debug('Email sent Successfully');
      } else {
        log?.debug('Failed to send Email ');
        // #pending exception on sending email
        //throw new customException(System.Label.Email_EmailNotSent);
      }
    }
  }
  /**
   * @description generate URL that can be used in email templates
   * @author Digital Align | 12-15-2021
   * @param Map<String string> params
   * @return virtual
   **/
  global virtual String generateUrl(Map<String, String> params) {
    SecurityUtils.CipherDTO cipher = new SecurityUtils.CipherDTO();
    cipher.aplType = params.get('aplType');
    cipher.flw = params.get('flw');
    String urlSuffix = params.get('urlSuffix');
    cipher.appId = ApexRequest.getApplicationId();
    cipher.aplId = params.get('aplId');
    cipher.edt = Datetime.now()
      .addHours(
        (Integer) ApplicationConfiguration__c.getInstance()
          .EmailLinkExpirationTime__c
      );
    cipher.ch = params.get('ch');

    String link =
      SiteSetting__c.getInstance().OnlineSiteUrl__c +
      '/OpenAccount' +
      '?vmf=' +
      SecurityUtils.encryptUrl(JSON.serialize(cipher, true)) +
      '&vue=' +
      EncodingUtil.urlEncode(urlSuffix, 'UTF-8');
    return link;
  }
}
