//
system.debug(
  EmailNotificationRepository.fetchEmailTemplateByDevName(
    new Set<string>{ 'TestContact' }
  )
);
//

// #2 using email builder
String inviteUrl =
  SiteSetting__c.getOrgDefaults().OnlineSiteUrl__c +
  '/s/DealerRegistration?id=' +
  SecurityUtils.encryptUrl(leadRecord.id);
EmailNotificationBuilder.newInstance('DealerInvitation', leadRecord.Id)
  .setToAddresses(leadRecord.Email)
  .setSubstitute(new Map<String, String>{ '{{url}}' => inviteUrl })
  .setdocumentNames(
    new List<String>{ 'MintflowLogo', 'DAContent1', 'MintflowLogo' }
  );
List<Messaging.SendEmailResult> result = EmailNotificationBuilder.sendEmail();
if (result != null) {
  if (result[0].success) {
    System.debug('Email sent Successfully');
  } else {
    System.debug('Failed to send Email ');
    throw new customException('email not sent');
  }
}

// #3. Sakesfirce default messaging

//a0d1y000000pBCeAAM  survey
Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
//message.setTargetObjectId(UserInfo.getUserId());
message.setTreatTargetObjectAsRecipient(false);
message.setSenderDisplayName('Company Support');
message.setReplyTo('no-reply@company.com');
message.setUseSignature(false);
message.setBccSender(false);
message.setSaveAsActivity(false);
EmailTemplate emailTemplate = [
  SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
  FROM EmailTemplate
  WHERE name = 'TestContact1'
];
message.setTemplateID(emailTemplate.Id);
message.setWhatId('a0d1y000000pBCeAAM'); //This is important for the merge fields in template to work
message.toAddresses = new List<String>{ 'nithesh.k@digitalalign.com' };

Messaging.SingleEmailMessage emailMessageTemp = Messaging.renderStoredEmailTemplate(
  message.getTemplateId(),
  message.getTargetObjectId(),
  message.getWhatId()
);
message.setSubject(emailMessageTemp.getSubject());
message.setPlainTextBody(emailMessageTemp.getPlainTextBody());
message.setHtmlBody(emailMessageTemp.getHtmlBody());
Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
  message
};
Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
if (results[0].success) {
  System.debug('The email was sent successfully.');
} else {
  System.debug('The email failed to send: ' + results[0].errors[0].message);
}

//#4
ApexRequest request = new ApexRequest();
Application__c application = ApplicationRepository.readApplicationForKYC(
  '0016D00000aYc5zQAC'
);
CustomerEmailService.getInstance().fundingLinkOnKycApproval(application);
Logger.persist();
