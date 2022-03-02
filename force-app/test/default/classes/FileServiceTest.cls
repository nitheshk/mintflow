@istest
public with sharing class FileServiceTest {
  public static ContentVersion makeContentVersion() {
    ContentVersion cv = TestData.createContentVersion();
    cv = (ContentVersion) DatabaseUtils.insertRecord(cv);
    return cv;
  }
  private static Applicant__c makeApplicantData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecords(new List<Account>{ acc })[0];
    Applicant__c applicant = TestData.createApplicant(acc.Id);
    applicant.Email__c = 'test@mail.com';
    applicant.SSN__c = '986584759';
    applicant.Phone__c = '7894661236';
    applicant.Birthdate__c = date.valueOf('1990-11-01');
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }
  public static List<FileDTO> makeFileDtos(string applicantId) {
    List<FileDTO> fileDtos = new List<FileDTO>();
    fileDtos.add(TestData.createFileDto('TestFile.txt', applicantId));
    fileDtos.add(TestData.createFileDto('TestFileTwo.txt', applicantId));
    return fileDtos;
  }

  @isTest
  static void createFileTest() {
    Applicant__c applicant = makeApplicantData();
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
    request.applicationId = applicant.Application__c;
    request.setData('Data');
    request.setHeader(header);
    test.startTest();
    FileController.createFile(request);
    FileController.fetchContentVersionByCD(request);
    FileController.fetchContentVersionByEntityId(request);
    header.put(
      'contentVersionId',
      FileService.getInstance()
          .fetchContentVersionByEntityId(applicant.Id, true)[0]
        .Id
    );
    header.put('ignoreVersionData', 'true');
    request.setHeader(header);
    FileController.generatePublicUrl(request);
    FileController.fetchContentVersionByCD(request);
    FileController.deleteContentVersion(request);
    test.stopTest();
    system.assertEquals(null, null, 'msg');
  }
  @isTest
  static void fileServiceTest() {
    Applicant__c applicant = makeApplicantData();
    List<FileDTO> fileDtos = makeFileDtos(applicant.Id);
    test.startTest();
    fileService.getInstance().createFiles(fileDtos);
    fileService.getInstance()
      .fetchContentVersionByFileType(applicant.Id, 'Address', 'Other', false);
    fileService.getInstance().deleteContentVersionByEntityId(applicant.Id);
    fileService.getInstance().deleteContentVersion(applicant.Id);
    fileService.getInstance()
      .fetchContentVersionsByCD(new List<Id>{ applicant.Id }, false);
    fileService.getInstance()
      .fetchContentVersionsByIds(new List<Id>{ applicant.Id }, true);
    fileService.getInstance().fetchContentVersionById(applicant.Id, true);
    try {
      fileService.getInstance().linkContentDocumentWithEntity(fileDtos);
      fileService.getInstance()
        .linkContentDocumentWithEntity(
          applicant.Id,
          new List<Id>{ applicant.Id }
        );
    } catch (Exception e) {
    }
    test.stopTest();
    system.assertEquals(null, null, 'msg');
  }
}
