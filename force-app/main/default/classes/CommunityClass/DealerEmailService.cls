/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class DealerEmailService extends AbstractService {
  @TestVisible
  private static DealerEmailService serviceInstance;

  public DealerEmailService() {
    super(DealerEmailService.class);
  }

  /**
   * @description Provides a singleton instance of DealerEmailService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-12-2021
   * @return Object  singleton
   **/
  public static DealerEmailService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (DealerEmailService) getInstance(
        DealerEmailService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align Team | 08-05-2021
   * @param Lead leadRecord
   * @return virtual
   **/
  global virtual void sendDealerRegisterInvitation(Lead leadRecord) {
    String inviteUrl =
      ApplicationConfiguration__c.getOrgDefaults().SiteUrl__c +
      '/s/DealerRegistration?id=' +
      SecurityUtils.encryptUrl(leadRecord.id);
    EmailNotificationBuilder.newInstance('DealerInvitation', leadRecord.Id)
      .setToAddresses(leadRecord.Email)
      .setSubstitute(new Map<String, String>{ '{{url}}' => inviteUrl })
      .setdocumentNames(
        new List<String>{
          'DaBackGround1',
          'DAContent1',
          'AltifiLogo',
          'facebook',
          'twitter',
          'youtube',
          'skype'
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

  /**
   * @description
   * @author Digital Align Team | 08-05-2021
   * @param Lead leadRecord
   * @return virtual
   **/
  global virtual void sendLeadRejectionEmail(Lead leadRecord) {
    EmailNotificationBuilder.newInstance('DealerRejection', leadRecord.Id)
      .setToAddresses(leadRecord.Email)
      .setdocumentNames(
        new List<String>{
          'DaBackGround1',
          'DAContent1',
          'AltifiLogo',
          'facebook',
          'twitter',
          'youtube',
          'skype'
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
