@istest
public with sharing class SentiLinkReportControllerTest {
  public static ContentVersion makeContentVersion() {
    ContentVersion cv = TestData.createContentVersion();
    cv = (ContentVersion) DatabaseUtils.insertRecord(cv);
    return cv;
  }
  private static ContactPointAddress makeContactPointAddress(Id applicantId) {
    ContactPointAddress address = TestData.createContactPointAddress(null);
    address.Applicant__c = applicantId;
    address = (ContactPointAddress) DatabaseUtils.insertRecord(address);
    return address;
  }
  private static ApplicationConfiguration__c makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    appConfig = (ApplicationConfiguration__c) DatabaseUtils.insertRecord(appConfig);
    return appConfig;
  }
  private static Applicant__c makeApplicantData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecords(new List<Application__c>{ acc })[0];
    Applicant__c applicant = TestData.createApplicant(acc.Id);
    applicant.Email__c = 'test@mail.com';
    applicant.SSN__c = '986584759';
    applicant.Phone__c = '7894661236';
    applicant.Birthdate__c = date.valueOf('1990-11-01');
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }
  @istest
  private static void SentiLinkReportControllerTest() {
    Applicant__c applicant = makeApplicantData();
    ApexRequest request = new ApexRequest();
    request.applicationId = applicant.Application__c; //Application__c ID
    ContentVersion cvs = FileService.getInstance()
      .createFile(new FileDTO('SentiLink.json', blob.valueof(TestData.getSentilinkData()), applicant.Id));

    PageReference SentiLinkReportPage = Page.SentiLinkReport;
    Test.setCurrentPage(SentiLinkReportPage);
    // Put Id into the current page Parameters
    ApexPages.currentPage().getParameters().put('id', cvs.contentDocumentId);
    ApexPages.StandardController sc = new ApexPages.StandardController(applicant);
    Test.startTest();
    ApexResponse response = IdentityController.identityVerify(request);
    FileService.getInstance().fetchContentVersionByEntityId(applicant.Id, false);
    SentiLinkReportController sentilink = new SentiLinkReportController();
    sentilink.prefillFraudCheckDetail();
    SentiLinkReportController.fetchReportDetail(applicant.Id);
    test.stopTest();
  }
}
