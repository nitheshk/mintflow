String applicationId = '0010w00000ndNSUAA2';

List<Id> ids = new List<Id>{ applicationId };

Account result1 = DatabaseUtils.getRecord(
  new Query(Account.SObjectType)
    .addFields()
    .queryChild('dau01__Applicants__r')
    .run()
    .queryChild('FinServ__HouseholdFinancialAccounts__r')
    .run()
    .whereIn('Id', ids)
    .toString(true)
);

system.debug(Json.Serialize(result1));
logger.persist();

List<dau01__Applicant__c> result2 = DatabaseUtils.getRecord(
  new Query(dau01__Applicant__c.SObjectType)
    .addFields()
    .queryChild('dau01__Applicants__r')
    .addFields()
    .run()
    .whereEq('Id', result1.dau01__Applicants__r)
    .toString(true)
);
system.debug(Json.Serialize(result));

//
FinServ__IdentificationDocument__c identity = new FinServ__IdentificationDocument__c();
insert identity;
