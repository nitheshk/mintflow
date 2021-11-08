/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class IdentityService extends AbstractService {
  @TestVisible
  private static IdentityService serviceInstance;

  public IdentityService() {
    super(IdentityService.class);
  }
  /**
   * @description Provides a singleton instance of IdentityService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static IdentityService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (IdentityService) getInstance(IdentityService.class);
    }
    return serviceInstance;
  }

  /**
   * @description verify county eligibility
   * Pass "zipcode" as parameter
   * @author Digital Align Team | 10-13-2021
   * @param Map<String String> params
   * @return Object
   **/
  global virtual Object verifyCounty(Map<String, Object> params) {
    Flow.initialize(ApexRequest.getApplicationId());
    Flow.setFlow('EligibilityFlow');
    Flow.setSubFlow(APINames.Geocoding.name());
    try {
      string zipcode = (string) params.get('zipcode');
      if (string.isBlank(zipcode) && params != null) {
        throw new CustomException('Zipcode value not set');
      }
      if (HttpBuilder.isActiveApiSetting(APINames.Geocoding)) {
        HttpBuilder.setAPISetting(APINames.Geocoding);
        HttpBuilder.replaceEndpoint(
          '{APIKey}',
          HttpBuilder.getApiConstant('GeocodingAPIKey')
        );
        HttpBuilder.replaceEndpoint(
          '{Pincode}',
          (string) params.get('zipcode')
        );
        HttpBuilder.Response response = GeocodingProvider.getInstance()
          .validateCountyUsingGoogleApi(params);
        flow.setSubFlowPassed(response.status);
        flow.setFlowPassed('Completed');
        return response.data;
      } else {
        throw new CustomException('Requested API is disabled');
      }
    } catch (Exception ex) {
      flow.setSubFlowFailed(ex.getMessage());
      flow.setFlowFailed('Failed');
      throw ex;
    }
  }
  /**
   * @description Document Scan functionality for identity verify
   * @author Digital Align | 10-26-2021
   * @param Map<String object> params
   * @return  Applicant__c
   **/
  global virtual Applicant__c scanIdentityDocument(Map<String, object> params) {
    Flow.initialize(ApexRequest.getApplicationId());
    Flow.setFlow('IdentityFlow');
    Flow.setSubFlow(APINames.IdScanAnalyzer);
    try {
      string contentDocumentId = (string) params.get('contentDocumentId');
      ContentVersion cv = FileService.getInstance()
        .fetchContentVersionByCD(contentDocumentId, false);
      if (cv == null) {
        throw new CustomException('Document Not Found');
      }
      params.put('frontContentVersion', cv);

      if (HttpBuilder.isActiveApiSetting(APINames.IdScanAnalyzer)) {
        HttpBuilder.setAPISetting(APINames.IdScanAnalyzer);
        HttpBuilder.Response response = DocumentScanProvider.getInstance()
          .idScanAnalyzer(params);
        flow.setSubFlowPassed(response.status);
        flow.setFlowPassed('Completed');
        return (Applicant__c) response.data;
      } else {
        throw new CustomException('Requested API is disabled');
      }
    } catch (Exception ex) {
      flow.setSubFlowFailed(ex.getMessage());
      flow.setFlowFailed('Failed');
      throw ex;
    }
  }

  /**
   * @description
   * @author Digital Align Team | 11-01-2021
   * @param Map<String object> params
   * @return virtual
   **/
  global virtual Applicant__c identityVerify(Map<String, object> params) {
    try {
      String applicantId = params.get('applicantId').toString();
      if (String.isBlank('applicantId')) {
        throw new customException('Invalid Applicant Id');
      }
      String apiName = params.get('apiName').toString();
      Applicant__c applicant = IdentityRepository.readApplicantForIdentity(
        (ID) applicantId
      );
      params.put('applicant', applicant);

      HttpBuilder.Response response;
      if (apiName == 'SentiLink') {
        if (HttpBuilder.isActiveApiSetting(APINames.SentiLink)) {
          HttpBuilder.setAPISetting(APINames.SentiLink);
          response = SentiLinkProvider.getInstance().validateSentiLink(params);
          applicant = (Applicant__c) response.data;
        }
      } else if (apiName == 'SentiLinkIdCompletion') {
        if (HttpBuilder.isActiveApiSetting(APINames.SentiLinkIdCompletion)) {
          HttpBuilder.setAPISetting(APINames.SentiLinkIdCompletion);
          response = SentiLinkProvider.getInstance().validateSentiLink(params);
          applicant = (Applicant__c) response.data;
        }
      } else {
        throw new CustomException('Check API Configuration');
      }

      if (response?.statusCode != 200) {
        applicant.SentiLinkStatus__c = 'Under Review';
        applicant.SentiLinkRemarks__c = '';
      }
      IdentityRepository.upsertRecord(Applicant);
      return applicant;
    } catch (Exception ex) {
      throw ex;
    }
  }

  /**
   * @description generate otp via sms or email
   * @author Digital Align Team | 11-05-2021
   * @param Id applicantId
   * @return Object
   **/
  global virtual Object generateOTP(Id applicantId) {
    Flow.initialize(ApexRequest.getApplicationId());
    Applicant__c applicant = IdentityRepository.fetchApplicantById(applicantId);

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

    IdentityRepository.updateRecord(applicant);

    return true;
  }

  /**
   * @description validate Entered OTP
   * @author Digital Align Team | 11-05-2021
   * @param Map<String Object> params
   * @return virtual
   **/
  global virtual Applicant__c validateOTP(Map<String, Object> params) {
    Applicant__c applicant = IdentityRepository.fetchApplicantById(
      (String) params.get('applicantId')
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
      IdentityRepository.updateRecord(applicant);
      return applicant;
    } catch (customException ex) {
      IdentityRepository.updateRecord(applicant);
      throw ex;
    }
  }
}
