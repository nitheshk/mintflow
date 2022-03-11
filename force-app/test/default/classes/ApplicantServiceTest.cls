@istest
public with sharing class ApplicantServiceTest {
  private static Application__c makeApplicationData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);

    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    IdentificationDocument__c identity = TestData.createIdentity();
    identity.Applicant__c = applicant.Id;
    identity = (IdentificationDocument__c) DatabaseUtils.insertRecord(identity);
    applicant.mflow__IdentificationDocuments__r.addAll(new List<IdentificationDocument__c>{ identity });
    acc.Applicants__r.addAll(new List<Applicant__c>{ applicant });
    return acc;
  }
  private static Applicant__c makeApplicantData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);
    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant.OTPExpireTime__c = Datetime.now();
    applicant.OtpAttempts__c = 1;
    applicant.SmsOtp__c = '1234';
    applicant.EmailOtp__c = '1234';
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    Employment__c employment = TestData.createEmployment();
    employment.Applicant__c = applicant.Id;
    employment = (Employment__c) DatabaseUtils.insertRecord(employment);
    applicant.mflow__Employments__r.addAll(new List<Employment__c>{ employment });

    return applicant;
  }
  @isTest
  static void applicantListTest() {
    Application__c application = makeApplicationData();
    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantIds' => application.applicants__r });
    request.setData(application.applicants__r);
    test.startTest();
    ApplicantController.saveApplicants(request);
    test.stopTest();
  }
  @isTest
  static void singleApplicantTest() {
    Application__c application = makeApplicationData();
    Applicant__c applicant = makeApplicantData();
    ApexRequest request = new ApexRequest();
    request.setHeader(
      new Map<String, object>{
        'applicantIds' => new List<Applicant__c>{ applicant, applicant },
        'applicantId' => applicant.Id,
        'otpMode' => 'SMS',
        'sms' => '1234',
        'email' => '1234'
      }
    );
    request.setData(new Applicant__c());
    test.startTest();
    ApplicantController.readApplicantsWithChild(request);
    ApplicantController.saveApplicant(request);
    ApplicantController.generateOTP(request);
    ApplicantController.validateOTP(request);
    test.stopTest();
  }
  @isTest
  static void singleApplicantTestTwo() {
    Application__c application = makeApplicationData();
    Applicant__c applicant = makeApplicantData();
    ApexRequest request = new ApexRequest();
    request.setHeader(
      new Map<String, object>{
        'applicantIds' => new List<Applicant__c>{ applicant, applicant },
        'applicantId' => applicant.Id,
        'otpMode' => 'SMS',
        'sms' => '1234',
        'email' => '1234'
      }
    );
    request.setData(new Applicant__c());
    test.startTest();
    try {
      ApplicantController.readApplicantsWithChild(new ApexRequest());
      ApplicantController.saveApplicant(new ApexRequest());
      ApplicantController.generateOTP(new ApexRequest());
      ApplicantController.validateOTP(new ApexRequest());
    } catch (Exception e) {
    }
    test.stopTest();
  }
}
