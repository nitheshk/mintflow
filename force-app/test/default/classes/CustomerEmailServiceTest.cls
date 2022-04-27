@IsTest
public with sharing class CustomerEmailServiceTest {
  public static List<FileDTO> makeFileDtos(string applicantId) {
    List<FileDTO> fileDtos = new List<FileDTO>();
    fileDtos.add(TestData.createFileDto('TestFile.txt', applicantId));
    fileDtos.add(TestData.createFileDto('TestFileTwo.txt', applicantId));
    return fileDtos;
  }
  private static Application__c makeAccountData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  private static List<FinancialProduct__c> makeProducts() {
    List<FinancialProduct__c> products = TestData.createProduct();
    products = (List<FinancialProduct__c>) DatabaseUtils.insertRecords(products);
    return products;
  }
  private static Applicant__c makeApplicantData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecords(new List<Application__c>{ acc })[0];
    Applicant__c applicant = TestData.createApplicant(acc.Id);
    applicant.Email__c = 'test@mail.com';
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }
  private static List<Applicant__c> makeApplicantList(string applicantType) {
    Applicant__c primary = makeApplicantData();
    Id recType = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Primary').getRecordTypeId();
    primary.RecordTypeId = recType;
    Applicant__c familyMember = TestData.createApplicant(primary.Application__c);
    familyMember.Email__c = 'test@mail.com';
    familyMember.ApplicantType__c = applicantType;
    familyMember = (Applicant__c) DatabaseUtils.insertRecord(familyMember);
    return (new List<Applicant__c>{ primary, familyMember });
  }
  private static ApplicationConfiguration__c makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    appConfig = (ApplicationConfiguration__c) DatabaseUtils.insertRecord(appConfig);
    return appConfig;
  }
  private static Applicant__c makeApplicantDataWithoutEmail() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecords(new List<Application__c>{ acc })[0];
    Applicant__c applicant = TestData.createApplicant(acc.Id);
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }

  @IsTest
  private static void validatGeneralEmails() {
    Applicant__c applicant = makeApplicantData();
    makeApplicationConfiguration();
    Test.startTest();
    CustomerEmailService.getInstance().sendEmailOTP(applicant);
    CustomerEmailService.getInstance().savedApplication(applicant);
    CustomerEmailService.getInstance().resumeApplication(applicant);
    CustomerEmailService.getInstance().notifyAboutEmploymentReport(applicant, 'Notify');
    CustomerEmailService.getInstance().uploadIdentityDocument(applicant, 'link');
    // CustomerEmailService.getInstance().accountOpened(applicant, new FinancialAccount__c());
    CustomerEmailService.getInstance().primaryReviewInformationCompleted(applicant);
    Test.stopTest();
    System.assertEquals(0, Limits.getEmailInvocations(), 'success');
  }

  @IsTest
  private static void validatFamilyNotificationEmail() {
    List<Applicant__c> applicants = makeApplicantList('Family Member');
    Test.startTest();
    CustomerEmailService.getInstance().removeJointApplicant(applicants);
    CustomerEmailService.getInstance().notifyFamilyMember(applicants);
    Test.stopTest();
    System.assertEquals(0, Limits.getEmailInvocations(), 'success');
  }
  @IsTest
  private static void validatReviewInformationSubmittedOne() {
    makeApplicationConfiguration();
    List<Applicant__c> applicants = makeApplicantList('Joint');
    List<String> notifications = new List<String>{ 'PrimaryReviewInformationSubmitted', 'JointStartApplication' };
    Test.startTest();
    for (string notificationType : notifications) {
      CustomerEmailService.getInstance().reviewInformationSubmitted(applicants, notificationType);
    }
    Test.stopTest();
    System.assertEquals(0, Limits.getEmailInvocations(), 'success');
  }
  @IsTest
  private static void validateEmailNotSent() {
    Applicant__c applicant = makeApplicantDataWithoutEmail();
    Test.startTest();
    try {
      CustomerEmailService.getInstance().sendEmailOTP(applicant);
    } catch (Exception e) {
      System.assertEquals(e.getMessage(), 'email not sent');
    }
    Test.stopTest();
  }

  @IsTest
  private static void NotificationTest() {
    Applicant__c applicant = makeApplicantData();
    Application__c app = makeAccountData();
    List<FinancialProduct__c> products = makeProducts();
    app.Applicants__r.addAll(makeApplicantList('Primary'));
    makeApplicationConfiguration();
    Test.startTest();

    NotificationService.getInstance()
      .dispatchKycNotification('onExceptionKycReviewSubmit', applicant.Id, 'string', 'string');
    NotificationService.getInstance()
      .dispatchKycNotification('onSuccessKycReviewSubmit', applicant.Id, 'string', 'string');
    NotificationService.getInstance()
      .dispatchKycNotification('onExceptionKycProcess', applicant.Id, 'string', 'string');
    NotificationService.getInstance().dispatchKycNotification('onReviewKycProcess', applicant.Id, 'string', 'string');
    NotificationService.getInstance().dispatchKycNotification('onSuccessKycProcess', applicant.Id, 'string', 'string');
    NotificationService.getInstance().dispatchKycNotification('onManualKycAction', applicant.Id, 'string', 'string');

    NotificationService.getInstance()
      .dispatchSubmitNotification('onApplicationCompleted', applicant.Id, 'string', 'string');
    NotificationService.getInstance()
      .dispatchSubmitNotification('onApplicationFailed', applicant.Id, 'string', 'string');

    NotificationBuilder.chatterLinkMessagePost(applicant.Id, 'string', 'string');
    NotificationBuilder.chatterContentDataPost(applicant.Id, 'string', makeFileDtos(applicant.Id)[0]);
    NotificationBuilder nb = new NotificationBuilder();
    NotificationBuilder.getInstance();

    Test.stopTest();
  }
}
