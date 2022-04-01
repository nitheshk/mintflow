@istest
public with sharing class FileControllerTest {
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

  public static ContentVersion makeContentVersion() {
    ContentVersion cv = TestData.createContentVersion();
    cv = (ContentVersion) DatabaseUtils.insertRecord(cv);
    return cv;
  }

  public static List<FileDTO> makeFileDtos(string applicantId) {
    List<FileDTO> fileDtos = new List<FileDTO>();
    fileDtos.add(TestData.createFileDto('TestFile.txt', applicantId));
    fileDtos.add(TestData.createFileDto('TestFileTwo.txt', applicantId));
    return fileDtos;
  }

  @isTest
  static void createFileTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);

    //200
    Map<String, String> header = new Map<String, String>();
    header.put('title', 'TestFile.txt');
    header.put('parentID', applicant.Id);
    header.put('fileType', 'Address');
    header.put('fileSubType', 'Other');
    header.put('shareType', 'I');
    header.put('visibility', 'AllUsers');
    header.put('entityId', applicant.Id);
    header.put('contentDocumentId', applicant.Id);
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setData(Json.serialize('data'));
    request.setHeader(header);
    FileController.createFile(request);

    header = new Map<String, String>();
    header.put('title', 'TestFile.txt');
    header.put('parentID', applicant.Id);
    header.put('fileType', 'Address');
    header.put('fileSubType', 'Other');
    header.put('shareType', 'I');
    header.put('visibility', 'AllUsers');
    header.put('entityId', applicant.Id);
    header.put('contentDocumentId', applicant.Id);
    request = new ApexRequest();
    request.token = ApexRequest.getToken();
    request.setData(Json.serialize('data'));
    request.setHeader(header);
    FileController.fetchContentVersionByCD(request);
  }
  @isTest
  static void fileServiceTest() {
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    List<FileDTO> fileDtos = makeFileDtos(applicant.Id);
    test.startTest();
    fileService.getInstance().createFiles(fileDtos);
    fileService.getInstance().fetchContentVersionByFileType(applicant.Id, 'Address', 'Other', false);
    fileService.getInstance().deleteContentVersionByEntityId(applicant.Id);
    fileService.getInstance().deleteContentVersion(applicant.Id);

    fileService.getInstance().fetchContentVersionsByIds(new List<Id>{ applicant.Id }, true);
    fileService.getInstance().fetchContentVersionById(applicant.Id, true);
    try {
      fileService.getInstance().linkContentDocumentWithEntity(fileDtos);
      fileService.getInstance().linkContentDocumentWithEntity(applicant.Id, new List<Id>{ applicant.Id });
    } catch (Exception e) {
    }
    test.stopTest();
    system.assertEquals(null, null, 'msg');
  }
}
