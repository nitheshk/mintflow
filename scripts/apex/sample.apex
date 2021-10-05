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

///

Account applicationObj = new Account();
applicationObj.Name = 'Init';
applicationObj.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
  Account.SObjectType,
  'Application'
);
ApplicationRepository.upsertRecord(applicationObj);

// create person Account
Account personAccountObj = new Account();
personAccountObj.FirstName = 'Test1';
personAccountObj.LastName = 'Test1';
personAccountObj.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
  Account.SObjectType,
  'PersonAccount'
);
ApplicationRepository.upsertRecord(personAccountObj);

Account pc = [
  SELECT id, FirstName, LastName, RecordTypeId, PersonContactId
  FROM Account
  WHERE id = :personAccountObj.id
];

//AccountContactRelation
AccountContactRelation primaryRelationObj = new AccountContactRelation();
primaryRelationObj.AccountId = applicationObj.Id;
primaryRelationObj.ContactId = pc.PersonContactId;
primaryRelationObj.FinServ__Primary__c = true;
primaryRelationObj.FinServ__PrimaryGroup__c = true;
primaryRelationObj.FinServ__Rollups__c = 'All';
primaryRelationObj.Roles = '	Business User';
ApplicationRepository.upsertRecord(primaryRelationObj);

///

String q = new Query(Account.SObjectType)
  .addFields()
  .queryChild('AccountContactRelations')
  .addFields()
  .queryLookup('Contact')
  .addFields()
  .removeFields('AccountId,CleanStatus')
  .run()
  .run()
  .whereEq('Name', 'Init')
  .toString(true);
List<Account> sl = (List<Account>) DatabaseUtils.getRecords(q);
//system.debug('all : ' + system.JSON.Serialize(sl));

Contact employeeContactObj = sl[0].AccountContactRelations[0].Contact;
//system.debug(' employeeContactObj: ' + system.JSON.Serialize(employeeContactObj));

update employeeContactObj;
