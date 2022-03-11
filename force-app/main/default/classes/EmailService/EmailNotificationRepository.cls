/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class EmailNotificationRepository extends DatabaseUtils {
  /**
   * @description fetch email templates by Deveploper Name
   * @author Digital Align Team | 08-03-2021
   * @param List<String> emailTemplateNames
   * @return List<EmailTemplate>
   **/
  public static List<EmailTemplate> fetchEmailTemplateByDevName(Set<String> emailTemplateNames) {
    return (List<EmailTemplate>) getRecords(
      Query.newInstance(EmailTemplate.SObjectType)
        .addFields('DeveloperName,Subject,Body,HTMLValue')
        .whereCon('DeveloperName', '={0}')
        .toString(true),
      new List<Object>{ emailTemplateNames }
    );
  }

  /**
   * @description fetch org wide emaill address
   * @author Digital Align Team | 08-03-2021
   * @return List<OrgWideEmailAddress>
   **/
  public static List<OrgWideEmailAddress> fetchOrgWideEmailAddress() {
    return (List<OrgWideEmailAddress>) getRecords(
      Query.newInstance(OrgWideEmailAddress.SObjectType).addFields().toString(true)
    );
  }

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   * @param List<String> documentNames
   * @return Set<Document>
   **/
  public static List<Document> fetchDocumentByDevName(Set<String> documentNames) {
    return (List<Document>) getRecords(
      Query.newInstance(Document.SObjectType)
        .addFields('DeveloperName')
        .whereCon('DeveloperName', '={0}')
        .toString(true),
      new List<Object>{ documentNames }
    );
  }
}
