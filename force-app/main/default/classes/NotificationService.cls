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
    String applicantNumber = (String) params.get('applicantNumber');
    Flow.setSubFlow(APINames.TwillioMessaging.name(), applicantNumber);
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
        throw new CustomException('Requested API is disabled');
      }
    } catch (Exception ex) {
      flow.setSubFlowFailed(ex.getMessage());
      flow.setFlowFailed('Failed');
      throw ex;
    }
  }
}
