//
system.debug(
  EmailNotificationRepository.fetchEmailTemplateByDevName(
    new Set<string>{ 'TestContact' }
  )
);
//

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
