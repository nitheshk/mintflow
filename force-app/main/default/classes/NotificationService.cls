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
   * @description Method to send OTP message to phone.
   * @author Digital Align Team | 07-22-2021
   * @return String
   **/
  global virtual String sendOTPMessage(Map<String, Object> params) {
    //call provider of twillio
    Map<String, Object> data = params.clone();
    System.debug(' Old data::' + data);
    String message;
    data.put('APIMapper', APINames.TwillioMessaging);
    data.put('Version', APIConfigurationService.getAPIConstants('Version'));
    data.put(
      'Twillio_Account',
      APIConfigurationService.getAPIConstants('Twillio_Account')
    );
    data.put(
      'Twillio_Token',
      APIConfigurationService.getAPIConstants('Twillio_Token')
    );
    data.put('OTP', Math.round((Math.random() * (9000) + 1000)));
    data.put(
      'CountryCode',
      APIConfigurationService.getAPIConstants('Twillio_Country')
    );
    data.put('FromPhone', APIConfigurationService.getAPIConstants('FromPhone'));
    System.debug(' New data::' + data);
    Map<String, Object> response = NotificationAdapter.InvokeAPI(data);

    if (
      String.valueof(response.get('Status')).equalsIgnorecase('200') ||
      String.valueof(response.get('Status')).equalsIgnorecase('201')
    ) {
      message = 'Success';
    } else {
      message = 'Error';
      throw new CustomException(' API exception occured');
    }
    return message;
  }
}
