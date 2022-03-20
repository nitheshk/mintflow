@istest
public with sharing class ApplicationControllerTest {
  //makeApplicationConfiguration
  private static void makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    insert appConfig;
    TestData.createSiteSetting();
    List<FinancialProduct__c> products = TestData.createProduct();
    insert products;
  }
  //createApplicantDataWithChild
  private static Applicant__c createApplicantDataWithChild(Application__c application) {
    Applicant__c applicant = Application.Applicants__r[0];
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

  //startApplicationTest
  @isTest
  static void startApplicationTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse res = ApplicationController.startApplication(request);
    system.assertEquals(200, res.status, 'success');

    //400
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    res = ApplicationController.startApplication(null);
    system.assertEquals(400, res.status, 'success');
  }

  //readApplicationWithChild
  @isTest
  static void readApplicationWithChildTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200 //Primary
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse res = ApplicationController.readApplicationWithChild(request);
    system.assertEquals(200, res.status, 'success');

    //200 //Joint
    String token = SecurityUtils.generateTokenForTesting(
      application.Id,
      applicant.id,
      ApplicationConstant.APPLICANT_JOINT_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );
    request = new ApexRequest();
    request.token = token;
    res = ApplicationController.readApplicationWithChild(request);
    system.assertEquals(200, res.status, 'success');

    //500
    request = new ApexRequest();
    request.token = 'InvalidToken';
    res = ApplicationController.readApplicationWithChild(request);
    system.assertEquals(500, res.status, 'success');
  }

  //saveApplicationTest
  @isTest
  static void saveApplicationTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse res = ApplicationController.readApplicationWithChild(request);
    system.assertEquals(200, res.status, 'success');
    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.data = (String) res.data;
    res = ApplicationController.saveApplication(request);
    system.assertEquals(200, res.status, 'success');

    //400
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.data = 'InvalidaJson';
    res = ApplicationController.saveApplication(request);
    system.assertEquals(400, res.status, 'success');
    //500
    request = new ApexRequest();
    request.token = 'invalidToken';
    request.data = (String) res.data;
    res = ApplicationController.saveApplication(request);
    system.assertEquals(500, res.status, 'success');
  }

  //saveApplicationFlowStateTest
  @isTest
  static void saveApplicationFlowStateTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.currentPage = ApplicationConstant.GET_STARTED;
    ApexResponse res = ApplicationController.readApplicationWithChild(request);
    system.assertEquals(200, res.status, 'success');
    //200
    ApplicationService.getInstance().updateFlowState(application);
    ApplicationService.getInstance().updateFlowState(application.Applicants__r);
    ApplicationService.getInstance().updateFlowState(applicant);
    ApplicationService.getInstance().updateFlowState(application.FinancialAccounts__r);

    ApexRequest.setApplicantType(ApplicationConstant.APPLICANT_JOINT_RECORDTYPE);
    ApplicationService.getInstance().updateFlowState(applicant);

    //Exception
    ApexRequest.getRequest().currentPage = 'InvalidPage';
    ApplicationService.getInstance().updateFlowState(applicant);
  }

  //deleteEntityTest1
  @isTest
  static void deleteEntityTest1() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse res = ApplicationController.readApplicationWithChild(request);
    system.assertEquals(200, res.status, 'success');

    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, object>{ 'recordId' => application.FinancialAccounts__r[0].Id });
    res = ApplicationController.deleteEntity(request);
    system.assertEquals(200, res.status, 'success');

    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, object>{ 'recordId' => applicant.IdentificationDocuments__r[0].Id });
    res = ApplicationController.deleteEntity(request);
    system.assertEquals(200, res.status, 'success');

    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, object>{ 'recordId' => applicant.ContactPointAddresses__r[0].Id });
    res = ApplicationController.deleteEntity(request);
    system.assertEquals(200, res.status, 'success');

    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, object>{ 'recordId' => applicant.Employments__r[0].Id });
    res = ApplicationController.deleteEntity(request);
    system.assertEquals(200, res.status, 'success');

    //200
    Application__c app = new Application__c();
    insert app;
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, object>{ 'recordId' => app.Id });
    res = ApplicationController.deleteEntity(request);
    system.assertEquals(200, res.status, 'success');

    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, object>{ 'recordId' => applicant.Id });
    res = ApplicationController.deleteEntity(request);
    system.assertEquals(200, res.status, 'success');
  }

  //deleteEntityTest2
  @isTest
  static void deleteEntityTest2() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse res = ApplicationController.readApplicationWithChild(request);
    system.assertEquals(200, res.status, 'success');

    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(new Map<String, object>{ 'recordIds' => new List<String>{ application.Id } });
    res = ApplicationController.deleteEntity(request);
    system.assertEquals(200, res.status, 'success');

    //500
    request = new ApexRequest();
    request.token = 'InvalidToken';
    request.setHeader(new Map<String, object>{ 'recordIds' => new List<String>{ application.Id } });
    res = ApplicationController.deleteEntity(request);
    system.assertEquals(500, res.status, 'success');
  }

  //reviewInformationSubmit
  //Failure case when api is not working
  @isTest
  static void reviewInformationSubmitTest1() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    String primaryToken = ApexRequest.getToken();

    // Joint Applicant
    Applicant__c jointApplicant = TestData.createApplicant(application.Id);
    jointApplicant.ApplicantType__c = 'Joint';
    jointApplicant.recordTypeId = SObjectUtils.recordTypeIdByName(Applicant__c.SObjectType, 'Joint');
    insert jointApplicant;
    //200 Primary
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse res = ApplicationController.reviewInformationSubmit(request);
    system.assertEquals(200, res.status, 'success');

    //Joint
    String jointToken = SecurityUtils.generateTokenForTesting(
      application.Id,
      jointApplicant.id,
      ApplicationConstant.APPLICANT_JOINT_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    request = new ApexRequest();
    request.token = jointToken;
    res = ApplicationController.reviewInformationSubmit(request);
    system.assertEquals(200, res.status, 'success');

    // Submit primary for Exception
    application.Status__c = ApplicationConstant.IN_PROGRESS;
    update application;
    request = new ApexRequest();
    request.token = primaryToken;
    res = ApplicationController.reviewInformationSubmit(request);
    system.assertEquals(200, res.status, 'success');
  }

  //reviewInformationSubmitTest2
  //Success for Primary Submitted
  @isTest
  static void reviewInformationSubmitTest2() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    String primaryToken = ApexRequest.getToken();

    // Joint Applicant
    Applicant__c jointApplicant = TestData.createApplicant(application.Id);
    jointApplicant.ApplicantType__c = 'Joint';
    jointApplicant.Status__c = ApplicationConstant.SUBMITTED_FOR_REVIEW;
    jointApplicant.recordTypeId = SObjectUtils.recordTypeIdByName(Applicant__c.SObjectType, 'Joint');
    insert jointApplicant;
    //200 Primary
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('RpaReviewQueue', 'ReviewSubmit_200'));
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse res = ApplicationController.reviewInformationSubmit(request);
    system.assertEquals(200, res.status, 'success');
    Test.stopTest();
  }

  //reviewInformationSubmitTest3
  //Success for Joint Submitted
  @isTest
  static void reviewInformationSubmitTest3() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    String primaryToken = ApexRequest.getToken();

    // Joint Applicant
    Applicant__c jointApplicant = TestData.createApplicant(application.Id);
    jointApplicant.ApplicantType__c = 'Joint';
    jointApplicant.Status__c = ApplicationConstant.SUBMITTED_FOR_REVIEW;
    jointApplicant.recordTypeId = SObjectUtils.recordTypeIdByName(Applicant__c.SObjectType, 'Joint');
    insert jointApplicant;

    applicant.Status__c = ApplicationConstant.SUBMITTED_FOR_REVIEW;
    update applicant;
    String jointToken = SecurityUtils.generateTokenForTesting(
      application.Id,
      jointApplicant.id,
      ApplicationConstant.APPLICANT_JOINT_RECORDTYPE,
      ApplicationConstant.FLOW_TYPE_APPLICATION
    );

    //200 Joint
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('RpaReviewQueue', 'ReviewSubmit_200'));
    ApexRequest request = new ApexRequest();
    request.token = jointToken;
    ApexResponse res = ApplicationController.reviewInformationSubmit(request);
    system.assertEquals(200, res.status, 'success');
    Test.stopTest();

    //500 Already Submitted
    request = new ApexRequest();
    request.token = jointToken;
    res = ApplicationController.reviewInformationSubmit(request);
    system.assertEquals(500, res.status, 'success');
  }

  //resubmitTheApplication
  //Success for Primary Submitted
  @isTest
  static void resubmitTheApplicationTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //Exception
    ApexResponse res = LwcCustomController.resubmitTheApplication(ApexRequest.getApplicationId());
    system.assertEquals(500, res.status, 'success');
    //200 Primary
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockAPIResponse('RpaReviewQueue', 'ReviewSubmit_200'));
    res = LwcCustomController.resubmitTheApplication(ApexRequest.getApplicationId());
    system.assertEquals(200, res.status, 'success');
    Test.stopTest();
  }

  //tokenTest
  @isTest
  static void tokenTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse res = ApplicationController.refreshToken(request);
    system.assertEquals(200, res.status, 'success');
    //200
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    res = ApplicationController.expireToken(request);
    system.assertEquals(200, res.status, 'success');
    //500
    request = new ApexRequest();
    request.token = 'invalidToken';
    res = ApplicationController.refreshToken(request);
    system.assertEquals(500, res.status, 'success');

    //500
    request = new ApexRequest();
    request.token = 'invalidToken';
    res = ApplicationController.expireToken(request);
    system.assertEquals(400, res.status, 'success');
  }
}
