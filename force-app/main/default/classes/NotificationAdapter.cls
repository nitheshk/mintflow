/**
 * Copyright (c) 2021 Digital Align
 * @group Adapter
 * @author Digital Align Team
 * @reference
 * @description Adapters to send notifications using API
 **/
public with sharing class NotificationAdapter {
  /**
   * @description Method to Invoke API for the API calls
   * @author Digital Align Team | 07-22-2021
   * @return Map<String, Object>
   **/
  public static Map<String, Object> InvokeAPI(Map<String, Object> params) {
    Map<String, Object> data = params.clone();
    setAPIConfiguration(data);
    if (data != null) {
      //return (new TwillioProvider().executeRequest(data));
      return null;
    } else
      return null;
  }
  public static void setAPIConfiguration(Map<String, Object> params) {
    switch on ((APINames) params.get('APIMapper')) {
      when TwillioMessaging {
        APIConfigurationService.setAPISettings(APINames.TwillioMessaging);
        APIConfigurationService.apiSetting.EndPoint__c = APIConfigurationService.apiSetting.EndPoint__c.replace(
          '{Twillio_Account}',
          String.valueOf(params.get('Twillio_Account'))
        );
        APIConfigurationService.apiSetting.EndPoint__c = APIConfigurationService.apiSetting.EndPoint__c.replace(
          '{Version}',
          String.valueOf(params.get('Version'))
        );
      }
    }
    System.debug(
      'EndPoint ::' + APIConfigurationService.apiSetting.EndPoint__c
    );
  }
}
