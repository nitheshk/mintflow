@istest
public with sharing class OnlinePortalControllerTest {
  //makeApplicationConfiguration
  private static void makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    insert appConfig;
    TestData.createSiteSetting();
    List<FinancialProduct__c> products = TestData.createProduct();
    insert products;
  }

  @isTest
  static void productSelectorTest() {
    makeApplicationConfiguration();
    //200
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse res = OnlinePortalController.productSelector(request);
    system.assertEquals(200, res.status, 'success');

    request = new ApexRequest();
    request.token = 'InvalidToken';
    res = OnlinePortalController.productSelector(null);
    system.assertEquals(400, res.status, 'success');
  }

  @isTest
  static void onlinePortalAuthenticateTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = Application.Applicants__r[0];
    applicant.Email__c = 'test@test.com';
    applicant.Phone__c = '9876543210';
    applicant.LastName__c = 'lastname';
    applicant.SSN__c = '9876543210';
    applicant.IsEmailVerified__c = true;
    update applicant;

    // Failure
    ApexRequest request = new ApexRequest();
    request.setHeader(
      new Map<String, object>{ 'lastName' => 'Failure', 'email' => applicant.Email__c, 'ssn' => applicant.SSN__c }
    );
    ApexResponse res = OnlinePortalController.onlinePortalAuthenticate(request);

    //Success case
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(
      new Map<String, object>{
        'lastName' => applicant.LastName__c,
        'email' => applicant.Email__c,
        'ssn' => applicant.SSN__c
      }
    );
    res = OnlinePortalController.onlinePortalAuthenticate(request);
    system.assertEquals(200, res.status, 'success');
  }

  @isTest
  static void onlinePortalAuthorizeTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = Application.Applicants__r[0];
    applicant.Email__c = 'test@test.com';
    applicant.Phone__c = '9876543210';
    applicant.LastName__c = 'lastname';
    applicant.SSN__c = '9876543210';
    applicant.IsEmailVerified__c = true;
    update applicant;

    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(
      new Map<String, object>{
        'lastName' => applicant.LastName__c,
        'email' => applicant.Email__c,
        'ssn' => applicant.SSN__c
      }
    );

    ApexResponse res = OnlinePortalController.onlinePortalAuthenticate(request);

    SessionManagement__c sn = (SessionManagement__c) (JSON.deserialize((String) res.data, SessionManagement__c.class));

    //Failure no EMail OTP
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'sessionId' => sn.Id });
    res = OnlinePortalController.onlinePortalAuthorize(request);

    sn = [SELECT EmailOtp__c FROM SessionManagement__c WHERE id = :sn.Id];
    system.debug('sn :' + sn);

    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'sessionId' => sn.Id, 'email' => sn.EmailOtp__c });
    res = OnlinePortalController.onlinePortalAuthorize(request);
    system.assertEquals(200, res.status, 'success');
  }

  @isTest
  static void fetchMyApplicationTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = Application.Applicants__r[0];
    applicant.Email__c = 'test@test.com';
    applicant.Phone__c = '9876543210';
    applicant.LastName__c = 'lastname';
    applicant.SSN__c = '9876543210';
    applicant.IsEmailVerified__c = true;
    update applicant;

    //onlinePortalAuthenticate
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(
      new Map<String, object>{
        'lastName' => applicant.LastName__c,
        'email' => applicant.Email__c,
        'ssn' => applicant.SSN__c
      }
    );

    ApexResponse res = OnlinePortalController.onlinePortalAuthenticate(request);
    SessionManagement__c sn = (SessionManagement__c) (JSON.deserialize((String) res.data, SessionManagement__c.class));
    sn = [SELECT EmailOtp__c FROM SessionManagement__c WHERE id = :sn.Id];
    system.debug('sn :' + sn);

    //onlinePortalAuthorize
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'sessionId' => sn.Id, 'email' => sn.EmailOtp__c });
    res = OnlinePortalController.onlinePortalAuthorize(request);
    system.assertEquals(200, res.status, 'success');

    //readApplicationWithChild Sucess
    sn = (SessionManagement__c) (JSON.deserialize((String) res.data, SessionManagement__c.class));

    request = new ApexRequest();
    request.token = sn.SessionToken__c;
    res = OnlinePortalController.fetchMyApplication(request);
    system.assertEquals(200, res.status, 'success');

    //readApplicationWithChild Exception
    request = new ApexRequest();
    res = OnlinePortalController.fetchMyApplication(request);
    system.assertEquals(400, res.status, 'success');
  }

  @isTest
  static void readApplicationWithChildTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = Application.Applicants__r[0];
    applicant.Email__c = 'test@test.com';
    applicant.Phone__c = '9876543210';
    applicant.LastName__c = 'lastname';
    applicant.SSN__c = '9876543210';
    applicant.IsEmailVerified__c = true;
    update applicant;

    //onlinePortalAuthenticate
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(
      new Map<String, object>{
        'lastName' => applicant.LastName__c,
        'email' => applicant.Email__c,
        'ssn' => applicant.SSN__c
      }
    );

    ApexResponse res = OnlinePortalController.onlinePortalAuthenticate(request);
    SessionManagement__c sn = (SessionManagement__c) (JSON.deserialize((String) res.data, SessionManagement__c.class));
    sn = [SELECT EmailOtp__c FROM SessionManagement__c WHERE id = :sn.Id];
    system.debug('sn :' + sn);

    //onlinePortalAuthorize
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'sessionId' => sn.Id, 'email' => sn.EmailOtp__c });
    res = OnlinePortalController.onlinePortalAuthorize(request);
    system.assertEquals(200, res.status, 'success');

    //readApplicationWithChild Sucess
    sn = (SessionManagement__c) (JSON.deserialize((String) res.data, SessionManagement__c.class));

    request = new ApexRequest();
    request.token = sn.SessionToken__c;
    request.setHeader(new Map<String, object>{ 'applicationId' => application.Id });
    res = OnlinePortalController.readApplicationWithChild(request);
    system.assertEquals(200, res.status, 'success');

    //readApplicationWithChild Exception
    request = new ApexRequest();
    res = OnlinePortalController.readApplicationWithChild(request);
    system.assertEquals(400, res.status, 'success');
  }

  @isTest
  static void resumeApplicationTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = Application.Applicants__r[0];
    applicant.Email__c = 'test@test.com';
    applicant.Phone__c = '9876543210';
    applicant.LastName__c = 'lastname';
    applicant.SSN__c = '9876543210';
    applicant.IsEmailVerified__c = true;
    update applicant;

    //onlinePortalAuthenticate
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(
      new Map<String, object>{
        'lastName' => applicant.LastName__c,
        'email' => applicant.Email__c,
        'ssn' => applicant.SSN__c
      }
    );

    ApexResponse res = OnlinePortalController.onlinePortalAuthenticate(request);
    SessionManagement__c sn = (SessionManagement__c) (JSON.deserialize((String) res.data, SessionManagement__c.class));
    sn = [SELECT EmailOtp__c FROM SessionManagement__c WHERE id = :sn.Id];
    system.debug('sn :' + sn);

    //onlinePortalAuthorize
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'sessionId' => sn.Id, 'email' => sn.EmailOtp__c });
    res = OnlinePortalController.onlinePortalAuthorize(request);
    system.assertEquals(200, res.status, 'success');

    //Sucess
    sn = (SessionManagement__c) (JSON.deserialize((String) res.data, SessionManagement__c.class));

    request = new ApexRequest();
    request.token = sn.SessionToken__c;
    request.setHeader(new Map<String, object>{ 'applicationId' => application.Id, 'resumeType' => 'url' });
    res = OnlinePortalController.resumeApplication(request);
    system.assertEquals(200, res.status, 'success');

    request = new ApexRequest();
    request.token = sn.SessionToken__c;
    request.setHeader(new Map<String, object>{ 'applicationId' => application.Id, 'resumeType' => 'email' });
    res = OnlinePortalController.resumeApplication(request);
    system.assertEquals(200, res.status, 'success');

    request = new ApexRequest();
    request.token = sn.SessionToken__c;
    request.setHeader(new Map<String, object>{ 'applicationId' => application.Id });
    res = OnlinePortalController.resumeApplication(request);
    system.assertEquals(200, res.status, 'success');

    // Exception
    request = new ApexRequest();
    res = OnlinePortalController.resumeApplication(request);
    system.assertEquals(400, res.status, 'success');
  }

  @isTest
  static void uploadDocumentTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = Application.Applicants__r[0];
    applicant.Email__c = 'test@test.com';
    applicant.Phone__c = '9876543210';
    applicant.LastName__c = 'lastname';
    applicant.SSN__c = '9876543210';
    applicant.IsEmailVerified__c = true;
    update applicant;

    //test data
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(
      new Map<String, object>{
        'lastName' => applicant.LastName__c,
        'email' => applicant.Email__c,
        'ssn' => applicant.SSN__c
      }
    );

    ApexResponse res = OnlinePortalController.onlinePortalAuthenticate(request);
    SessionManagement__c sn = (SessionManagement__c) (JSON.deserialize((String) res.data, SessionManagement__c.class));
    sn = [SELECT EmailOtp__c FROM SessionManagement__c WHERE id = :sn.Id];
    system.debug('sn :' + sn);

    //test data
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'sessionId' => sn.Id, 'email' => sn.EmailOtp__c });
    res = OnlinePortalController.onlinePortalAuthorize(request);
    system.assertEquals(200, res.status, 'success');

    //Sucess
    sn = (SessionManagement__c) (JSON.deserialize((String) res.data, SessionManagement__c.class));

    DocumentRequest__c docReq = new DocumentRequest__c();
    docReq.mflow__Applicant__c = applicant.id;
    docReq.mflow__Application__c = application.Id;
    docReq.mflow__Comments__c = 'Test';
    docReq.mflow__DocumentType__c = 'Address';
    docReq.mflow__Name__c = 'Test';
    docReq.mflow__Status__c = 'New';
    insert docReq;

    Map<String, String> header = new Map<String, String>();
    header.put('title', 'TestFile.txt');
    header.put('parentID', docReq.Id);
    header.put('fileType', 'Address');
    header.put('fileSubType', 'Other');
    header.put('shareType', 'I');
    header.put('visibility', 'AllUsers');

    request = new ApexRequest();
    request.token = sn.SessionToken__c;
    request.setHeader(header);
    request.setData(Json.serialize('data'));
    res = OnlinePortalController.uploadDocument(request);
    system.assertEquals(200, res.status, 'success');

    // Exception
    request = new ApexRequest();
    res = OnlinePortalController.uploadDocument(request);
    system.assertEquals(400, res.status, 'success');
  }

  @isTest
  static void fetchAllDocumentRequestFilesTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = Application.Applicants__r[0];
    applicant.Email__c = 'test@test.com';
    applicant.Phone__c = '9876543210';
    applicant.LastName__c = 'lastname';
    applicant.SSN__c = '9876543210';
    applicant.IsEmailVerified__c = true;
    update applicant;

    //test data
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setHeader(
      new Map<String, object>{
        'lastName' => applicant.LastName__c,
        'email' => applicant.Email__c,
        'ssn' => applicant.SSN__c
      }
    );

    ApexResponse res = OnlinePortalController.onlinePortalAuthenticate(request);
    SessionManagement__c sn = (SessionManagement__c) (JSON.deserialize((String) res.data, SessionManagement__c.class));
    sn = [SELECT EmailOtp__c FROM SessionManagement__c WHERE id = :sn.Id];
    system.debug('sn :' + sn);

    //test data
    request = new ApexRequest();
    request.setHeader(new Map<String, object>{ 'sessionId' => sn.Id, 'email' => sn.EmailOtp__c });
    res = OnlinePortalController.onlinePortalAuthorize(request);
    system.assertEquals(200, res.status, 'success');

    //Sucess
    sn = (SessionManagement__c) (JSON.deserialize((String) res.data, SessionManagement__c.class));

    DocumentRequest__c docReq = new DocumentRequest__c();
    docReq.mflow__Applicant__c = applicant.id;
    docReq.mflow__Application__c = application.Id;
    docReq.mflow__Comments__c = 'Test';
    docReq.mflow__DocumentType__c = 'Address';
    docReq.mflow__Name__c = 'Test';
    docReq.mflow__Status__c = 'New';
    insert docReq;

    Map<String, String> header = new Map<String, String>();
    header.put('title', 'TestFile.txt');
    header.put('parentID', docReq.Id);
    header.put('fileType', 'Address');
    header.put('fileSubType', 'Other');
    header.put('shareType', 'I');
    header.put('visibility', 'AllUsers');

    Test.enableChangeDataCapture();
    request = new ApexRequest();
    request.token = sn.SessionToken__c;
    request.setHeader(header);
    request.setData(Json.serialize('data'));
    res = OnlinePortalController.uploadDocument(request);
    system.assertEquals(200, res.status, 'success');

    Test.getEventBus().deliver();

    // success
    request = new ApexRequest();
    request.token = sn.SessionToken__c;
    request.setHeader(new Map<String, object>{ 'applicationId' => application.Id });
    res = OnlinePortalController.fetchAllDocumentRequestFiles(request);
    system.assertEquals(200, res.status, 'success');

    // Exception
    // request = new ApexRequest();
    // res = OnlinePortalController.fetchAllDocumentRequestFiles(request);
    // system.assertEquals(400, res.status, 'success');
  }
}
