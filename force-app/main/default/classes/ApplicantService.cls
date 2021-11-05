/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicantService extends AbstractService {
  @TestVisible
  private static ApplicantService serviceInstance;

  public ApplicantService() {
    super(ApplicantService.class);
  }

  /**
   * @description Provides a singleton instance of ApplicantService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static ApplicantService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicantService) getInstance(ApplicantService.class);
    }
    return serviceInstance;
  }

  /**
   * @description Read all applicant by applicant records
   * @author Digital Align Team | 10-26-2021
   * @param List<Applicant__c> applicants
   **/
  global virtual List<Applicant__c> readApplicantsWithChild(
    List<Applicant__c> applicants
  ) {
    return readApplicantsWithChild(new Map<Id, SObject>(applicants).keyset());
  }

  /**
   * @description Read all applicant by applicant Ids
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> applicantIds
   **/
  global virtual List<Applicant__c> readApplicantsWithChild(
    Set<Id> applicantIds
  ) {
    return ApplicantRepository.readApplicantsWithChild(applicantIds);
  }

  /**
   * @description Read  applicant by applicant record
   * @author Digital Align Team | 10-26-2021
   * @param Applicant__c applicants
   **/
  global virtual Applicant__c readApplicantWithChild(Applicant__c applicant) {
    return readApplicantWithChild(applicant?.Id);
  }

  /**
   * @description Read applicant by applicant Id
   * @author Digital Align Team | 10-26-2021
   * @param String applicantId
   **/
  global virtual Applicant__c readApplicantWithChild(Id applicantId) {
    return ApplicantRepository.readApplicantWithChild(applicantId);
  }

  /**
   * @description generate otp via sms or email
   * @author Digital Align Team | 11-05-2021
   * @param Id applicantId
   * @return Object
   **/
  global virtual Object generateOTP(Id applicantId) {
    Flow.initialize(ApexRequest.getApplicationId());
    Applicant__c applicant = ApplicantRepository.fetchApplicantById(
      applicantId
    );

    String otpMode = ApplicationConfiguration__c.getInstance()
      .AllowedOtpMode__c;
    List<String> otpModeList = String.isNotBlank(otpMode)
      ? otpMode.split(';')
      : new List<String>();

    //SMS
    if (otpModeList.contains('SMS')) {
      applicant.SmsOtp__c = Math.round((Math.random() * (9000) + 1000));
      applicant.SmsOtpAttempts__c = 0;
      applicant.OTPExpireTime__c = Datetime.now()
        .addMinutes(
          (Integer) ApplicationConfiguration__c.getOrgDefaults()
            .OTPExpirationTime__c
        );

      Map<String, Object> params = new Map<String, Object>();
      params.put(
        'messageText',
        System.Label.TwillioOtpFormat.replace(
          '{OTP}',
          String.valueOf(applicant.SmsOtp__c)
        )
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
      applicant.EmailOtp__c = Math.round((Math.random() * (9000) + 1000));
      applicant.EmailOtpAttempts__c = 0;
    }

    ApplicantRepository.updateRecord(applicant);
    return true;
  }

  /**
   * @description
   * @author Digital Align Team | 11-05-2021
   * @param Map<String Object> params
   * @return virtual
   **/
  global virtual Applicant__c validateOTP(Map<String, Object> params) {
    return null;
  }
}
