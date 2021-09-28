String q = new Query(Opportunity.SObjectType)
  .addFields('Name')
  .queryLookup('Account')
  .addFields('Name')
  .run()
  .queryChild('OpportunityLineItems')
  .addFields('Name')
  .run()
  .queryChild('OpportunityContactRoles')
  .addFields()
  .run()
  .enforceFLS()
  .toString(true);
List<Opportunity> sl = (List<Opportunity>) DatabaseUtils.getRecords(q);
system.debug(system.JSON.Serialize(sl));

system.debug(
  Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByName()
    .get('Checking Account')
    .getRecordTypeId()
);

String ciperText = SecurityUtils.encryptUrl('00QN000000AQMNPMA5');
system.debug('ciperText : ' + ciperText);
system.debug(' Decrypted Data : ' + SecurityUtils.decryptUrl(ciperText));

//assign permission set to FI on user creation
FinInstAccountService.assignCommunityPermissionSetAsync('005N000000ALmCFIA1');

system.debug(
  'ciperText : ' +
  FileService.getInstance()
    .fetchContentVersionByIdWithoutBlob('068N0000002BDJzIAO')
);

Map<String, Object> params = new Map<String, Object>{
  'Lead' => new List<String>{ 'LeadSource' }
};
system.debug(
  JSON.Serialize(LWCDealerSiteController.fetchPickListValues(params))
);
