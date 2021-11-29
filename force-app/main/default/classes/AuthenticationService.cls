/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AuthenticationService extends AbstractService {
  @TestVisible
  private static AuthenticationService serviceInstance;
  private String mintFlowAuthToken;

  public AuthenticationService() {
    super(AuthenticationService.class);
  }
  /**
   * @description Provides a singleton instance of AuthenticationService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static AuthenticationService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (AuthenticationService) getInstance(
        AuthenticationService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description Generate AUth Token for AWS service
   * @author Digital Align Team | 10-29-2021
   * @return String
   **/
  global String getAuthToken() {
    if (String.isNotBlank(mintFlowAuthToken)) {
      return mintFlowAuthToken;
    }
    HttpBuilder.setAPISetting(APINames.AWSAuth);
    HttpBuilder.Response response = (HttpBuilder.Response) AuthenticationProvider.getInstance()
      .generateToken(null);
    if (response.statusCode == 200) {
      return String.valueOf(response.data);
    }
    return null;
  }

  /**
   * @description generate otp via sms or email
   * @author Digital Align Team | 11-05-2021
   * @param Id applicantId
   * @return Object
   **/
  global virtual Object generateOTP(Id applicantId) {
    Flow.initialize(ApexRequest.getApplicationId());
    Applicant__c applicant = ApplicantRepository.readApplicantById(applicantId);

    String otpMode = ApexRequest.getParams('otpMode') != null
      ? (String) ApexRequest.getParams('otpMode')
      : ApplicationConfiguration__c.getInstance().AllowedOtpMode__c;

    List<String> otpModeList = String.isNotBlank(otpMode)
      ? otpMode.split(';')
      : new List<String>();

    applicant.OTPExpireTime__c = Datetime.now()
      .addMinutes(
        (Integer) ApplicationConfiguration__c.getOrgDefaults()
          .OTPExpirationTime__c
      );
    applicant.OtpAttempts__c = 0;

    //SMS
    if (otpModeList.contains('SMS')) {
      applicant.IsPhoneNumberVerified__c = false;
      applicant.SmsOtp__c = String.valueOf(
        Math.round((Math.random() * (9000) + 1000))
      );

      Map<String, Object> params = new Map<String, Object>();
      params.put(
        'messageText',
        System.Label.TwillioOtpFormat.replace('{OTP}', applicant.SmsOtp__c)
      );
      // #pending remove hardcode mobile number [applicant.Phone__c]
      params.put(
        'toPhone',
        HttpBuilder.getApiConstant('Twillio_Country') + '7892981668'
      );
      params.put('applicantId', applicant.Id);
      //NotificationService.getInstance().sendOTPMessage(params);
    }
    //Email
    if (otpModeList.contains('EMAIL')) {
      applicant.IsEmailVerified__c = false;
      applicant.EmailOtp__c = String.valueOf(
        Math.round((Math.random() * (9000) + 1000))
      );
      //CustomerEmailService.getInstance().sendEmailOTP(applicant);
    }

    ApplicantRepository.updateRecord(applicant);
    return true;
  }

  /**
   * @description validate Entered OTP
   * @author Digital Align Team | 11-05-2021
   * @param Map<String Object> params
   * @return virtual
   **/
  global virtual Applicant__c validateOTP(Map<String, Object> params) {
    Applicant__c applicant = ApplicantRepository.readApplicantWithApplication(
      (Id) params.get('applicantId')
    );
    ApplicationConfiguration__c appConfig = ApplicationConfiguration__c.getInstance();
    try {
      String otpMode = ApexRequest.getParams('otpMode') != null
        ? (String) ApexRequest.getParams('otpMode')
        : appConfig.AllowedOtpMode__c;

      List<String> otpModeList = String.isNotBlank(otpMode)
        ? otpMode.split(';')
        : new List<String>();

      if (otpModeList.isEmpty()) {
        throw new customException('Please verify the otp configuration');
      }

      if (applicant.OTPExpireTime__c.getTime() < Datetime.now().getTime()) {
        applicant.OtpAttempts__c += 1;
        throw new customException('OTP has Expired,Generate new OTP');
      }

      if (applicant.OtpAttempts__c < appConfig.OTPMaxAllowedAttempts__c) {
        applicant.OtpAttempts__c += 1;
      } else {
        applicant.OtpAttempts__c += 1;
        throw new customException('Reached Maximum Number Attempt');
      }

      String smsOTP = (String) params.get('sms');
      String emailOTP = (String) params.get('email');

      //SMS
      if (otpModeList.contains('SMS')) {
        if (String.isBlank(smsOTP)) {
          throw new customException('Please enter the SMS OTP');
        }
        if (applicant.SmsOtp__c != smsOTP) {
          throw new customException('Please verify the SMS OTP entered');
        }
        applicant.IsPhoneNumberVerified__c = true;
      }
      //Email
      if (otpModeList.contains('EMAIL')) {
        if (String.isBlank(emailOTP)) {
          throw new customException('Please enter the Email OTP');
        }
        if (applicant.EmailOtp__c != emailOTP) {
          throw new customException('Please verify the Email OTP entered');
        }
        applicant.IsEmailVerified__c = true;
      }

      // Generate Token base on the OTP verified from configuration
      List<String> otpConfiguredModeList = String.isNotBlank(
          appConfig.AllowedOtpMode__c
        )
        ? appConfig.AllowedOtpMode__c.split(';')
        : new List<String>();

      Boolean otpValidated = false;
      if (
        otpConfiguredModeList.contains('SMS') &&
        otpConfiguredModeList.contains('EMAIL')
      ) {
        otpValidated =
          applicant.IsPhoneNumberVerified__c && applicant.IsEmailVerified__c;
        if (otpValidated) {
          applicant.SmsOtp__c = applicant.EmailOtp__c = '';
        }
      } else if (otpConfiguredModeList.contains('SMS')) {
        otpValidated = applicant.IsPhoneNumberVerified__c;
        if (otpValidated) {
          applicant.SmsOtp__c = '';
        }
      } else if (otpConfiguredModeList.contains('EMAIL')) {
        otpValidated = applicant.IsEmailVerified__c;
        if (otpValidated) {
          applicant.EmailOtp__c = '';
        }
      }

      //create a session for primary/joint applicant when token is not present
      if (String.isBlank(ApexRequest.getToken()) && otpValidated) {
        SecurityUtils.createSessionForApplicant(applicant);
        if (ApexRequest.getApplicantType() == 'Primary') {
          applicant.Application__r.SessionToken__c = applicant.SessionToken__c;
          ApplicantRepository.updateRecord(applicant.Application__r);
        }
      }
      applicant = (Applicant__c) SObjectConstructor.getInstance(applicant)
        .removeFields('mflow__Application__r')
        .build();
      ApplicantRepository.updateRecord(applicant);
      applicant.SmsOtp__c = applicant.EmailOtp__c = '';
      return applicant;
    } catch (customException ex) {
      ApplicantRepository.updateRecord(applicant);
      throw ex;
    }
  }
}
