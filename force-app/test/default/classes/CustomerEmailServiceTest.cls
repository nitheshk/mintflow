@IsTest
public with sharing class CustomerEmailServiceTest {
  private static Applicant__c makeApplicantData() {
    Application__c acc = TestData.createAccount();
    acc = (Application__c) DatabaseUtils.insertRecords(
      new List<Application__c>{ acc }
    )[0];
    Applicant__c applicant = TestData.createApplicant(acc.Id);
    applicant.Email__c = 'test@mail.com';
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }
  private static List<Applicant__c> makeApplicantList(string applicantType) {
    Applicant__c primary = makeApplicantData();
    Applicant__c familyMember = TestData.createApplicant(
      primary.Application__c
    );
    familyMember.Email__c = 'test@mail.com';
    familyMember.ApplicantType__c = applicantType;
    familyMember = (Applicant__c) DatabaseUtils.insertRecord(familyMember);
    return (new List<Applicant__c>{ primary, familyMember });
  }
  private static ApplicationConfiguration__c makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    appConfig = (ApplicationConfiguration__c) DatabaseUtils.insertRecord(
      appConfig
    );
    return appConfig;
  }
  private static Applicant__c makeApplicantDataWithoutEmail() {
    Application__c acc = TestData.createAccount();
    acc = (Application__c) DatabaseUtils.insertRecords(
      new List<Application__c>{ acc }
    )[0];
    Applicant__c applicant = TestData.createApplicant(acc.Id);
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);
    return applicant;
  }

  @IsTest
  private static void validatGeneralEmails() {
    Applicant__c applicant = makeApplicantData();
    Test.startTest();
    CustomerEmailService.getInstance().sendEmailOTP(applicant);
    CustomerEmailService.getInstance().resumeApplication(applicant);
    CustomerEmailService.getInstance()
      .accountOpened(applicant, new FinancialAccount__c());
    CustomerEmailService.getInstance()
      .primaryReviewInformationCompleted(applicant);
    Test.stopTest();
    System.assertEquals(0, Limits.getEmailInvocations(), 'success');
  }

  @IsTest
  private static void validatFamilyNotificationEmail() {
    List<Applicant__c> applicants = makeApplicantList('Family Member');
    Test.startTest();
    CustomerEmailService.getInstance().notifyFamilyMember(applicants);
    Test.stopTest();
    System.assertEquals(0, Limits.getEmailInvocations(), 'success');
  }
  @IsTest
  private static void validatReviewInformationSubmittedOne() {
    makeApplicationConfiguration();
    List<Applicant__c> applicants = makeApplicantList('Joint');
    List<String> notifications = new List<String>{
      'PrimaryReviewInformationSubmitted',
      'JointStartApplication'
    };
    Test.startTest();
    for (string notificationType : notifications) {
      CustomerEmailService.getInstance()
        .reviewInformationSubmitted(applicants, notificationType);
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
}
