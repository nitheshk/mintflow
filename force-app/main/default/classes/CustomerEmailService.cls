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
      serviceInstance = (CustomerEmailService) getInstance(CustomerEmailService.class);
    }
    return serviceInstance;
  }

  /**
   * @description Dispatch email notification to OTP to Applicant
   * @author Digital Align | 11-05-2021
   * @param Applicant__c applicant
   **/
  global virtual void sendEmailOTP(Applicant__c applicant) {
    String expireTime = String.valueOf((Integer) ApplicationConfiguration__c.getOrgDefaults().OTPExpirationTime__c);
    //applicant.OTPExpireTime__c.format('MM/dd/yyyy HH:mm:ss')
    // #pending remove SMS OTP From Email
    EmailNotificationBuilder.newInstance('OTPVerificationEmail', applicant.Id)
      .setToAddresses(applicant.Email__c)
      /* .setSubstitute(
        new Map<String, String>{
          '{OTP}' => applicant.SmsOtp__c +
          ' ' +
          applicant.EmailOtp__c,
          '{ExpireTime}' => expireTime
        }
      );
      */
      .setSubstitute(new Map<String, String>{ '{OTP}' => applicant.EmailOtp__c, '{ExpireTime}' => expireTime });
    sendEmail();
  }

  /**
   * @description send otp for online portal login
   * @author Digital Align Team | 06-07-2022
   * @param Applicant__c applicant
   * @param SessionManagement__c session
   **/
  global virtual void onlinePortalLoginEmailOtp(Applicant__c applicant, SessionManagement__c session) {
    String expireTime = String.valueOf((Integer) ApplicationConfiguration__c.getOrgDefaults().OTPExpirationTime__c);
    EmailNotificationBuilder.newInstance('OTPVerificationEmail', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(new Map<String, String>{ '{OTP}' => session.EmailOtp__c, '{ExpireTime}' => expireTime });
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
      Set<String> applicantTypes = new Set<String>(applicant.ApplicantType__c.split(';'));
      if (applicantTypes.contains('Primary')) {
        primaryApplicant = applicant;
      } else if (applicantTypes.contains('Family Member')) {
        familyMembers.add(applicant);
      }
    }

    if (familyMembers.isEmpty()) {
      return;
    }
    for (Applicant__c applicant : familyMembers) {
      EmailNotificationBuilder.newInstance('NotificationToFamilyMember', applicant.Id)
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
   * @description Suggest primary applicant to remove joint applicant
   * @author Digital Align Team | 11-10-2021
   * @param List<Applicant__c> applicants
   **/
  global virtual void removeJointApplicant(List<Applicant__c> applicants) {
    Applicant__c primaryApplicant;
    string jointApplicantNames = '';

    for (Applicant__c applicant : applicants) {
      Set<String> applicantTypes = new Set<String>(applicant.ApplicantType__c.split(';'));
      if (applicantTypes.contains('Primary')) {
        primaryApplicant = applicant;
      } else if (applicantTypes.contains('Joint')) {
        jointApplicantNames = jointApplicantNames + applicant.FirstName__c + ' ' + applicant.LastName__c + ', ';
      }
    }

    EmailNotificationBuilder.newInstance('removeJoint', primaryApplicant.Id)
      .setToAddresses(primaryApplicant.Email__c)
      .setSubstitute(new Map<String, String>{ '{jointApplicantNames}' => jointApplicantNames });
    sendEmail();
  }

  /**
   * @description
   * ResumeApplicationEmail -> resume application email to primary applicant
   * @author Digital Align | 11-12-2021
   * @param Applicant__c applicant
   **/
  global virtual void resumeApplication(Applicant__c applicant) {
    Map<String, String> params = new Map<String, String>();
    if (applicant.ApplicantType__c == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
      params.put('flw', 'ApplicationFlow');
      params.put('urlSuffix', '/other/resume/otp');
      params.put('aplType', ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE);
    } else {
      params.put('flw', 'JointFlow');
      params.put('urlSuffix', '/other/resume/otp');
      params.put('aplType', ApplicationConstant.APPLICANT_JOINT_RECORDTYPE);
    }
    params.put('aplId', applicant.Id);
    params.put('ch', 'Virtual');
    EmailNotificationBuilder.newInstance('ResumeApplicationEmail', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(new Map<String, String>{ '{url}' => generateUrl(params) });
    sendEmail();
  }

  /**
   * @description Saved application email to Primary/Joint applicant
   * @author Digital Align | 11-12-2021
   * @param Applicant__c applicant
   **/
  global virtual void savedApplication(Applicant__c applicant) {
    Map<String, String> params = new Map<String, String>();
    if (ApexRequest.getFlowType() == ApplicationConstant.FLOW_TYPE_APPLICATION) {
      params.put('urlSuffix', '/other/resume/otp');
    } else if (ApexRequest.getFlowType() == ApplicationConstant.FLOW_TYPE_FUNDING) {
      params.put('urlSuffix', '/savings/funding/welcome');
    } else {
      params.put('urlSuffix', '/other/resume/otp');
    }

    params.put('flw', ApexRequest.getFlowType());
    params.put('aplType', ApexRequest.getApplicantType());
    params.put('aplId', applicant.Id);
    params.put('ch', 'Virtual');
    EmailNotificationBuilder.newInstance('SavedApplication', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(new Map<String, String>{ '{url}' => generateUrl(params) });
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
  global virtual void reviewInformationSubmitted(List<Applicant__c> applicants, String notificationName) {
    for (Applicant__c applicant : applicants) {
      String link;
      switch on notificationName {
        when 'PrimaryReviewInformationSubmitted', 'PrimaryReviewInformationWaiting' {
          link = generateUrl(
            new Map<String, String>{
              'aplType' => 'Primary',
              'flw' => 'ApplicationFlow',
              'urlSuffix' => '/other/resume/otp',
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
              'urlSuffix' => '/savings/joint-app/welcome',
              'aplId' => applicant.Id,
              'ch' => 'Virtual'
            }
          );
        }
      }

      EmailNotificationBuilder.newInstance(notificationName, applicant.Id)
        .setToAddresses(applicant.Email__c)
        .setSubstitute(new Map<String, String>{ '{url}' => link });
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
  global virtual void primaryReviewInformationCompleted(Applicant__c applicant) {
    EmailNotificationBuilder.newInstance('PrimaryReviewInformationCompleted', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(new Map<String, String>{ '{url}' => SiteSetting__c.getInstance().OnlineSiteUrl__c });
    sendEmail();
  }

  /**
   * @description Notify Primary applicant that account is opened
   * @author Digital Align Team | 03-15-2022
   * @param Application__c application
   **/
  global virtual void accountOpened(Application__c application) {
    EmailNotificationBuilder builder = EmailNotificationBuilder.newInstance('AccountOpened', application.Id);
    for (Applicant__c applicant : application.Applicants__r) {
      if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        builder.setToAddresses(applicant.Email__c);
      } else if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_JOINT_RECORDTYPE) {
        builder.setCcAddresses(applicant.Email__c);
      }
    }
    String accountDetails = '<br/>';
    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      accountDetails +=
        '<b>Account Name : ' +
        financialAccount.ProductName__c +
        ' [ ' +
        financialAccount.AccountNumber__c +
        ' ] </b><br/>';
    }
    builder.setSubstitute(new Map<String, String>{ '{AccountDetail}' => accountDetails });
    sendEmail();
  }

  /**
   * @description Notify support team about incorrect employment information of an applicant
   * @author Digital Align | 12-15-2021
   * @param Applicant__c applicant
   * @param string information
   * @return virtual
   **/
  global virtual void notifyAboutEmploymentReport(Applicant__c applicant, String information) {
    EmailNotificationBuilder.newInstance('employmentReportInformation', applicant.Id)
      .setToAddresses((String) ApplicationConfiguration__c.getOrgDefaults().SupportTeamEmail__c)
      .setSubstitute(
        new Map<String, String>{
          '{ApplicationNumber}' => ApexRequest.getApplicationName(),
          '{ApplicantName}' => applicant.ApplicantName__c,
          '{Information}' => information
        }
      );
    sendEmail();
  }

  /**
   * @description Send Url to applicat to upload identity document from mobile device
   * @author Digital Align Team | 02-08-2022
   * @param Applicant__c applicant
   **/
  global virtual void uploadIdentityDocument(Applicant__c applicant, String link) {
    EmailNotificationBuilder.newInstance('IdentityUploadDocument', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(new Map<String, String>{ '{url}' => link });
    sendEmail();
  }

  /**
   * @description Send Url to applicat to update funding detail
   * @author Digital Align Team | 04-27-2022
   * @param Applicant__c applicant
   **/
  global virtual void notifyToUpdateFunding(Applicant__c applicant, String link) {
    EmailNotificationBuilder.newInstance('FundingLink', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(new Map<String, String>{ '{url}' => link });
    sendEmail();
  }

  /**
   * @description Send Url to applicat to complete account opening for interested products
   * @author Digital Align Team | 02-08-2022
   * @param Applicant__c applicant
   * @param List<Object> interestedProductList
   **/
  global virtual void notifyProductInterest(Applicant__c applicant, List<Object> interestedProductList) {
    String productDetails = '<br/>';
    for (Object interestedProduct : interestedProductList) {
      Map<String, Object> interestedProductParams = (Map<String, Object>) interestedProduct;

      String link =
        SiteSetting__c.getInstance().OnlineSiteUrl__c +
        '/OpenAccount?cvmf=' +
        interestedProductParams.get('cvmf') +
        '&vue=' +
        EncodingUtil.urlEncode((String) interestedProductParams.get('urlSuffix'), 'UTF-8');
      if (interestedProductParams.containsKey('Certificates')) {
        productDetails +=
          '<b><br/>' +
          interestedProductParams.get('Certificates') +
          '</i><br/><a href="' +
          link +
          '" target="_blank">' +
          interestedProductParams.get('displayName') +
          '</a></b></i><br/><br/>';
      } else {
        productDetails +=
          '</i><b><a href="' +
          link +
          '" target="_blank">' +
          interestedProductParams.get('displayName') +
          '</a></b></i><br/><br/>';
      }
    }
    EmailNotificationBuilder.newInstance('StartSecondaryApplication', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(new Map<string, String>{ '{productDetails}' => productDetails });
    sendEmail();
  }

  /**
   * @description Send Email to upload document
   * @author Digital Align Team | 05-30-2022
   * @param Applicant__c applicant
   **/
  global virtual void documentRequestInitiated(Applicant__c applicant, DocumentRequest__c documentRequest) {
    EmailNotificationBuilder.newInstance('DocumentRequestInitiated', applicant.Id)
      .setToAddresses(applicant.Email__c)
      .setSubstitute(new Map<String, String>{ '{url}' => SiteSetting__c.getInstance().OnlineSiteUrl__c });
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
        NotificationBuilder.chatterMessagePost(ApexRequest.getApplicationId(), 'Email Trigger Failure ' + results);
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
      .addHours((Integer) ApplicationConfiguration__c.getInstance().EmailLinkExpirationTime__c);
    cipher.ch = params.get('ch');
    String pageName = params.containsKey('pageName') ? params.get('pageName') : '/OpenAccount';
    String link =
      SiteSetting__c.getInstance().OnlineSiteUrl__c +
      pageName +
      '?vmf=' +
      SecurityUtils.encryptUrl(JSON.serialize(cipher, true));

    if (params.get('suffixType') == 'path') {
      link += '#' + urlSuffix;
    } else {
      link += '&vue=' + EncodingUtil.urlEncode(urlSuffix, 'UTF-8');
    }
    return link;
  }
}
