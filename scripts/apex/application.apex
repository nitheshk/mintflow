// Application Read Testing

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

FinServ__Revenue__c rv = new FinServ__Revenue__c(
  FinServ__Date__c = Date.Today(),
  FinServ__Amount__c = 10,
  dau01__Applicant__c = result1.dau01__Applicants__r[0].Id
);
insert rv;

// save testing
String js = '{"IsDeleted":false,"Name":"Init 3","RecordTypeId":"0120w0000016fuBAAQ","BillingAddress":null,"ShippingAddress":null,"PhotoUrl":"/services/images/photo/0010w00000ndNSUAA2","Description":"103.157.239.36","OwnerId":"0050w000002ziPxAAI","CreatedDate":"2021-10-22T09:22:22.000+0000","CreatedById":"0050w000002ziPxAAI","LastModifiedDate":"2021-10-22T09:22:22.000+0000","LastModifiedById":"0050w000002ziPxAAI","SystemModstamp":"2021-10-22T09:22:22.000+0000","LastViewedDate":"2021-10-22T17:10:42.000+0000","LastReferencedDate":"2021-10-22T17:10:42.000+0000","IsPartner":false,"IsCustomerPortal":false,"CleanStatus":"Pending","FinServ__AUM__c":0.00,"FinServ__IndividualType__c":"Group","FinServ__Status__c":"Active","FinServ__WalletShare__c":0,"dau01__deleteRecord__c":false,"dau01__Applicants__r":{"totalSize":1,"done":true,"records":[{"OwnerId":"0050w000002zi3VAAQ","IsDeleted":false,"Name":"Applicant 12","CreatedDate":"2021-10-22T12:35:06.000+0000","CreatedById":"0050w000002zi3VAAQ","LastModifiedDate":"2021-10-22T12:35:06.000+0000","LastModifiedById":"0050w000002zi3VAAQ","SystemModstamp":"2021-10-22T12:35:06.000+0000","dau01__Application__c":"0010w00000ndNSUAA2","dau01__FirstName__c":"First Name","dau01__IsEmailVerified__c":false,"dau01__IsExistingCustomer__c":false,"dau01__IsPhoneNumberVerified__c":false,"dau01__LastName__c":"Last Name","dau01__DeleteRecord__c":false}]},"FinServ__HouseholdFinancialAccounts__r":{"totalSize":1,"done":true,"records":[{"attributes":{"type":"FinServ__FinancialAccount__c","url":"/services/data/v53.0/sobjects/FinServ__FinancialAccount__c/a0F0w000001BYMLEA4"},"FinServ__Household__c":"0010w00000ndNSUAA2","Id":"a0F0w000001BYMLEA4"}]}}';
ApexRequest request = new ApexRequest();
request.header = '{}';
Request.data = js;
ApplicationController.saveApplication(request);
