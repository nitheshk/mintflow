/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class EmailNotificationBuilder {
  //static context
  private static Map<String, EmailTemplate> emailTemplates = new Map<String, EmailTemplate>();
  private static Map<String, String> documentURL = new Map<String, String>();
  private static Map<String, Id> orgWideEmailAddress = new Map<String, Id>();
  private static List<EmailNotificationBuilder> notificationServices = new List<EmailNotificationBuilder>();
  private static Logger log = Logger.getInstance(EmailNotificationBuilder.class);

  // scoped context
  private String notificationName;
  private Id linkedEntityId;
  private List<String> toAddresses = new List<String>();
  private List<String> ccAddresses = new List<String>();
  private List<String> bccAddresses = new List<String>();
  private Map<String, String> substitute = new Map<String, String>();
  private Set<String> documentNames = new Set<String>();
  private List<Id> entityAttachmentIds = new List<Id>();
  private Map<String, Blob> fileAttachments = new Map<String, Blob>();

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   * @param String notificationName
   **/
  private EmailNotificationBuilder(String notificationName) {
    this.notificationName = notificationName;
  }

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   * @param String notificationName
   * @param Id linkedEntityId
   **/
  private EmailNotificationBuilder(String notificationName, Id linkedEntityId) {
    this.notificationName = notificationName;
    this.linkedEntityId = linkedEntityId;
  }

  /**
   * @description
   * @author Digital Align Team | 08-03-2021
   * @return EmailNotificationBuilder
   **/
  global static EmailNotificationBuilder newInstance(String notificationName) {
    EmailNotificationBuilder notificationService = new EmailNotificationBuilder(notificationName);
    EmailNotificationBuilder.notificationServices.add(notificationService);
    return notificationService;
  }

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   * @param String notificationName
   * @param Id linkedEntityId
   * @return EmailNotificationBuilder
   **/
  global static EmailNotificationBuilder newInstance(String notificationName, Id linkedEntityId) {
    EmailNotificationBuilder notificationService = new EmailNotificationBuilder(notificationName, linkedEntityId);
    EmailNotificationBuilder.notificationServices.add(notificationService);
    return notificationService;
  }

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   * @return List<Messaging.SendEmailResult>
   **/
  global static List<Messaging.SendEmailResult> sendEmail() {
    // build notification service
    List<Messaging.SingleEmailMessage> emailMessages = EmailNotificationBuilder.buildNotificationServices();
    log?.fine('EmailMessages Size :' + emailMessages.size());
    List<Messaging.SendEmailResult> emailResult;
    if (!emailMessages.isEmpty()) {
      emailResult = SObjectWithoutSharing.sendEmail(emailMessages, false);
      //reset values
      emailTemplates = new Map<String, EmailTemplate>();
      documentURL = new Map<String, String>();
      notificationServices = new List<EmailNotificationBuilder>();
    }
    return emailResult;
  }

  /**
   * @description
   * @author Digital Align Team | 08-03-2021
   **/
  @SuppressWarnings('PMD.NcssMethodCount,PMD.CognitiveComplexity')
  global static List<Messaging.SingleEmailMessage> buildNotificationServices() {
    List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
    //get OrgWideEmailAddress
    if (orgWideEmailAddress.isEmpty()) {
      for (OrgWideEmailAddress owa : EmailNotificationRepository.fetchOrgWideEmailAddress()) {
        orgWideEmailAddress.put(owa.DisplayName, owa.Id);
      }
    }
    //get template details
    EmailNotificationBuilder.setEmailTemplates();

    // get document url
    EmailNotificationBuilder.buildDocumentUrl();

    // build single Email message
    for (EmailNotificationBuilder notificationService : EmailNotificationBuilder.notificationServices) {
      EmailNotificationSetting__mdt setting = EmailNotificationSetting__mdt.getInstance(
        notificationService.notificationName
      );
      if (!(setting != null && !setting.mflow__Disabled__c)) {
        continue;
      }
      EmailTemplate emailTemplate = emailTemplates.get(setting.EmailTemplateName__c);

      Messaging.SingleEmailMessage emailMessage = new Messaging.SingleEmailMessage();
      emailMessage.setTargetObjectId(UserInfo.getUserId());
      emailMessage.setTreatTargetObjectAsRecipient(false);
      emailMessage.setWhatId(notificationService.linkedEntityId);
      emailMessage.setTemplateId(emailTemplate.Id);
      emailMessage.setUseSignature(false);

      //replace
      substituteEmailMessage(emailMessage, notificationService.substitute, notificationService.documentNames);

      if (orgWideEmailAddress.containsKey(setting.OrgWideName__c)) {
        emailMessage.setOrgWideEmailAddressId(orgWideEmailAddress.get(setting.OrgWideName__c));
      }

      //Save As Activity
      //Object Should have Track Activities is enabled
      emailMessage.setSaveAsActivity(setting.TraceEmailActivity__c);

      //toAddress
      if (String.isNotBlank(setting.ToAddress__c)) {
        notificationService.toAddresses.addAll(setting.ToAddress__c.split(';'));
      }
      if (!notificationService.toAddresses.isEmpty()) {
        emailMessage.setToAddresses(notificationService.toAddresses);
      }

      //ccAddress
      if (String.isNotBlank(setting.CCEmailAddress__c)) {
        notificationService.ccAddresses.addAll(setting.CCEmailAddress__c.split(';'));
      }
      if (!notificationService.ccAddresses.isEmpty()) {
        emailMessage.setCcAddresses(notificationService.ccAddresses);
      }

      //bccAddress
      if (String.isNotBlank(setting.BCCEmailAddress__c)) {
        notificationService.bccAddresses.addAll(setting.BCCEmailAddress__c.split(';'));
      }
      if (!notificationService.bccAddresses.isEmpty()) {
        emailMessage.setBccAddresses(notificationService.bccAddresses);
      }

      //ReplyToAddress__c
      if (String.isNotBlank(setting.ReplyToAddress__c)) {
        emailMessage.setReplyTo(setting.ReplyToAddress__c);
      }

      //
      if (!notificationService.entityAttachmentIds.isEmpty()) {
        emailMessage.setEntityAttachments(notificationService.entityAttachmentIds);
      }

      if (String.isBlank(emailMessage.getOrgWideEmailAddressId())) {
        emailMessage.setSenderDisplayName(setting.DisplayName__c);
      }

      //build attachements
      buildFileAttachments(emailMessage, notificationService.fileAttachments);

      log?.fine('emailMessage :' + JSON.serialize(emailMessage));
      emailMessages.add(emailMessage);

      // send email;
    }
    return emailMessages;
  }

  /**
   * @description
   * @author Digital Align Team | 08-03-2021
   **/
  private static void setEmailTemplates() {
    for (EmailNotificationBuilder notificationService : EmailNotificationBuilder.notificationServices) {
      EmailNotificationSetting__mdt setting = EmailNotificationSetting__mdt.getInstance(
        notificationService.notificationName
      );
      emailTemplates.put(
        EmailNotificationSetting__mdt.getInstance(notificationService.notificationName)?.EmailTemplateName__c,
        null
      );
    }
    for (EmailTemplate template : EmailNotificationRepository.fetchEmailTemplateByDevName(emailTemplates.keySet())) {
      emailTemplates.put(template.DeveloperName, template);
    }
  }

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   **/
  private static void buildDocumentUrl() {
    Set<String> docuementNameList = new Set<String>();
    for (EmailNotificationBuilder notificationService : EmailNotificationBuilder.notificationServices) {
      for (String documentName : notificationService.documentNames) {
        docuementNameList.add(documentName);
      }
    }
    String baseUrl =
      Url.getSalesforceBaseUrl().getProtocol() +
      '://' +
      System.Url.getSalesforceBaseUrl().getHost().remove('-api') +
      '/servlet/servlet.ImageServer?id={{docID}}' +
      '&oid=' +
      UserInfo.getOrganizationId();
    for (Document doc : EmailNotificationRepository.fetchDocumentByDevName(docuementNameList)) {
      documentURL.put('{{' + doc.DeveloperName + '}}', baseUrl.replace('{{docID}}', doc.Id));
    }
  }
  /**
   * @description reder email template
   * @author Digital Align Team | 08-03-2021
   * @param Messaging.SingleEmailMessage emailMessage
   * @param Map<String String> substitute
   **/
  private static void substituteEmailMessage(
    Messaging.SingleEmailMessage emailMessage,
    Map<String, String> substitute,
    Set<String> documentNames
  ) {
    Messaging.SingleEmailMessage emailMessageTemp = SObjectWithoutSharing.renderStoredEmailTemplate(emailMessage);

    for (String key : substitute.keySet()) {
      if (String.isEmpty(substitute.get(key))) {
        continue;
      }
      emailMessageTemp.setSubject(emailMessageTemp.getSubject().replace(key, substitute.get(key)));
      emailMessageTemp.setPlainTextBody(emailMessageTemp.getPlainTextBody().replace(key, substitute.get(key)));
      emailMessageTemp.setHtmlBody(emailMessageTemp.getHtmlBody().replace(key, substitute.get(key)));
    }

    for (String key : documentNames) {
      String substituteDocumentUrl = '{{' + key + '}}';
      emailMessageTemp.setSubject(
        emailMessageTemp.getSubject().replace(substituteDocumentUrl, documentURL.get(substituteDocumentUrl))
      );
      emailMessageTemp.setPlainTextBody(
        emailMessageTemp.getPlainTextBody().replace(substituteDocumentUrl, documentURL.get(substituteDocumentUrl))
      );
      emailMessageTemp.setHtmlBody(
        emailMessageTemp.getHtmlBody().replace(substituteDocumentUrl, documentURL.get(substituteDocumentUrl))
      );
    }

    emailMessage.setSubject(emailMessageTemp.getSubject());
    emailMessage.setPlainTextBody(emailMessageTemp.getPlainTextBody());
    emailMessage.setHtmlBody(emailMessageTemp.getHtmlBody());
  }

  /**
   * @description
   * @author Digital Align Team | 08-03-2021
   * @param Messaging.SingleEmailMessage emailMessage
   * @param Map<String Blob> fileAttachments
   **/
  private static void buildFileAttachments(
    Messaging.SingleEmailMessage emailMessage,
    Map<String, Blob> fileAttachments
  ) {
    List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
    for (String filename : fileAttachments.keySet()) {
      Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
      attachment.setFileName(filename);
      attachment.setBody(fileAttachments.get(filename));
      attachments.add(attachment);
    }
    emailMessage.setFileAttachments(attachments);
  }

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   * @param String notificationName
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setNotificationName(String notificationName) {
    this.notificationName = notificationName;
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   * @param Id linkedEntityId
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setLinkedEntityId(Id linkedEntityId) {
    this.linkedEntityId = linkedEntityId;
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 08-03-2021
   * @param String toAddress
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setToAddresses(String toAddress) {
    this.toAddresses.add(toAddress);
    return this;
  }
  /**
   * @description
   * @author Digital Align Team | 08-03-2021
   * @param List<String> toAddress
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setToAddresses(List<String> toAddress) {
    this.toAddresses.addAll(toAddresses);
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 08-03-2021
   * @param String ccAddress
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setCcAddresses(String ccAddress) {
    this.ccAddresses.add(ccAddress);
    return this;
  }
  /**
   * @description
   * @author Digital Align Team | 08-03-2021
   * @param List<String> ccAddress
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setCcAddresses(List<String> ccAddress) {
    this.ccAddresses.addAll(ccAddress);
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 08-03-2021
   * @param String bccAddresses
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setBccAddresses(String bccAddresses) {
    this.bccAddresses.add(bccAddresses);
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 08-03-2021
   * @param List<String> bccAddresses
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setBccAddresses(List<String> bccAddresses) {
    this.bccAddresses.addAll(bccAddresses);
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   * @param String documentName
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setDocumentNames(String documentName) {
    this.documentNames.add(documentName);
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   * @param List<String> documentNames
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setDocumentNames(List<String> documentNames) {
    this.documentNames.addAll(documentNames);
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   * @param List<Id> entityAttachmentIds
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setEntityAttachmentIds(List<Id> entityAttachmentIds) {
    this.entityAttachmentIds = entityAttachmentIds;
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   * @param Map<String Blob> fileAttachments
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setFileAttachments(Map<String, Blob> fileAttachments) {
    this.fileAttachments.putAll(fileAttachments);
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 08-04-2021
   * @param Map<String String> substitute
   * @return EmailNotificationBuilder
   **/
  global EmailNotificationBuilder setSubstitute(Map<String, String> substitute) {
    this.substitute.putAll(substitute);
    return this;
  }
}
