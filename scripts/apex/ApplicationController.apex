// #1 calling read method
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000010fl06AAA',
  '',
  'Primary',
  'ApplicationFlow'
);
//request.applicationId = '0010p000010fl06AAA';
ApexResponse res = ApplicationController.readApplicationWithChild(request);
system.debug('Full Json : ' + res.data);

// #2 Save application

String js = '{"FinServ__IndividualType__c":"Group","LastModifiedById":"0050p0000037LPsAAM","ShippingAddress":null,"FinServ__TotalAUMJointOwner__c":12.0,"SystemModstamp":"2021-11-22T10:15:47.000Z","FinServ__TotalBankDeposits__c":0.0,"dau01__IsCountyEligible__c":true,"FinServ__TotalNonfinancialAssetsJointOwner__c":0.0,"IsCustomerPortal":false,"FinServ__WalletShare__c":0.0,"FinServ__TotalBankDepositsJointOwner__c":0.0,"FinServ__Status__c":"Active","RecordTypeId":"0120p0000018FOwAAM","FinServ__AUM__c":0.0,"FinServ__TotalInvestments__c":0.0,"OwnerId":"0050p0000037LPsAAM","FinServ__TotalInsurancePrimaryOwner__c":0.0,"BillingAddress":null,"FinServ__TotalInvestmentsPrimaryOwner__c":0.0,"FinServ__TotalInsuranceJointOwner__c":0.0,"FinServ__TotalNonfinancialAssetsPrimaryOwner__c":0.0,"LastReferencedDate":"2021-11-19T18:03:15.000Z","FinServ__TotalLiabilitiesJointOwner__c":0.0,"Description":"103.157.239.36","IsPartner":false,"Id":"0010p000010fl06AAA","CreatedDate":"2021-11-10T07:59:52.000Z","FinServ__TotalLiabilities__c":0.0,"CleanStatus":"Pending","dau01__DeleteRecord__c":false,"LastViewedDate":"2021-11-19T18:03:15.000Z","IsDeleted":false,"FinServ__TotalInvestmentsJointOwner__c":0.0,"dau01__Applicants__r":[{"dau01__Revenues__r":[{"FinServ__Account__c":"0010p000010fl06AAA","LastModifiedById":"0050p0000037LPsAAM","Id":"a0T0p000003RBSkEAO","CreatedDate":"2021-11-10T07:59:52.000Z","CreatedById":"0050p0000037LPsAAM","OwnerId":"0050p0000037LPsAAM","dau01__DeleteRecord__c":false,"FinServ__Date__c":"2021-10-26","FinServ__Amount__c":10.0,"SystemModstamp":"2021-11-10T08:52:48.000Z","Name":"REV-000000015","dau01__Applicant__c":"a0b0p0000026aUnAAI","FinServ__Type__c":"Commission","FinServ__SubType__c":"Transaction","IsDeleted":false,"LastModifiedDate":"2021-11-10T08:52:48.000Z"},{"FinServ__Account__c":"0010p000010fl06AAA","LastModifiedById":"0050p0000037LPsAAM","Id":"a0T0p000003RBSjEAO","CreatedDate":"2021-11-10T07:59:52.000Z","CreatedById":"0050p0000037LPsAAM","OwnerId":"0050p0000037LPsAAM","dau01__DeleteRecord__c":false,"FinServ__Date__c":"2021-10-26","FinServ__Amount__c":10.0,"SystemModstamp":"2021-11-10T08:52:48.000Z","Name":"REV-000000014","dau01__Applicant__c":"a0b0p0000026aUnAAI","FinServ__Type__c":"Commission","FinServ__SubType__c":"Transaction","IsDeleted":false,"LastModifiedDate":"2021-11-10T08:52:48.000Z"}],"dau01__OtpAttempts__c":1.0,"LastModifiedById":"0050p0000037LPsAAM","dau01__ContactPointAddresses__r":[{"LastModifiedById":"0050p0000037LPsAAM","AddressType":"Billing","Id":"8lW0p00000003LmEAI","Country":"India","IsPrimary":false,"CreatedDate":"2021-11-10T07:59:52.000Z","State":"Karnataka","dau01__DeleteRecord__c":false,"SystemModstamp":"2021-11-10T08:52:48.000Z","Longitude":34.34,"City":"Mangalore","IsDeleted":false,"IsDefault":false,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","dau01__YearsLivedAtCurrentAddress__c":3.0,"CreatedById":"0050p0000037LPsAAM","OwnerId":"0050p0000037LPsAAM","dau01__MonthsLivedAtCurrentAddress__c":2.0,"Name":"Nithesh K","dau01__Applicant__c":"a0b0p0000026aUnAAI","UsageType":"Home","Latitude":34.34,"PostalCode":"575017","LastModifiedDate":"2021-11-10T08:52:48.000Z"},{"LastModifiedById":"0050p0000037LPsAAM","AddressType":"Billing","Id":"8lW0p00000003LlEAI","Country":"India","IsPrimary":false,"CreatedDate":"2021-11-10T07:59:52.000Z","State":"Karnataka","dau01__DeleteRecord__c":false,"SystemModstamp":"2021-11-10T08:52:48.000Z","Longitude":34.34,"City":"Mangalore","IsDeleted":false,"IsDefault":true,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","dau01__YearsLivedAtCurrentAddress__c":3.0,"CreatedById":"0050p0000037LPsAAM","OwnerId":"0050p0000037LPsAAM","dau01__MonthsLivedAtCurrentAddress__c":2.0,"Name":"Nithesh K","dau01__Applicant__c":"a0b0p0000026aUnAAI","UsageType":"Home","Latitude":34.34,"PostalCode":"575017","LastModifiedDate":"2021-11-10T08:52:48.000Z"}],"Id":"a0b0p0000026aUnAAI","CreatedDate":"2021-11-10T07:59:52.000Z","dau01__DeleteRecord__c":false,"SystemModstamp":"2021-11-23T18:03:08.000Z","dau01__LastName__c":"Last Name","LastViewedDate":"2021-11-19T17:55:39.000Z","dau01__Application__c":"0010p000010fl06AAA","IsDeleted":false,"dau01__ApplicantType__c":"Primary","dau01__IdentificationDocuments__r":[{"LastModifiedById":"0050p0000037LPsAAM","Id":"a0I0p000001gH4NEAU","FinServ__IssuingCountry__c":"United States","CreatedDate":"2021-11-10T07:59:52.000Z","CreatedById":"0050p0000037LPsAAM","OwnerId":"0050p0000037LPsAAM","dau01__DeleteRecord__c":false,"SystemModstamp":"2021-11-10T08:52:48.000Z","Name":"DOC-000000019","dau01__Applicant__c":"a0b0p0000026aUnAAI","FinServ__DocumentNumber__c":"23432","FinServ__IssueDate__c":"2021-10-04","FinServ__ExpirationDate__c":"2021-10-07","IsDeleted":false,"FinServ__DocumentType__c":"License","LastModifiedDate":"2021-11-10T08:52:48.000Z"}],"dau01__ApplicantNumber__c":"A-0009","RecordTypeId":"0120p0000018FP1AAM","dau01__FirstName__c":"First Name","dau01__Email__c":"nithesh.k@digitalalign.com","CreatedById":"0050p0000037LPsAAM","OwnerId":"0050p0000037LPsAAM","dau01__IsPhoneNumberVerified__c":true,"dau01__Employments__r":[{"LastModifiedById":"0050p0000037LPsAAM","FinServ__Position__c":"1","Id":"a0A0p000001tPZjEAM","CreatedDate":"2021-11-10T07:59:52.000Z","FinServ__EmploymentStatus__c":"Employed","CreatedById":"0050p0000037LPsAAM","OwnerId":"0050p0000037LPsAAM","dau01__DeleteRecord__c":false,"SystemModstamp":"2021-11-10T08:52:48.000Z","Name":"Employed","dau01__Applicant__c":"a0b0p0000026aUnAAI","FinServ__AnnualIncome__c":23232.0,"FinServ__Occupation__c":"Sales","IsDeleted":false,"LastModifiedDate":"2021-11-10T08:52:48.000Z"}],"Name":"First Name Last Name","dau01__IsExistingCustomer__c":false,"LastReferencedDate":"2021-11-19T17:55:39.000Z","dau01__IsEmailVerified__c":false,"dau01__Phone__c":"7892981668","dau01__OTPExpireTime__c":"2021-11-18T11:16:22.000Z","LastModifiedDate":"2021-11-23T18:03:08.000Z"}],"PhotoUrl":"/services/images/photo/0010p000010fl06AAA","FinServ__TotalInsurance__c":0.0,"FinServ__TotalLiabilitiesPrimaryOwner__c":0.0,"FinServ__TotalNonfinancialAssets__c":0.0,"FinServ__TotalNumberOfFinAccounts__c":0.0,"CreatedById":"0050p0000037LPsAAM","FinServ__TotalBankDepositsPrimaryOwner__c":0.0,"dau01__isMemberFlow__c":false,"Name":"App-001","FinServ__TotalFinancialAccounts__c":0.0,"FinServ__TotalOutstandingCredit__c":0.0,"FinServ__TotalAUMPrimaryOwner__c":0.0,"LastModifiedDate":"2021-11-22T10:15:47.000Z"}';
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

// #8
system.debug(AuthenticationService.getInstance().getAuthToken());
Logger.persist();
