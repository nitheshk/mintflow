@istest
public with sharing class ApplicantControllerTest {
  private static void makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    insert appConfig;
    SystemSetting__c systemSetting = TestData.createSystemSetting();
    insert systemSetting;
    List<FinancialProduct__c> products = TestData.createProduct();
    insert products;
  }

  private static Applicant__c createApplicantDataWithChild(Application__c Application) {
    Applicant__c applicant = TestData.createApplicant(Application.Id);
    insert Applicant;
    SObjectConstructor construct = SObjectConstructor.getInstance(applicant);

    IdentificationDocument__c identity = TestData.createIdentity(applicant.Id);
    insert identity;

    Employment__c employment = TestData.createEmployment(applicant.Id);
    insert employment;

    ContactPointAddress address = TestData.createContactPointAddress(applicant.Id);
    insert address;

    construct.addChildObject('mflow__IdentificationDocuments__r', identity);
    construct.addChildObject('mflow__Employments__r', employment);
    construct.addChildObject('mflow__ContactPointAddresses__r', address);

    return (Applicant__c) construct.build();
  }
  private static void createExistingContact(string ssn) {
    Contact con = testdata.createContact(null);
    con.mflow__SSN__c = ssn;
    upsert con;
  }

  @isTest
  static void readApplicantTest() {
    makeApplicationConfiguration();
    Application__c app = TestData.createApplication();
    insert app;
    Applicant__c applicant = createApplicantDataWithChild(app);
    String token = SecurityUtils.generateTokenForTesting(
      app.Id,
      applicant.id,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    //200
    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantIds' => new List<String>{ applicant.Id } });
    request.token = token;
    ApexResponse res = ApplicantController.readApplicantsWithChild(request);
    system.assertEquals(200, res.status, 'success');

    //500
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantIds' => new List<String>{ applicant.Id } });
    request.token = 'invalidToken';
    res = ApplicantController.readApplicantsWithChild(request);
    system.assertEquals(500, res.status, 'success');

    //400
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantIds' => new Map<String, String>{ 'key' => 'value' } });
    request.token = token;
    res = ApplicantController.readApplicantsWithChild(request);
    system.assertEquals(400, res.status, 'success');

    //Applicant Service Read
    ApplicantService.getInstance().readApplicantWithChild(applicant.Id);
  }

  @isTest
  static void saveApplicantsTest() {
    makeApplicationConfiguration();
    Application__c app = TestData.createApplication();
    insert app;
    Applicant__c applicant = createApplicantDataWithChild(app);
    String token = SecurityUtils.generateTokenForTesting(
      app.Id,
      applicant.id,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantIds' => new List<String>{ applicant.Id } });
    request.token = token;
    ApexResponse res = ApplicantController.readApplicantsWithChild(request);
    system.assertEquals(200, res.status, 'success');
    //200
    request = new ApexRequest();
    request.token = token;
    request.data = (String) res.data;
    res = ApplicantController.saveApplicants(request);
    system.assertEquals(200, res.status, 'success');
    //500
    request = new ApexRequest();
    request.token = 'invalidToken';
    request.data = (String) res.data;
    res = ApplicantController.saveApplicants(request);
    system.assertEquals(500, res.status, 'success');

    //400
    request = new ApexRequest();
    request.token = token;
    request.data = (String) '{}';
    res = ApplicantController.saveApplicants(request);
    system.assertEquals(400, res.status, 'success');
  }

  @isTest
  static void saveApplicantTest() {
    makeApplicationConfiguration();
    Application__c app = TestData.createApplication();
    insert app;
    Applicant__c applicant = createApplicantDataWithChild(app);
    String token = SecurityUtils.generateTokenForTesting(
      app.Id,
      applicant.id,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantIds' => new List<String>{ applicant.Id } });
    request.token = token;
    ApexResponse res = ApplicantController.readApplicantsWithChild(request);
    system.assertEquals(200, res.status, 'success');

    List<Object> applicants = (List<Object>) Json.deserializeUntyped((String) res.data);
    String applicantJson = Json.serialize(applicants[0]);
    //200
    request = new ApexRequest();
    request.token = token;
    request.data = applicantJson;
    res = ApplicantController.saveApplicant(request);
    system.assertEquals(200, res.status, 'success');
    //500
    request = new ApexRequest();
    request.token = 'invalidToken';
    request.data = applicantJson;
    res = ApplicantController.saveApplicant(request);
    system.assertEquals(500, res.status, 'success');

    //400
    request = new ApexRequest();
    request.token = token;
    request.data = (String) '[]';
    res = ApplicantController.saveApplicant(request);
    system.assertEquals(400, res.status, 'success');
  }

  @isTest
  static void generateOTPTest() {
    makeApplicationConfiguration();
    Application__c app = TestData.createApplication();
    insert app;
    Applicant__c applicant = createApplicantDataWithChild(app);
    applicant.Email__c = 'test@test.com';
    applicant.Phone__c = '9876543210';
    upsert applicant;
    String token = SecurityUtils.generateTokenForTesting(
      app.Id,
      applicant.id,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    //400 OTP Generate custom Exception
    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantId' => 'invalidID' });
    request.token = token;
    ApexResponse res = ApplicantController.generateOTP(request);
    system.assertEquals(400, res.status, 'success');

    //200
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('SampleRequest', '200'));
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantId' => applicant.Id });
    request.token = token;
    res = ApplicantController.generateOTP(request);
    system.assertEquals(200, res.status, 'success');
    Test.stopTest();
  }

  @isTest
  static void validateOTPTest() {
    makeApplicationConfiguration();
    Application__c app = TestData.createApplication();
    insert app;
    Applicant__c applicant = createApplicantDataWithChild(app);
    applicant.Email__c = 'test@test.com';
    applicant.Phone__c = '9876543210';
    upsert applicant;
    String token = SecurityUtils.generateTokenForTesting(
      app.Id,
      applicant.id,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    //200
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('SampleRequest', '200'));
    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantId' => applicant.Id });
    request.token = token;
    ApexResponse res = ApplicantController.generateOTP(request);
    system.assertEquals(200, res.status, 'success');
    Test.stopTest();

    //200
    //#1
    applicant = [SELECT id, SmsOtp__c, EmailOtp__c FROM mflow__Applicant__c WHERE id = :applicant.id];
    request = new ApexRequest();
    request.setHeader(
      new Map<String, object>{
        'sms' => applicant.SmsOtp__c,
        'email' => applicant.EmailOtp__c,
        'applicantId' => applicant.Id
      }
    );
    request.token = token;
    res = ApplicantController.validateOTP(request);
    system.assertEquals(200, res.status, 'success');
    //400
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantId' => 'invalidId' });
    request.token = token;
    res = ApplicantController.validateOTP(request);
    system.assertEquals(400, res.status, 'success');

    ApplicationConfiguration__c appConfig = [SELECT AllowedOtpMode__c FROM ApplicationConfiguration__c LIMIT 1];
    //500
    //#2 Empty EMail
    appConfig.AllowedOtpMode__c = 'EMAIL';
    update appConfig;
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'email' => '', 'applicantId' => applicant.Id });
    request.token = token;
    res = ApplicantController.validateOTP(request);
    system.assertEquals(500, res.status, 'success');

    //#3 Empty sms
    appConfig.AllowedOtpMode__c = 'SMS';
    update appConfig;
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'sms' => '', 'applicantId' => applicant.Id });
    request.token = token;
    res = ApplicantController.validateOTP(request);
    system.assertEquals(500, res.status, 'success');

    //#4 Invalid EMail
    appConfig.AllowedOtpMode__c = 'EMAIL';
    update appConfig;
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'email' => '323', 'applicantId' => applicant.Id });
    request.token = token;
    res = ApplicantController.validateOTP(request);
    system.assertEquals(500, res.status, 'success');

    //#5 Invalid sms
    appConfig.AllowedOtpMode__c = 'SMS';
    update appConfig;
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'sms' => '232', 'applicantId' => applicant.Id });
    request.token = token;
    res = ApplicantController.validateOTP(request);
    system.assertEquals(500, res.status, 'success');

    applicant.SmsOtp__c = '1111';
    applicant.EmailOtp__c = '1111';
    update applicant;
    //#6 valid EMail
    appConfig.AllowedOtpMode__c = 'EMAIL';
    update appConfig;
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'email' => '1111', 'applicantId' => applicant.Id });
    request.token = token;
    res = ApplicantController.validateOTP(request);
    system.assertEquals(200, res.status, 'success');

    //#7 valid sms
    appConfig.AllowedOtpMode__c = 'SMS';
    update appConfig;
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'sms' => '1111', 'applicantId' => applicant.Id });
    request.token = token;
    res = ApplicantController.validateOTP(request);
    system.assertEquals(200, res.status, 'success');

    //#8 Max Attempta
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'sms' => '2222', 'applicantId' => applicant.Id });
    request.token = token;
    res = ApplicantController.validateOTP(request);
    system.assertEquals(500, res.status, 'success');

    //#9 expire OTP
    applicant.OTPExpireTime__c = Datetime.now().addMinutes(-10);
    update applicant;
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'otpMode' => 'SMS', 'sms' => '1111', 'applicantId' => applicant.Id });
    request.token = token;
    res = ApplicantController.validateOTP(request);
    system.assertEquals(500, res.status, 'success');
  }

  @isTest
  static void atomicAuthenticateTest() {
    makeApplicationConfiguration();
    Application__c app = TestData.createApplication();
    insert app;
    Applicant__c applicant = createApplicantDataWithChild(app);
    String token = SecurityUtils.generateTokenForTesting(
      app.Id,
      applicant.id,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    //400 Exception // no Mock API
    ApexRequest request = new ApexRequest();
    request.setHeader(
      new Map<String, object>{ 'applicantId' => applicant.Id, 'employerId' => applicant.Employments__r[0].Id }
    );
    request.token = token;
    ApexResponse res = ApplicantController.atomicAuthenticate(request);
    system.assertEquals(400, res.status, 'success');

    // 200
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('AtomicFIRequest', '200'));
    request = new ApexRequest();
    request.setHeader(
      new Map<String, object>{ 'applicantId' => applicant.Id, 'employerId' => applicant.Employments__r[0].Id }
    );
    request.token = token;
    res = ApplicantController.atomicAuthenticate(request);
    system.assertEquals(200, res.status, 'success');
    Test.stopTest();
  }

  @isTest
  static void getAtomicResponseTest() {
    makeApplicationConfiguration();
    Application__c app = TestData.createApplication();
    insert app;
    Applicant__c applicant = createApplicantDataWithChild(app);
    String token = SecurityUtils.generateTokenForTesting(
      app.Id,
      applicant.id,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    //400 Exception // no Mock API
    ApexRequest request = new ApexRequest();
    request.setHeader(
      new Map<String, object>{ 'applicantId' => applicant.Id, 'employerId' => applicant.Employments__r[0].Id }
    );
    request.token = token;
    ApexResponse res = ApplicantController.getAtomicResponse(request);
    system.assertEquals(200, res.status, 'success');

    //CReate NEw File for Atomicfic
    //FileService.getInstance().createFile
    FileService.getInstance()
      .createFile(
        new FileDTO('test.txt', blob.valueof('test'), applicant.Employments__r[0].Id, 'Employment', 'AtomicFIResponse')
      );

    request = new ApexRequest();
    request.setHeader(
      new Map<String, object>{ 'applicantId' => applicant.Id, 'employerId' => applicant.Employments__r[0].Id }
    );
    request.token = token;
    res = ApplicantController.getAtomicResponse(request);
    system.assertEquals(200, res.status, 'success');

    //exception case
    request = new ApexRequest();
    request.setHeader(
      new Map<String, object>{ 'applicantId' => 'invalidID', 'employerId' => applicant.Employments__r[0].Id }
    );
    request.token = token;
    res = ApplicantController.getAtomicResponse(request);
    system.assertEquals(400, res.status, 'success');
  }

  @isTest
  static void generatePaySlipsW2Test() {
    makeApplicationConfiguration();
    Application__c app = TestData.createApplication();
    insert app;
    Applicant__c applicant = createApplicantDataWithChild(app);
    String token = SecurityUtils.generateTokenForTesting(
      app.Id,
      applicant.id,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    //400 Exception // no Mock API
    ApexRequest request = new ApexRequest();
    request.setHeader(
      new Map<String, object>{ 'applicantId' => applicant.Id, 'employerId' => applicant.Employments__r[0].Id }
    );
    request.token = token;
    ApexResponse res = ApplicantController.generatePaySlipsW2(request);
    system.assertEquals(400, res.status, 'success');
  }

  @isTest
  static void validateAtomicFiTest() {
    makeApplicationConfiguration();
    Application__c app = TestData.createApplication();
    insert app;
    Applicant__c applicant = createApplicantDataWithChild(app);
    String token = SecurityUtils.generateTokenForTesting(
      app.Id,
      applicant.id,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    //200
    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'employerId' => applicant.Employments__r[0].Id });
    request.token = token;
    ApexResponse res = ApplicantController.validateAtomicFi(request);
    system.assertEquals(200, res.status, 'success');
  }

  /** Application Service  */
  @isTest
  static void afterSaveApplicantsTest() {
    makeApplicationConfiguration();
    List<FinancialProduct__c> products = TestData.createProduct();
    insert products;
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());

    Applicant__c familyMember = TestData.createApplicant(application.id);
    familyMember.ApplicantType__c = 'Family Member';
    familyMember.Email__c = 'test@test.com';
    familyMember.Phone__c = '9876543210';
    insert familyMember;

    //200
    ApexRequest request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'applicantIds' => new List<String>{ ApexRequest.getApplicantId() } });
    request.token = ApexRequest.getToken();
    ApexResponse res = ApplicantController.readApplicantsWithChild(request);
    system.assertEquals(200, res.status, 'success');

    //Save Applicant
    List<Object> applicants = (List<Object>) Json.deserializeUntyped((String) res.data);
    String applicantJson = Json.serialize(applicants[0]);
    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.currentPage = 'PersonalInfo';
    request.data = applicantJson;
    res = ApplicantController.saveApplicant(request);
    system.assertEquals(200, res.status, 'success');

    //200 //saveApplicants
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.data = (String) Json.serialize(applicants);
    request.currentPage = 'PersonalInfo';
    res = ApplicantController.saveApplicants(request);
    system.assertEquals(200, res.status, 'success');
  }

  @isTest
  static void verifyKYCTest() {
    makeApplicationConfiguration();
    Application__c app = TestData.createApplication();
    insert app;
    Applicant__c applicant = createApplicantDataWithChild(app);
    String token = SecurityUtils.generateTokenForTesting(
      app.Id,
      applicant.id,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    //200
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('AlloyKYC', '201'));
    ApexRequest request = new ApexRequest();
    request.token = token;
    ApexRequest.setApplicantId(applicant.Id);
    AlloyProvider.getInstance();
    ApexResponse res = ApplicantController.verifyKYC(request);
    Test.stopTest();
  }

  @isTest
  static void verifyKYCTestTwo() {
    makeApplicationConfiguration();
    Application__c app = TestData.createApplication();
    insert app;
    Applicant__c applicant = createApplicantDataWithChild(app);

    //200
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('AlloyKYCFailed', '400'));
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse res = ApplicantController.verifyKYC(request);
    Test.stopTest();
  }

  @isTest
  static void validateExistingCustomerTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    String token = SecurityUtils.generateTokenForTesting(
      application.Id,
      applicant.id,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    //200
    ApexRequest request = new ApexRequest();
    request.token = token;
    ApexResponse res = ApplicantController.validateExistingCustomer(request);
    // system.assertEquals(200, res.status, 'success');

    createExistingContact(applicant.SSN__c);
    request = new ApexRequest();
    request.token = token;
    res = ApplicantController.validateExistingCustomer(request);
  }
  @isTest
  static void getBaseURLTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse res = ApplicantController.getBaseURL(request);
    // system.assertEquals(200, res.status, 'success');
  }
}
