/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description NotificationService for sending messages
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class NotificationService extends AbstractService {
  @TestVisible
  private static NotificationService serviceInstance;

  public NotificationService() {
    super(NotificationService.class);
  }

  /**
   * @description Provides a singleton instance of NotificationService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-22-2021
   * @return Object  singleton
   **/
  public static NotificationService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (NotificationService) getInstance(
        NotificationService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description  Method to send OTP message to phone.
   * @author Digital Align Team | 11-03-2021
   * @param Map<String Object> params
   * @return virtual
   **/
  global virtual object sendOTPMessage(Map<String, Object> params) {
    Flow.setFlow('EligibilityFlow');
    String applicantId = (String) params.get('applicantId');
    Flow.setSubFlow(APINames.TwillioMessaging.name(), applicantId);
    try {
      if (HttpBuilder.isActiveApiSetting(APINames.TwillioMessaging)) {
        HttpBuilder.setAPISetting(APINames.TwillioMessaging);
        HttpBuilder.replaceEndpoint(
          '{Twillio_Account}',
          HttpBuilder.getApiConstant('Twillio_Account')
        );
        HttpBuilder.replaceEndpoint(
          '{Version}',
          HttpBuilder.getApiConstant('Version')
        );
        log?.debug('Endpoint :' + HttpBuilder.getAPISetting());
        HttpBuilder.Response response = TwillioProvider.getInstance()
          .sendMessageUsingTwillio(params);
        flow.setSubFlowPassed(response.status);
        flow.setFlowPassed('Completed');
        return true;
      } else {
        throw new CustomException(System.Label.Api_RequestedApiIsDisabled);
      }
    } catch (Exception ex) {
      flow.setSubFlowFailed(ex.getMessage());
      flow.setFlowFailed('Failed');
      throw ex;
    }
  }

  /**
   * @description dispatch kyc notification
   * @author Digital Align Team | 01-18-2022
   * @param String eventName
   * @param Id entityId
   * @param String title
   * @param String message
   **/
  global virtual void dispatchKycNotification(
    String eventName,
    Id entityId,
    String title,
    String message
  ) {
    switch on eventName {
      when 'onExceptionKycReviewSubmit' {
        String chatterPost =
          'Excpetion on Submit To RPA Review Queue For Kyc Verification \n Error Occured : ' +
          message;
        NotificationBuilder.chatterMessagePost(entityId, chatterPost);

        // Notification
        NotificationBuilder.bellNotification(
          entityId,
          title,
          'Exception on Submit Review Queue :' + title,
          NotificationBuilder.getRegularGroupId('OnKycReview')
        );
      }
      when 'onSuccessKycReviewSubmit' {
        String chatterPost = 'Application Submitted for RPA review Queue';
        NotificationBuilder.chatterMessagePost(entityId, chatterPost);
        // Notification
        NotificationBuilder.bellNotification(
          entityId,
          title,
          'Application Submitted for Review Queue :' + title,
          NotificationBuilder.getRegularGroupId('OnKycSuccess')
        );
      }
      when 'onExceptionKycProcess' {
        String chatterPost = 'Exception on Process Kyc Result : ' + message;
        NotificationBuilder.chatterMessagePost(entityId, chatterPost);
        // Notification
        NotificationBuilder.bellNotification(
          entityId,
          title,
          'Exception On :' + title,
          NotificationBuilder.getRegularGroupId('OnKycReview')
        );
      }
      when 'onReviewKycProcess' {
        String chatterPost = 'Application Added to Review Process';
        NotificationBuilder.chatterMessagePost(entityId, chatterPost);
        // Notification
        NotificationBuilder.bellNotification(
          entityId,
          title,
          'Application Added to Review Process : ' + title,
          NotificationBuilder.getRegularGroupId('OnKycReview')
        );
      }
      when 'onSuccessKycProcess' {
        String chatterPost = 'Kyc Process Successfully for ' + title;
        NotificationBuilder.chatterMessagePost(entityId, chatterPost);
        // Notification
        NotificationBuilder.bellNotification(
          entityId,
          title,
          chatterPost,
          NotificationBuilder.getRegularGroupId('OnKycSuccess')
        );
      }
      when 'onManualKycAction' {
        NotificationBuilder.chatterMessagePost(entityId, message);
      }
    }
  }
}
