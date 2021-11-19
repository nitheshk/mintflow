// #1 calling read method
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000010fl06AAA',
  'a0b0p0000026aUnAAI',
  'Joint',
  'ApplicationFlow'
);
//request.applicationId = '0010p000010fl06AAA';
ApexResponse res = ApplicationController.readApplicationWithChild(request);
system.debug('Full Json : ' + res.data);

// #2 Save application

String js = '{"Name":"App-00343","LastModifiedDate":"2021-11-10T07:59:52.000+0000","FinServ__TotalAUMPrimaryOwner__c":0.0,"Description":"103.157.239.36","FinServ__HouseholdFinancialAccounts__r":{"totalSize":0,"done":true,"records":[]},"FinServ__TotalLiabilitiesJointOwner__c":0.0,"LastReferencedDate":"2021-11-10T08:27:41.000+0000","FinServ__TotalNonfinancialAssetsPrimaryOwner__c":0.0,"FinServ__TotalOutstandingCredit__c":0.0,"FinServ__TotalInsuranceJointOwner__c":0.0,"FinServ__TotalFinancialAccounts__c":0.0,"FinServ__TotalInvestmentsPrimaryOwner__c":0.0,"FinServ__TotalBankDepositsPrimaryOwner__c":0.0,"BillingAddress":null,"FinServ__TotalInsurancePrimaryOwner__c":0.0,"FinServ__TotalNumberOfFinAccounts__c":0.0,"FinServ__TotalInvestments__c":0.0,"FinServ__AUM__c":0.0,"FinServ__Status__c":"Active","FinServ__TotalNonfinancialAssets__c":0.0,"FinServ__TotalLiabilitiesPrimaryOwner__c":0.0,"FinServ__TotalInsurance__c":0.0,"dau01__Applicants__r":{"totalSize":3,"done":true,"records":[{"LastModifiedDate":"2021-11-10T07:59:52.000+0000","IsDeleted":false,"dau01__IsEmailVerified__c":false,"dau01__LastName__c":"Last Name","dau01__IsExistingCustomer__c":false,"Name":"First Name Last Name","dau01__Employments__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-11-10T07:59:52.000+0000","IsDeleted":false,"FinServ__Occupation__c":"Sales","FinServ__AnnualIncome__c":23232.0,"Name":"Employed","dau01__DeleteRecord__c":false,"FinServ__EmploymentStatus__c":"Employed","CreatedDate":"2021-11-10T07:59:52.000+0000","FinServ__Position__c":"1"}]},"dau01__DeleteRecord__c":false,"dau01__IsPhoneNumberVerified__c":false,"dau01__FirstName__c":"First Name","CreatedDate":"2021-11-10T07:59:52.000+0000","dau01__ApplicantNumber__c":"A-0009","dau01__IdentificationDocuments__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-11-10T07:59:52.000+0000","FinServ__DocumentType__c":"License","IsDeleted":false,"FinServ__ExpirationDate__c":"2021-10-07","FinServ__IssueDate__c":"2021-10-04","FinServ__DocumentNumber__c":"23432","Name":"DOC-000000018","SystemModstamp":"2021-11-10T07:59:52.000+0000","dau01__DeleteRecord__c":false,"FinServ__IssuingCountry__c":"United States"}]},"dau01__ContactPointAddresses__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-11-10T07:59:52.000+0000","PostalCode":"575017","Latitude":34.34,"UsageType":"Home","Name":"Nithesh K","dau01__MonthsLivedAtCurrentAddress__c":2.0,"dau01__YearsLivedAtCurrentAddress__c":3.0,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","IsDefault":true,"IsDeleted":false,"City":"Mangalore","Longitude":34.34,"SystemModstamp":"2021-11-10T07:59:52.000+0000","dau01__DeleteRecord__c":false,"State":"Karnataka","CreatedDate":"2021-11-10T07:59:52.000+0000","IsPrimary":false,"Country":"India","AddressType":"Billing"}]},"dau01__Email__c":"nitheshk.hero@gmail.com","dau01__ApplicantType__c":"Primary","dau01__Revenues__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-11-10T07:59:52.000+0000","IsDeleted":false,"FinServ__SubType__c":"Transaction","FinServ__Type__c":"Commission","Name":"REV-000000014","SystemModstamp":"2021-11-10T07:59:52.000+0000","FinServ__Amount__c":10.0,"FinServ__Date__c":"2021-10-26","dau01__DeleteRecord__c":false}]}},{"LastModifiedDate":"2021-11-10T08:18:05.000+0000","IsDeleted":false,"dau01__IsEmailVerified__c":false,"dau01__LastName__c":"Member1","dau01__IsExistingCustomer__c":false,"Name":"Fmaily Member 1","SystemModstamp":"2021-11-10T08:18:05.000+0000","dau01__DeleteRecord__c":false,"dau01__IsPhoneNumberVerified__c":false,"dau01__Email__c":"nithesh.k@digitalalign.com","dau01__FirstName__c":"Fmaily","CreatedDate":"2021-11-10T08:18:05.000+0000","dau01__ApplicantNumber__c":"A-0010","dau01__ApplicantType__c":"Family Member"}]},"FinServ__TotalInvestmentsJointOwner__c":0.0,"FinServ__TotalBankDepositsJointOwner__c":0.0,"IsDeleted":false,"FinServ__WalletShare__c":0.0,"IsCustomerPortal":false,"LastViewedDate":"2021-11-10T08:27:41.000+0000","FinServ__TotalNonfinancialAssetsJointOwner__c":0.0,"FinServ__TotalBankDeposits__c":0.0,"SystemModstamp":"2021-11-10T07:59:52.000+0000","dau01__DeleteRecord__c":false,"CleanStatus":"Pending","FinServ__TotalAUMJointOwner__c":0.0,"ShippingAddress":null,"FinServ__TotalLiabilities__c":0.0,"CreatedDate":"2021-11-10T07:59:52.000+0000","FinServ__IndividualType__c":"Group","IsPartner":false}';
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000010fl06AAA',
  'a0b0p0000026aUnAAI',
  'Primary',
  'ApplicationFlow'
);
Request.data = js;
//request.currentPage = 'personal-information';
ApexResponse res = ApplicationController.saveApplication(request);
system.debug('Full Json : ' + res.data);

// #3 Delete Entity

ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000010fl06AAA',
  '',
  'Primary',
  'ApplicationFlow'
);
request.setHeader(
  new Map<String, String>{ 'recordId' => 'a0b0p0000026jWVAAY' }
);
ApexResponse res = ApplicationController.deleteEntity(request);
system.debug('Full Json : ' + res.data);

// #4 Review information
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000010fl06AAA',
  'a0b0p0000026aUsAAI',
  'Primary',
  'ApplicationFlow'
);
system.debug(request.token);
ApexResponse res = ApplicationController.reviewInformationSubmit(request);
system.debug('Full Json : ' + res.data);

// #8 validateToken
ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFONvS2ENRY3tJ2dmX4xaGrRU9BKBo6SZPCYhyNXv2HRPss325sZoznoK5yUsbQ/zZGQ3T0A+q+L0aEFmO3y7x/8VomqRl1Sk0SHCtmXbu0pkOw26VNRQ//qVHT2s8ZA0JNI+pO9W0rEa1EA0Z3lc8KuB+aBq3+w02+PmJXb996u6';
request.setRequest();
SecurityUtils.validateSession();
system.debug(ApexRequest.getApplicationId());
system.debug(ApexRequest.getApplicantType());

// #9 RefreshToken
ApexRequest request = new ApexRequest();
request.token = 'lTlmvHxNiXZSBgCGqoLKvAtpw0OHojTDjjbFY92PLay9GqQmAXdl7Dm8ecPuiZRPp+t2bJSz8+houOOob7bH2vtm3QMjUBN35JVNXWbu5OgrjJmpYVasJqbhWomNs/3r0gbwjopSEXf1cLzrNmmyFw==';
ApexResponse res = ApplicationController.refreshToken(request);
system.debug('Full Json : ' + res.data);

// #7 Create Token
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000010fl06AAA',
  'a0b0p0000026aUnAAI',
  'Primary',
  'ApplicationFlow'
);
request.setRequest();
system.debug('ApplicationId :' + Json.serialize(request));
SecurityUtils.validateSession();
system.debug('ApplicationId :' + ApexRequest.getApplicationId());
system.debug('applicantType : ' + ApexRequest.getApplicantType());
