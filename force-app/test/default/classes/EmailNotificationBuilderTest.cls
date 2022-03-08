@isTest
public with sharing class EmailNotificationBuilderTest {
  private static Application__c makeAccountData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);
    return acc;
  }

  @isTest
  static void generateDocumentUrlTest() {
    Application__c acc = makeAccountData();
    test.startTest();
    EmailNotificationBuilder.newInstance('OTPVerificationEmail', acc.Id)
      .setToAddresses('test@email.com')
      .setSubstitute(new Map<String, String>{ '{Name}' => 'Name' })
      .setEntityAttachmentIds(new List<Id>{ acc.Id })
      .setBccAddresses('Test@email.com')
      .setCcAddresses('Test@email.com')
      .setBccAddresses(new List<String>{ 'Test@email.com' })
      .setCcAddresses(new List<String>{ 'Test@email.com' })
      .setSubstitute(new Map<string, string>{ 'Name' => 'TestName' });

    EmailNotificationBuilder.newInstance('notificationName')
      .setNotificationName('setNotificationName')
      .setLinkedEntityId(acc.Id)
      .setToAddresses('Test@email.com')
      .setToAddresses(new List<String>{ 'Test@email.com' })
      .setDocumentNames('document')
      .setDocumentNames(new List<String>{ 'documents' });

    EmailNotificationBuilder.sendEmail();
    test.stopTest();
  }
}
