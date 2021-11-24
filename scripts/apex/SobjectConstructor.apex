// constructor
String accountJson = '{"attributes":{"type":"Account","url":"/services/data/v52.0/sobjects/Account/0011y00000NMYupAAH"},"Name":"Init","Id":"0011y00000NMYupAAH"}';
String accountRelJson = '[{"attributes":{"type":"AccountContactRelation","url":"/services/data/v52.0/sobjects/AccountContactRelation/07k1y000004B9LYAA0"},"AccountId":"0011y00000NMYupAAH","Id":"07k1y000004B9LYAA0","ContactId":"0031y00000HkuwgAAB","Roles":"Business User","IsDirect":false,"IsActive":true,"StartDate":"2021-10-06","IsDeleted":false,"FinServ__IncludeInGroup__c":false,"FinServ__PrimaryGroup__c":true,"FinServ__Primary__c":true,"FinServ__Rollups__c":"All"}]';

Account acc = (Account) JSON.deserialize(accountJson, Account.class);
List<AccountContactRelation> accRel = (List<AccountContactRelation>) JSON.deserialize(
  accountRelJson,
  List<AccountContactRelation>.class
);

Map<String, Object> mp = (Map<String, Object>) JSON.deserializeUntyped(
  Json.Serialize(acc)
);
mp.put(
  'AccountContactRelations',
  new Map<String, Object>{
    'totalSize' => accRel.size(),
    'done' => true,
    'records' => accRel
  }
);

system.debug('val : ' + mp.get('Name'));
acc = (Account) JSON.deserialize(Json.Serialize(mp), Account.class);
system.debug('acc : ' + JSON.Serialize(acc));

// #3

String accountJson = '{"attributes":{"type":"Account","url":"/services/data/v52.0/sobjects/Account/0011y00000NMYupAAH"},"Name":"Init","Id":"0011y00000NMYupAAH"}';
String accountRelJson = '[{"attributes":{"type":"AccountContactRelation","url":"/services/data/v52.0/sobjects/AccountContactRelation/07k1y000004B9LYAA0"},"AccountId":"0011y00000NMYupAAH","Id":"07k1y000004B9LYAA0","ContactId":"0031y00000HkuwgAAB","Roles":"Business User","IsDirect":false,"IsActive":true,"StartDate":"2021-10-06","IsDeleted":false,"FinServ__IncludeInGroup__c":false,"FinServ__PrimaryGroup__c":true,"FinServ__Primary__c":true,"FinServ__Rollups__c":"All"}]';

Account acc = (Account) JSON.deserialize(accountJson, Account.class);
List<AccountContactRelation> accRel = (List<AccountContactRelation>) JSON.deserialize(
  accountRelJson,
  List<AccountContactRelation>.class
);

Account acc1 = (Account) SObjectConstructor.getInstance(acc)
  .addChildObjects('AccountContactRelations', accRel)
  .build();
system.debug('acc : ' + JSON.Serialize(acc1));

// #4
String q = new Query(Account.SObjectType)
  .addFields('Name')
  .queryChild('FinServ__HouseholdFinancialAccounts__r')
  .addFields('FinServ__PrimaryOwner__r.PersonContactId')
  .run()
  .whereEq('Name', 'Init')
  .toString();

List<Account> sl1 = (List<Account>) DatabaseUtils.getRecords(q);

String pa = sl1[0]
  .FinServ__HouseholdFinancialAccounts__r[0]
  .FinServ__PrimaryOwner__c;

q = new Query(Account.SObjectType)
  .addFields()
  .queryChild('FinServ__Employment__pr')
  .addFields()
  .run()
  .whereEq('Id', pa)
  .andCon()
  .whereEq('isPersonAccount ', true)
  .toString();

List<Account> sl2 = (List<Account>) DatabaseUtils.getRecords(q);

FinServ__FinancialAccount__c fa = (FinServ__FinancialAccount__c) SObjectConstructor.getInstance(
    sl1[0].FinServ__HouseholdFinancialAccounts__r[0]
  )
  .setLookupObject('FinServ__PrimaryOwner__r', sl2[0])
  .build();

Account acc = (Account) SObjectConstructor.getInstance(sl1[0])
  .setChildObject('FinServ__HouseholdFinancialAccounts__r', fa)
  .build();

system.debug('acc : ' + JSON.Serialize(acc));

// #1

String str = '{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","FinServ__TotalAUMPrimaryOwner__c":0.0,"Description":"103.157.239.36","dau01__deleteRecord__c":false,"Name":"Init 6","FinServ__TotalInsurance__c":0.0,"PhotoUrl":"/services/images/photo/0010w00000ndVjdAAE","dau01__Applicants__r":[{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"dau01__Application__c":"0010w00000ndVjdAAE","dau01__IsEmailVerified__c":false,"dau01__LastName__c":"Last Name","dau01__IsExistingCustomer__c":false,"Name":"Applicant 12","SystemModstamp":"2021-10-26T11:52:55.000+0000","dau01__IsPhoneNumberVerified__c":false,"dau01__DeleteRecord__c":false,"OwnerId":"0050w000002zi3VAAQ","CreatedById":"0050w000002zi3VAAQ","dau01__FirstName__c":"First Name","CreatedDate":"2021-10-25T15:08:33.000+0000","LastModifiedById":"0050w000002zi3VAAQ"}],"FinServ__TotalInvestmentsJointOwner__c":0.0,"FinServ__TotalBankDepositsJointOwner__c":0.0,"CreatedDate":"2021-10-25T15:08:33.000+0000","LastModifiedById":"0050w000002zi3VAAQ","FinServ__IndividualType__c":"Group","IsPartner":false}';
JSONParser parser = JSON.createParser(str);
Account acc = (Account) parser.readValueAs(Account.class);

String str = '[{"Id":"a0b0p0000026k4GAAQ","OwnerId":"0050p0000037Li8AAE","IsDeleted":false,"Name":"Nithesh K","RecordTypeId":"0120p0000018FOzAAM","CreatedDate":1637605789000,"CreatedById":"0050p0000037Li8AAE","LastModifiedDate":1637605789000,"LastModifiedById":"0050p0000037Li8AAE","SystemModstamp":1637605789000,"LastViewedDate":1637605789000,"LastReferencedDate":1637605789000,"dau01__ApplicantNumber__c":"A-0057","dau01__ApplicantType__c":"Family Member","dau01__Application__c":"0010p000011ATBbAAO","dau01__DeleteRecord__c":false,"dau01__Email__c":"nitheshk.hero@gmail.com","dau01__FirstName__c":"Nithesh","dau01__IsEmailVerified__c":false,"dau01__IsExistingCustomer__c":false,"dau01__IsPhoneNumberVerified__c":false,"dau01__LastName__c":"K","dau01__Phone__c":"08147666960","dau01__Relationship__c":"Mother","dau01__ContactPointAddresses__r":{"totalSize":1"done":true,"records":"[{"dau01__Applicant__c":"a0b0p0000026k4GAAQ","Id":"8lW0p00000003W3EAI","OwnerId":"0050p0000037Li8AAE","IsDeleted":false,"Name":"Amrutha nilaya, Kerebail Gudde","CreatedDate":1637605789000,"CreatedById":"0050p0000037Li8AAE","LastModifiedDate":1637605789000,"LastModifiedById":"0050p0000037Li8AAE","SystemModstamp":1637605789000,"LastViewedDate":1637605789000,"LastReferencedDate":1637605789000,"IsPrimary":false,"Street":"Amrutha nilaya, Kerebail Gudde","City":"Mangalore","State":"Karnataka","PostalCode":"575017","Country":"India","IsDefault":false,"dau01__DeleteRecord__c":false}]"}}]';
List<Applicant__c> apl = (List<Applicant__c>) Json.deserialize(
  str,
  Applicant__c.class
);

// #2
String JSONContent = '{"firstName":"John"}';
JSONParser parser = JSON.createParser(JSONContent);
// Advance to the start object marker.
String val = parser.getText();
String fieldName = parser.getCurrentName();
//JSONToken fieldType = parser.nextValue();
JSONToken ct = parser.getCurrentToken();
system.debug('Val :' + val);
//system.debug('fieldType :' + fieldType);
system.debug('fieldName :' + fieldName);
system.debug('ct :' + ct);

JSONToken v1 = parser.nextToken();

val = parser.getText();
fieldName = parser.getCurrentName();
ct = parser.getCurrentToken();
//fieldType = parser.nextValue();
system.debug('Val :' + val);
//system.debug('fieldType :' + fieldType);
system.debug('fieldName :' + fieldName);
system.debug('ct :' + ct);
// Advance to the next value.
JSONToken v2 = parser.nextToken();

val = parser.getText();
fieldName = parser.getCurrentName();
ct = parser.getCurrentToken();
//fieldType = parser.nextValue();
system.debug('Val :' + val);
//system.debug('fieldType :' + fieldType);
system.debug('fieldName :' + fieldName);
system.debug('ct :' + ct);

// #3
String jsonBody = '{"LastModifiedDate":"2021-11-23T04:28:08.000+0000","FinServ__TotalFinAcctsJointOwner__c":12.0,"FinServ__TotalAUMPrimaryOwner__c":0.0,"FinServ__TotalOutstandingCredit__c":0.0,"FinServ__TotalFinancialAccounts__c":0.0,"Name":"app","dau01__isMemberFlow__c":false,"FinServ__TotalBankDepositsPrimaryOwner__c":0.0,"CreatedById":"0056D000004X8ttQAC","FinServ__TotalNumberOfFinAccounts__c":0.0,"FinServ__BranchCode__c":"002","dau01__FlowState__c":"Final-Confirmation","FinServ__TotalNonfinancialAssets__c":2300.0,"FinServ__TotalLiabilitiesPrimaryOwner__c":3700.0,"FinServ__TotalInsurance__c":0.0,"PhotoUrl":"/services/images/photo/0016D00000YF0YjQAL","dau01__UserAccountType__c":"CustomerApplication","FinServ__TotalFinAcctsPrimaryOwner__c":0.0,"dau01__Applicants__r":[{"dau01__Birthdate__c":"1990-11-01","LastModifiedDate":"2021-11-16T12:05:51.000+0000","dau01__OTPExpireTime__c":"2021-11-16T20:00:00.000+0000","dau01__CustomerNumber__c":"345654","dau01__MiddleName__c":"d","dau01__Order__c":1.0,"dau01__Phone__c":"6789876567","dau01__SentiLinkRemarks__c":"SentiLink fraud screw: 650","dau01__IsEmailVerified__c":true,"dau01__IdentityVerificationStatus__c":"Verified","LastReferencedDate":"2021-11-23T04:21:20.000+0000","dau01__FraudStatus__c":"Less","dau01__IsExistingCustomer__c":false,"Name":"john doe","dau01__Employments__r":[{"LastModifiedDate":"2021-11-17T16:44:56.000+0000","dau01__Order__c":1.0,"LastReferencedDate":"2021-11-17T16:44:56.000+0000","dau01__Applicant__c":"a0b6D0000021xS0QAI","Name":"DA","dau01__EmploymentVerificationType__c":"Manual","OwnerId":"0056D000004X8ttQAC","CreatedById":"0056D000004X8ttQAC","FinServ__Position__c":"Lead","dau01__DocumentType__c":"W2","dau01__PayGrade__c":"For Goverment/DOD","dau01__IncomeType__c":"Interest","IsDeleted":false,"dau01__EmploymentDuration__c":5.0,"LastViewedDate":"2021-11-17T16:44:56.000+0000","dau01__EmploymentType__c":"Current","dau01__GrossMonthlySalary__c":5000.0,"SystemModstamp":"2021-11-17T16:44:56.000+0000","dau01__PayCycle__c":"Bi-Weekly","dau01__DeleteRecord__c":false,"FinServ__EmploymentStatus__c":"Employed","CreatedDate":"2021-11-15T13:34:29.000+0000","Id":"a0A6D000004FGvZUAW","LastModifiedById":"0056D000004X8ttQAC"}],"dau01__IsPhoneNumberVerified__c":true,"dau01__SentiLinkStatus__c":"Passsed","OwnerId":"0056D000004X8ttQAC","CreatedById":"0056D000004X8ttQAC","dau01__Email__c":"qa@digitalalign.com","dau01__FirstName__c":"john","RecordTypeId":"0126D000001ukXIQAY","dau01__ApplicantNumber__c":"A-0001","dau01__IdentificationDocuments__r":[{"attributes":{"type":"FinServ__IdentificationDocument__c","url":"/services/data/v53.0/sobjects/FinServ__IdentificationDocument__c/a0I6D000003iY3rUAE"},"LastModifiedDate":"2021-11-16T12:09:30.000+0000","FinServ__DocumentType__c":"License","dau01__Order__c":1.0,"LastReferencedDate":"2021-11-19T12:48:35.000+0000","dau01__Applicant__c":"a0b6D0000021xS0QAI","Name":"DOC-000000000","OwnerId":"0056D000004X8ttQAC","CreatedById":"0056D000004X8ttQAC","dau01__IssuedRegion__c":"New york","FinServ__IssuingCountry__c":"United States","dau01__Height__c":"5.4","IsDeleted":false,"FinServ__ExpirationDate__c":"2027-11-10","FinServ__IssueDate__c":"2010-11-03","FinServ__DocumentNumber__c":"DL-009","LastViewedDate":"2021-11-19T12:48:35.000+0000","SystemModstamp":"2021-11-16T12:09:30.000+0000","dau01__DeleteRecord__c":false,"dau01__Weight__c":"69","CreatedDate":"2021-11-15T13:33:51.000+0000","Id":"a0I6D000003iY3rUAE","dau01__Nationality__c":"USA","LastModifiedById":"0056D000004X8ttQAC","dau01__Gender__c":"Male"}],"dau01__CreditScore__c":120.0,"dau01__EmailOtp__c":"1234","dau01__AssetsAndLiabilities__r":[{"LastModifiedDate":"2021-11-16T12:19:05.000+0000","IsDeleted":false,"FinServ__OwnerType__c":"0016D00000YF0YjQAL","FinServ__Ownership__c":"Individual","dau01__Order__c":1.0,"LastViewedDate":"2021-11-16T12:19:05.000+0000","LastReferencedDate":"2021-11-16T12:19:05.000+0000","FinServ__PrimaryOwner__c":"0016D00000YF0YjQAL","dau01__Applicant__c":"a0b6D0000021xS0QAI","Name":"car","SystemModstamp":"2021-11-16T12:19:05.000+0000","FinServ__Amount__c":2500.0,"dau01__DeleteRecord__c":false,"OwnerId":"0056D000004X8ttQAC","CreatedById":"0056D000004X8ttQAC","RecordTypeId":"0126D000001ukNUQAY","CreatedDate":"2021-11-15T13:36:01.000+0000","FinServ__AssetsAndLiabilitiesSource__c":"Manual Entry","Id":"a036D000005cafpQAA","FinServ__AssetsAndLiabilitiesType__c":"Other","LastModifiedById":"0056D000004X8ttQAC"}],"dau01__ApplicantType__c":"Primary","dau01__SentiLinkFraudScore__c":650.0,"IsDeleted":false,"dau01__KYCStatus__c":"Passed","dau01__IncomeVerificationStatus__c":"Approved","dau01__Application__c":"0016D00000YF0YjQAL","LastViewedDate":"2021-11-23T04:21:20.000+0000","dau01__LastName__c":"Doe","SystemModstamp":"2021-11-16T12:05:51.000+0000","dau01__DeleteRecord__c":false,"dau01__SSN__c":"569863215","dau01__SmsOtp__c":"5678","CreatedDate":"2021-11-15T06:28:09.000+0000","dau01__EmploymentStatus__c":"Manual","dau01__MembershipAccountNumber__c":"3453452","Id":"a0b6D0000021xS0QAI","dau01__ContactPointAddresses__r":[{"IsDefault":false,"LastModifiedDate":"2021-11-16T12:11:48.000+0000","IsDeleted":false,"dau01__Order__c":1.0,"LastViewedDate":"2021-11-19T12:01:36.000+0000","PostalCode":"34323","LastReferencedDate":"2021-11-19T12:01:36.000+0000","City":"CA","dau01__Applicant__c":"a0b6D0000021xS0QAI","Name":"00101","SystemModstamp":"2021-11-16T12:11:48.000+0000","dau01__DeleteRecord__c":false,"OwnerId":"0056D000004X8ttQAC","CreatedById":"0056D000004X8ttQAC","State":"karnataka","CreatedDate":"2021-11-15T06:29:14.000+0000","IsPrimary":true,"Street":"street one","Country":"India","Id":"8lW6D00000000gEUAQ","AddressType":"Primary","LastModifiedById":"0056D000004X8ttQAC"},{"IsDefault":false,"LastModifiedDate":"2021-11-16T12:11:58.000+0000","IsDeleted":false,"dau01__Order__c":2.0,"LastViewedDate":"2021-11-16T12:18:56.000+0000","PostalCode":"34323","LastReferencedDate":"2021-11-16T12:18:56.000+0000","City":"CA","dau01__Applicant__c":"a0b6D0000021xS0QAI","Name":"002","SystemModstamp":"2021-11-16T12:11:58.000+0000","dau01__DeleteRecord__c":false,"OwnerId":"0056D000004X8ttQAC","CreatedById":"0056D000004X8ttQAC","State":"karnataka","CreatedDate":"2021-11-15T13:32:48.000+0000","IsPrimary":false,"Street":"street one","Country":"India","Id":"8lW6D00000000gJUAQ","AddressType":"Document","LastModifiedById":"0056D000004X8ttQAC"}],"LastModifiedById":"0056D000004X8ttQAC","dau01__Revenues__r":[{"LastModifiedDate":"2021-11-16T12:07:56.000+0000","IsDeleted":false,"dau01__Order__c":1.0,"FinServ__SubType__c":"Transaction","FinServ__Type__c":"Fees","FinServ__FinancialAccount__c":"a0F6D0000021osMUAQ","dau01__Applicant__c":"a0b6D0000021xS0QAI","Name":"REV-000000000","SystemModstamp":"2021-11-16T12:07:56.000+0000","FinServ__Amount__c":2500.0,"FinServ__Date__c":"2019-11-06","dau01__DeleteRecord__c":false,"OwnerId":"0056D000004X8ttQAC","CreatedById":"0056D000004X8ttQAC","CreatedDate":"2021-11-15T13:35:34.000+0000","Id":"a0T6D000000bOA8UAM","LastModifiedById":"0056D000004X8ttQAC"}]}],"dau01__SubmittedDate__c":"2021-11-12","FinServ__TotalInvestmentsJointOwner__c":0.0,"IsDeleted":false,"LastViewedDate":"2021-11-23T04:24:28.000+0000","FinServ__LastUsedChannel__c":"Virtual","dau01__SubmittedBy__c":"0056D000004X8ttQAC","dau01__DeleteRecord__c":false,"CleanStatus":"Pending","FinServ__TotalHeldFinAcctsPrimaryOwner__c":0.0,"FinServ__TotalLiabilities__c":3700.0,"CreatedDate":"2021-11-15T06:32:06.000+0000","dau01__SessionToken__c":"pyh8mYAVjrnj1iy5gF7JFONvS2ENRY3tJ2dmX4xaGrQI5UocCs6vDdn+29DOt2o0fQ13t4/q/5Kp7EF51J0PUjjk4DVbwTOb9Qtm21ov1bpoFEMuOBEnF6rFMrZ09joFp0UpNbsswsoMjIQ7x1qx0aJQOMIPnw3PgA4Qe5xTFCk=","Id":"0016D00000YF0YjQAL","IsPartner":false,"FinServ__TotalLiabilitiesJointOwner__c":0.0,"LastReferencedDate":"2021-11-23T04:24:28.000+0000","FinServ__TotalNonfinancialAssetsPrimaryOwner__c":2300.0,"dau01__SubStatus__c":"Verified","FinServ__TotalInsuranceJointOwner__c":0.0,"FinServ__TotalInvestmentsPrimaryOwner__c":0.0,"BillingAddress":null,"dau01__IPAddress__c":"59.90.16.140","FinServ__TotalInsurancePrimaryOwner__c":0.0,"OwnerId":"0056D000004X8ttQAC","dau01__ApplicationNumber__c":"App-0001","FinServ__TotalInvestments__c":0.0,"FinServ__AUM__c":0.0,"RecordTypeId":"0126D000001ukXDQAY","FinServ__Status__c":"Completed","FinServ__TotalBankDepositsJointOwner__c":0.0,"FinServ__TotalHeldFinAcctsJointOwner__c":0.0,"FinServ__WalletShare__c":0.0,"IsCustomerPortal":false,"FinServ__CustomerType__c":"Consumer","FinServ__TotalNonfinancialAssetsJointOwner__c":0.0,"dau01__IsCountyEligible__c":true,"FinServ__TotalBankDeposits__c":0.0,"SystemModstamp":"2021-11-23T04:28:08.000+0000","FinServ__BranchName__c":"Manhattan","dau01__Version__c":"0.1","FinServ__TotalAUMJointOwner__c":0.0,"ShippingAddress":null,"dau01__CreatedChannel__c":"Virtual","LastModifiedById":"0056D000004X8ttQAC","FinServ__IndividualType__c":"Group"}';
Account acc = (Account) SObjectConstructor.deserialize(
  jsonBody,
  Account.class
);
system.debug('name : ' + acc.name);
system.debug('name : ' + acc.LastModifiedDate);
system.debug('name : ' + acc.dau01__Applicants__r.size());

//Map<String,Object> sMap=acc.getPopulatedFieldsAsMap();
jsonBody = SObjectConstructor.serialize(new List<Account>{ acc });
system.debug('result  : ' + jsonBody);

List<Account> accs = (List<Account>) SObjectConstructor.deserialize(
  jsonBody,
  List<Account>.class
);
