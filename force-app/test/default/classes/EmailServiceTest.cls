@istest
public with sharing class EmailServiceTest {
  public static Document makeDocumentData() {
    Document doc = TestData.createDocument();
    doc = (Document) DatabaseUtils.insertRecord(doc);
    return doc;
  }
  @isTest
  static void generateDocumentUrlTest() {
    makeDocumentData();
    test.startTest();
    EmailController emailCon = new EmailController();
    test.stopTest();
  }
}
