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
   * @description create session token for application
   * @author Digital Align Team | 11-15-2021
   * @param Account application
   * @return Account
   **/
  global static Account createSessionForApplication(Account application) {
    Map<String, Object> mf = new Map<String, Object>{
      'appId' => application.Id,
      'edt' => Datetime.now()
        .addMinutes(
          (Integer) ApplicationConfiguration__c.getOrgDefaults()
            .SesssionExpirationTime__c
        )
    };
    application.SessionToken__c = SecurityUtils.encryptBase64(
      Json.serialize(mf)
    );
    ApexRequest.getRequest().token = application.SessionToken__c;
    return application;
  }

  /**
   * @description create a session for applicant
   * @author Digital Align Team | 11-16-2021
   * @param Applicant__c applicant
   * @return Applicant__c
   **/
  global static Applicant__c createSessionForApplicant(Applicant__c applicant) {
    Map<String, Object> mf = new Map<String, Object>{
      'aplId' => applicant.Id,
      'edt' => Datetime.now()
        .addMinutes(
          (Integer) ApplicationConfiguration__c.getOrgDefaults()
            .SesssionExpirationTime__c
        )
    };
    applicant.SessionToken__c = SecurityUtils.encryptBase64(Json.serialize(mf));
    ApexRequest.getRequest().token = applicant.SessionToken__c;
    return applicant;
  }

  /**
   * @description extract data from token
   * @author Digital Align Team | 11-15-2021
   * @param String encryptedToken
   * @return Map<String, Object>
   **/
  global static Map<String, Object> extractToken(String encryptedToken) {
    return (Map<String, Object>) JSON.deserializeUntyped(
      SecurityUtils.decryptBase64(encryptedToken)
    );
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

    String otpMode = ApplicationConfiguration__c.getInstance()
      .AllowedOtpMode__c;
    List<String> otpModeList = String.isNotBlank(otpMode)
      ? otpMode.split(';')
      : new List<String>();

    applicant.OTPExpireTime__c = Datetime.now()
      .addMinutes(
        (Integer) ApplicationConfiguration__c.getOrgDefaults()
          .OTPExpirationTime__c
      );
    //SMS
    if (otpModeList.contains('SMS')) {
      applicant.SmsOtp__c = String.valueOf(
        Math.round((Math.random() * (9000) + 1000))
      );
      applicant.SmsOtpAttempts__c = 0;

      Map<String, Object> params = new Map<String, Object>();
      params.put(
        'messageText',
        System.Label.TwillioOtpFormat.replace('{OTP}', applicant.SmsOtp__c)
      );
      params.put(
        'toPhone',
        HttpBuilder.getApiConstant('Twillio_Country') + applicant.Phone__c
      );
      params.put('applicantNumber', applicant.Id);
      NotificationService.getInstance().sendOTPMessage(params);
    }
    //Email
    if (otpModeList.contains('EMAIL')) {
      applicant.EmailOtp__c = String.valueOf(
        Math.round((Math.random() * (9000) + 1000))
      );
      applicant.EmailOtpAttempts__c = 0;
      CustomerEmailService.getInstance().sendEmailOTP(applicant);
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
    Applicant__c applicant = ApplicantRepository.readApplicantById(
      (Id) params.get('applicantId')
    );
    ApplicationConfiguration__c appConfig = ApplicationConfiguration__c.getInstance();
    try {
      List<String> otpModeList = String.isNotBlank(appConfig.AllowedOtpMode__c)
        ? appConfig.AllowedOtpMode__c.split(';')
        : new List<String>();

      if (applicant.OTPExpireTime__c < Datetime.now()) {
        applicant.EmailOtpAttempts__c = applicant.SmsOtpAttempts__c += 1;
        throw new customException('OTP has Expired,Generate new OTP');
      }

      if (
        applicant.SmsOtpAttempts__c < appConfig.OTPMaxAllowedAttempts__c &&
        applicant.EmailOtpAttempts__c < appConfig.OTPMaxAllowedAttempts__c
      ) {
        applicant.EmailOtpAttempts__c = applicant.SmsOtpAttempts__c += 1;
      } else {
        applicant.EmailOtpAttempts__c = applicant.SmsOtpAttempts__c += 1;
        throw new customException('Reached Maximum Number Attempt');
      }

      //SMS
      if (otpModeList.contains('SMS')) {
        if (applicant.SmsOtp__c != params.get('sms')) {
          throw new customException('Please verify the OTP entered');
        }
      }
      //Email
      if (otpModeList.contains('EMAIL')) {
        if (applicant.EmailOtp__c != params.get('email')) {
          throw new customException('Please verify the OTP entered');
        }
      }

      applicant.SmsOtp__c = applicant.EmailOtp__c = '';
      applicant.IsPhoneNumberVerified__c = true;

      //create a session for joint applicant
      if (
        applicant.RecordType.Name !=
        ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
      ) {
        createSessionForApplicant(applicant);
      }
      ApplicantRepository.updateRecord(applicant);
      return applicant;
    } catch (customException ex) {
      ApplicantRepository.updateRecord(applicant);
      throw ex;
    }
  }
}
