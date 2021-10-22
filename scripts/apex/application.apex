String applicationId = '0010w00000ndNSUAA2';

List<Id> ids = new List<Id>{ applicationId };

Account result1 = (Account) DatabaseUtils.getRecord(
  new Query(Account.SObjectType)
    .addFields()
    .queryChild('dau01__Applicants__r')
    .run()
    .queryChild('FinServ__HouseholdFinancialAccounts__r')
    .run()
    .whereIn('Id', ids)
    .toString()
);

system.debug('Account : ' + Json.Serialize(result1));

List<dau01__Applicant__c> result2 = (List<dau01__Applicant__c>) DatabaseUtils.getRecords(
  new Query(dau01__Applicant__c.SObjectType)
    .addFields()
    .queryChild('dau01__IdentificationDocuments__r')
    .addFields()
    .run()
    .whereIn('Id', result1.dau01__Applicants__r)
    .toString()
);
system.debug('Applicant : ' + Json.Serialize(result2));

dau01.SObjectConstructor construct = dau01.SObjectConstructor.getInstance(
  result1
);
construct.setChildObjects('dau01__Applicants__r', result2);
result1 = (Account) construct.build();
system.debug('Full Json : ' + Json.Serialize(result1));

logger.persist();
