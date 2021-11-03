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
  global virtual object sendOTPMessage(Map<String, Object> params) {
    Flow.initialize(ApexRequest.getApplicationId());
    Flow.setFlow('EligibilityFlow');
    Flow.setSubFlow(APINames.TwillioMessaging.name());
    try {
      //call provider of twillio
      Map<String, Object> data = params.clone();
      Applicant__c applicant = NotificationRepository.fetchApplicantById(
        (string) params.get('ApplicantId')
      );
      String message;
      Integer otp = Math.round((Math.random() * (9000) + 1000));
      data.put('Phone', applicant.Phone__c);
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
      data.put('OTP', otp);
      data.put(
        'CountryCode',
        APIConfigurationService.getAPIConstants('Twillio_Country')
      );
      data.put(
        'FromPhone',
        APIConfigurationService.getAPIConstants('FromPhone')
      );
      System.debug(' New data::' + data);
      if (HttpBuilder.isActiveApiSetting(APINames.TwillioMessaging)) {
        HttpBuilder.setAPISetting(APINames.TwillioMessaging);
        HttpBuilder.replaceEndpoint(
          '{Twillio_Account}',
          APIConfigurationService.getAPIConstants('Twillio_Account')
        );
        HttpBuilder.replaceEndpoint(
          '{Version}',
          APIConfigurationService.getAPIConstants('Version')
        );
        HttpBuilder.Response response = TwillioProvider.getInstance()
          .sendMessageUsingTwillio(data);
        flow.setSubFlowPassed(response.status);
        flow.setFlowPassed('Completed');
        if (
          String.valueof(response.status).equalsIgnorecase('200') ||
          String.valueof(response.status).equalsIgnorecase('201')
        ) {
          applicant.OTP__c = otp;
          applicant.OTPAttempts__c = 0;
          applicant.OTPExpireTime__c = Datetime.now()
            .addMinutes(
              (Integer) ApplicationConfiguration__c.getOrgDefaults()
                .OTPExpirationTime__c
            );
          message = 'Success';
          NotificationRepository.updateRecord(applicant);
        } else {
          message = 'Error';
          throw new CustomException(' API exception occured');
        }
        return message;
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

// /**
//  * Copyright (c) 2021 Digital Align
//  * @group Service
//  * @author Digital Align Team
//  * @reference
//  * @description NotificationService for sending messages
//  **/
// @SuppressWarnings('PMD.AvoidGlobalModifier')
// global virtual with sharing class NotificationService extends AbstractService {
//   @TestVisible
//   private static NotificationService serviceInstance;

//   public NotificationService() {
//     super(NotificationService.class);
//   }

//   /**
//    * @description Provides a singleton instance of NotificationService from which all other class methods can be accessed.
//    * @author Digital Align Team | 07-22-2021
//    * @return Object  singleton
//    **/
//   public static NotificationService getInstance() {
//     if (serviceInstance == null) {
//       serviceInstance = (NotificationService) getInstance(
//         NotificationService.class
//       );
//     }
//     return serviceInstance;
//   }
//   /**
//    * @description Method to send OTP message to phone.
//    * @author Digital Align Team | 07-22-2021
//    * @return String
//    **/
//   global virtual String sendOTPMessage(Map<String, Object> params) {
//     //call provider of twillio
//     Map<String, Object> data = params.clone();
//     Applicant__c applicant = NotificationRepository.fetchApplicantById(
//       (string) params.get('ApplicantId')
//     );
//     //getRecord
//     String message;
//     Integer otp = Math.round((Math.random() * (9000) + 1000));
//     data.put('Phone', applicant.Phone__c);
//     data.put('APIMapper', APINames.TwillioMessaging);
//     data.put('Version', APIConfigurationService.getAPIConstants('Version'));
//     data.put(
//       'Twillio_Account',
//       APIConfigurationService.getAPIConstants('Twillio_Account')
//     );
//     data.put(
//       'Twillio_Token',
//       APIConfigurationService.getAPIConstants('Twillio_Token')
//     );
//     data.put('OTP', otp);
//     data.put(
//       'CountryCode',
//       APIConfigurationService.getAPIConstants('Twillio_Country')
//     );
//     data.put('FromPhone', APIConfigurationService.getAPIConstants('FromPhone'));
//     System.debug(' New data::' + data);
//     Map<String, Object> response = NotificationAdapter.InvokeAPI(data);
//     //Map<String, Object> response = new Map<String, Object>{ 'Status' => '200' };
//     if (
//       String.valueof(response.get('Status')).equalsIgnorecase('200') ||
//       String.valueof(response.get('Status')).equalsIgnorecase('201')
//     ) {
//       applicant.OTP__c = otp;
//       applicant.OTPAttempts__c = 0;
//       applicant.OTPExpireTime__c = Datetime.now().addMinutes(2);
//       message = 'Success';
//       NotificationRepository.updateRecord(applicant);
//     } else {
//       message = 'Error';
//       throw new CustomException(' API exception occured');
//     }
//     return message;
//   }
//   /**
//    * @description
//    * @author Digital Align | 11-01-2021
//    * @param Map<String Object> params
//    * @return virtual
//    **/
//   global virtual String verifyOTPMessage(Map<String, Object> params) {
//     Applicant__c applicant = NotificationRepository.fetchApplicantById(
//       (string) params.get('ApplicantId')
//     );
//     String message;
//     if (
//       applicant.OTP__c == (Integer) params.get('OTP') &&
//       applicant.OTPExpireTime__c > Datetime.now()
//     ) {
//       applicant.IsPhoneNumberVerified__c = true;
//       NotificationRepository.updateRecord(applicant);
//       message = 'Verified';
//     } else {
//       message = 'Invalid OTP';
//     }
//     return message;
//   }
// }

