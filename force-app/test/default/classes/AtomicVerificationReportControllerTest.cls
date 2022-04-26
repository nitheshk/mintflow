@istest
public with sharing class AtomicVerificationReportControllerTest {
  public static ContentVersion makeContentVersion() {
    ContentVersion cv = TestData.createContentVersion();
    cv = (ContentVersion) DatabaseUtils.insertRecord(cv);
    return cv;
  }
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
  @istest
  private static void AtomicReportTest() {
    makeApplicationConfiguration();
    PageReference testPage = Page.error;
    Test.setCurrentPage(testPage);
    testPage.getParameters().put('pid', 'IC001');
    Application__c application = ApplicationService.getInstance().createApplication(new Map<String, String>());
    Applicant__c applicant = createApplicantDataWithChild(application);
    ContentVersion cvs = FileService.getInstance()
      .createFile(
        new FileDTO(
          'AtomicFI Response.txt',
          blob.valueof(TestData.getAtomiFiData()),
          applicant.mflow__Employments__r[0].Id,
          'Employment',
          'AtomicFIResponse'
        )
      );

    PageReference AtomicVerificationReportPage = Page.AtomicVerificationReport;
    Test.setCurrentPage(AtomicVerificationReportPage);
    // Put Id into the current page Parameters
    ApexPages.currentPage().getParameters().put('id', applicant.mflow__Employments__r[0].Id);
    ApexPages.StandardController sc = new ApexPages.StandardController(applicant);
    Test.startTest();
    // AtomicVerificationReportController atomic = new AtomicVerificationReportController();
    AtomicVerificationReportController.getVerifiedData();
    test.stopTest();
  }
}
