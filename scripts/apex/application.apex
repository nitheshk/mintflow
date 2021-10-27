// Application Read Testing

String applicationId = '0010w00000ndVjdAAE';

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

//system.debug('Account : ' + Json.Serialize(result1));

List<dau01__Applicant__c> result2 = (List<dau01__Applicant__c>) DatabaseUtils.getRecords(
  new Query(dau01__Applicant__c.SObjectType)
    .addFields()
    .queryChild('dau01__IdentificationDocuments__r')
    .addFields()
    .run()
    .queryChild('dau01__ContactPointAddresses__r')
    .addFields()
    .removeFields('Address')
    .run()
    .queryChild('dau01__Employments__r')
    .addFields()
    .run()
    .queryChild('dau01__AssetsAndLiabilities__r')
    .addFields()
    .run()
    .queryChild('dau01__Revenues__r')
    .addFields()
    .run()
    .whereIn('Id', result1.dau01__Applicants__r)
    .toString()
);
//system.debug('Applicant : ' + Json.Serialize(result2));

dau01.SObjectConstructor construct = dau01.SObjectConstructor.getInstance(
  result1
);
construct.setChildObjects('dau01__Applicants__r', result2);
result1 = (Account) construct.build();
system.debug('Full Json : ' + Json.Serialize(result1));

logger.persist();

/// manuall insert
FinServ__Revenue__c rv = new FinServ__Revenue__c(
  FinServ__Date__c = Date.Today(),
  FinServ__Amount__c = 10,
  dau01__Applicant__c = 'a0b0w00000EYaRJAA1'
);
insert rv;

String js = '{"dau01__deleteRecord__c":false,"PostalCode":"575017","UsageType":"Home","dau01__Applicant__c":"a0b0w00000EYaRJAA1","Name":"Nithesh K","dau01__MonthsLivedAtCurrentAddress__c":2.0,"dau01__YearsLivedAtCurrentAddress__c":3.0,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","IsDefault":true,"IsDeleted":false,"City":"Mangalore","State":"Karnataka","IsPrimary":false,"Country":"India","AddressType":"Billing","Latitude":"34.34","Longitude":"34.34"}';
ContactPointAddress c = (ContactPointAddress) JSON.deserialize(
  js,
  ContactPointAddress.class
);
system.debug('Full Json : ' + Json.Serialize(c));
insert c;
