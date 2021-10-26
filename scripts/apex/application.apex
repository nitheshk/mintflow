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

// save testing
String js = '{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","FinServ__TotalAUMPrimaryOwner__c":0.0,"Description":"103.157.239.36","dau01__deleteRecord__c":false,"FinServ__TotalLiabilitiesJointOwner__c":0.0,"LastReferencedDate":"2021-10-26T11:08:36.000+0000","FinServ__TotalNonfinancialAssetsPrimaryOwner__c":0.0,"FinServ__TotalOutstandingCredit__c":0.0,"FinServ__TotalInsuranceJointOwner__c":0.0,"FinServ__TotalFinancialAccounts__c":0.0,"Name":"Init 6","FinServ__TotalInvestmentsPrimaryOwner__c":0.0,"FinServ__TotalBankDepositsPrimaryOwner__c":0.0,"BillingAddress":null,"FinServ__TotalInsurancePrimaryOwner__c":0.0,"CreatedById":"0050w000002zi3VAAQ","OwnerId":"0050w000002ziPxAAI","FinServ__TotalNumberOfFinAccounts__c":0.0,"FinServ__TotalInvestments__c":0.0,"FinServ__AUM__c":0.0,"RecordTypeId":"0120w0000016fuBAAQ","FinServ__Status__c":"Active","FinServ__TotalNonfinancialAssets__c":0.0,"FinServ__TotalLiabilitiesPrimaryOwner__c":0.0,"FinServ__TotalInsurance__c":0.0,"PhotoUrl":"/services/images/photo/0010w00000ndVjdAAE","dau01__Applicants__r":{"totalSize":1,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"dau01__Application__c":"0010w00000ndVjdAAE","dau01__IsEmailVerified__c":false,"dau01__LastName__c":"Last Name","dau01__IsExistingCustomer__c":false,"Name":"Applicant 12","SystemModstamp":"2021-10-26T11:52:55.000+0000","dau01__Employments__r":{"totalSize":1,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"FinServ__Occupation__c":"Sales","FinServ__AnnualIncome__c":23232.0,"LastViewedDate":"2021-10-26T11:46:00.000+0000","LastReferencedDate":"2021-10-26T11:46:00.000+0000","dau01__Applicant__c":"a0b0w00000EYaRJAA1","Name":"Employed","SystemModstamp":"2021-10-26T11:52:55.000+0000","dau01__DeleteRecord__c":false,"OwnerId":"0050w000002zi3VAAQ","CreatedById":"0050w000002zi3VAAQ","FinServ__EmploymentStatus__c":"Employed","CreatedDate":"2021-10-26T11:45:58.000+0000","FinServ__Position__c":"1","LastModifiedById":"0050w000002zi3VAAQ"}]},"dau01__IsPhoneNumberVerified__c":false,"dau01__DeleteRecord__c":false,"OwnerId":"0050w000002zi3VAAQ","CreatedById":"0050w000002zi3VAAQ","dau01__FirstName__c":"First Name","CreatedDate":"2021-10-25T15:08:33.000+0000","dau01__IdentificationDocuments__r":{"totalSize":1,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","FinServ__DocumentType__c":"License","IsDeleted":false,"FinServ__ExpirationDate__c":"2021-10-07","FinServ__IssueDate__c":"2021-10-04","FinServ__DocumentNumber__c":"23432","LastViewedDate":"2021-10-26T08:16:30.000+0000","LastReferencedDate":"2021-10-26T08:16:30.000+0000","dau01__Applicant__c":"a0b0w00000EYaRJAA1","Name":"DOC-000000002","SystemModstamp":"2021-10-26T11:52:55.000+0000","dau01__DeleteRecord__c":false,"OwnerId":"0050w000002zi3VAAQ","CreatedById":"0050w000002zi3VAAQ","CreatedDate":"2021-10-26T08:16:26.000+0000","FinServ__IssuingCountry__c":"United States","LastModifiedById":"0050w000002zi3VAAQ"}]},"dau01__ContactPointAddresses__r":{"totalSize":1,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","dau01__deleteRecord__c":false,"PostalCode":"575017","Latitude":34.34,"UsageType":"Home","dau01__Applicant__c":"a0b0w00000EYaRJAA1","Name":"Nithesh K","dau01__MonthsLivedAtCurrentAddress__c":2.0,"OwnerId":"0050w000002zi3VAAQ","CreatedById":"0050w000002zi3VAAQ","dau01__YearsLivedAtCurrentAddress__c":3.0,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","IsDefault":true,"IsDeleted":false,"City":"Mangalore","Longitude":34.34,"SystemModstamp":"2021-10-26T11:52:55.000+0000","State":"Karnataka","CreatedDate":"2021-10-26T07:54:15.000+0000","IsPrimary":false,"Country":"India","AddressType":"Billing","LastModifiedById":"0050w000002zi3VAAQ"}]},"LastModifiedById":"0050w000002zi3VAAQ","dau01__Revenues__r":{"totalSize":1,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"FinServ__SubType__c":"Transaction","FinServ__Type__c":"Commission","dau01__Applicant__c":"a0b0w00000EYaRJAA1","Name":"REV-000000003","SystemModstamp":"2021-10-26T11:52:55.000+0000","FinServ__Amount__c":10.0,"FinServ__Date__c":"2021-10-26","dau01__DeleteRecord__c":false,"OwnerId":"0050w000002zi3VAAQ","CreatedById":"0050w000002zi3VAAQ","CreatedDate":"2021-10-26T07:43:21.000+0000","LastModifiedById":"0050w000002zi3VAAQ"}]}}]},"FinServ__TotalInvestmentsJointOwner__c":0.0,"FinServ__TotalBankDepositsJointOwner__c":0.0,"IsDeleted":false,"FinServ__WalletShare__c":0.0,"IsCustomerPortal":false,"LastViewedDate":"2021-10-26T11:08:36.000+0000","FinServ__TotalNonfinancialAssetsJointOwner__c":0.0,"FinServ__TotalBankDeposits__c":0.0,"SystemModstamp":"2021-10-26T11:52:55.000+0000","CleanStatus":"Pending","FinServ__TotalAUMJointOwner__c":0.0,"ShippingAddress":null,"FinServ__TotalLiabilities__c":0.0,"CreatedDate":"2021-10-25T15:08:33.000+0000","LastModifiedById":"0050w000002zi3VAAQ","FinServ__IndividualType__c":"Group","IsPartner":false}';
ApexRequest request = new ApexRequest();
request.header = '{}';
Request.data = js;
ApplicationController.saveApplication(request);
