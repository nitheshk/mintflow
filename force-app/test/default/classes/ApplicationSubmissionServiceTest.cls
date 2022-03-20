@istest
public with sharing class ApplicationSubmissionServiceTest {
  private static Application__c makeApplicationData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);

    Applicant__c applicant = TestData.createApplicant('Primary');
    applicant.Application__c = acc.Id;
    applicant = (Applicant__c) DatabaseUtils.insertRecord(applicant);

    IdentificationDocument__c identity = TestData.createIdentity(null);
    identity.Applicant__c = applicant.Id;
    identity = (IdentificationDocument__c) DatabaseUtils.insertRecord(identity);
    applicant.mflow__IdentificationDocuments__r.addAll(new List<IdentificationDocument__c>{ identity });
    acc.Applicants__r.addAll(new List<Applicant__c>{ applicant });
    return acc;
  }
  @istest
  private static void testOne() {
    Application__c application = makeApplicationData();
    string data = 'data';
    ApplicationSubmissionService.getInstance().submitApplication(data);
  }
}
