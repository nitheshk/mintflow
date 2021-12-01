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

//---------------------------------------------------------------------------------------------------------------
// #2 Save application
//---General Application
// String js = '{"FinServ__IndividualType__c":"Group","ShippingAddress":null,"FinServ__TotalAUMJointOwner__c":12.0,"SystemModstamp":"2021-11-22T10:15:47.000Z","FinServ__TotalBankDeposits__c":0.0,"mflow__IsCountyEligible__c":true,"FinServ__TotalNonfinancialAssetsJointOwner__c":0.0,"IsCustomerPortal":false,"FinServ__WalletShare__c":0.0,"FinServ__TotalBankDepositsJointOwner__c":0.0,"FinServ__Status__c":"Active","FinServ__AUM__c":0.0,"FinServ__TotalInvestments__c":0.0,"FinServ__TotalInsurancePrimaryOwner__c":0.0,"BillingAddress":null,"FinServ__TotalInvestmentsPrimaryOwner__c":0.0,"FinServ__TotalInsuranceJointOwner__c":0.0,"FinServ__TotalNonfinancialAssetsPrimaryOwner__c":0.0,"LastReferencedDate":"2021-11-19T18:03:15.000Z","FinServ__TotalLiabilitiesJointOwner__c":0.0,"Description":"103.157.239.36","IsPartner":false,"CreatedDate":"2021-11-10T07:59:52.000Z","FinServ__TotalLiabilities__c":0.0,"CleanStatus":"Pending","mflow__DeleteRecord__c":false,"LastViewedDate":"2021-11-19T18:03:15.000Z","IsDeleted":false,"FinServ__TotalInvestmentsJointOwner__c":0.0,"mflow__Applicants__r":[{"mflow__Revenues__r":[{"CreatedDate":"2021-11-10T07:59:52.000Z","mflow__DeleteRecord__c":false,"FinServ__Date__c":"2021-10-26","FinServ__Amount__c":10.0,"SystemModstamp":"2021-11-10T08:52:48.000Z","Name":"REV-000000015","FinServ__Type__c":"Commission","FinServ__SubType__c":"Transaction","IsDeleted":false,"LastModifiedDate":"2021-11-10T08:52:48.000Z"},{"mflow__DeleteRecord__c":false,"FinServ__Date__c":"2021-10-26","FinServ__Amount__c":10.0,"SystemModstamp":"2021-11-10T08:52:48.000Z","Name":"REV-000000014","FinServ__Type__c":"Commission","FinServ__SubType__c":"Transaction","IsDeleted":false,"LastModifiedDate":"2021-11-10T08:52:48.000Z"}],"mflow__OtpAttempts__c":1.0,"mflow__ContactPointAddresses__r":[{"AddressType":"Billing","Country":"India","IsPrimary":false,"CreatedDate":"2021-11-10T07:59:52.000Z","State":"Karnataka","mflow__DeleteRecord__c":false,"SystemModstamp":"2021-11-10T08:52:48.000Z","Longitude":34.34,"City":"Mangalore","IsDeleted":false,"IsDefault":false,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","mflow__YearsLivedAtCurrentAddress__c":3.0,"mflow__MonthsLivedAtCurrentAddress__c":2.0,"Name":"Nithesh K","UsageType":"Home","Latitude":34.34,"PostalCode":"575017","LastModifiedDate":"2021-11-10T08:52:48.000Z"},{"AddressType":"Billing","Country":"India","IsPrimary":false,"CreatedDate":"2021-11-10T07:59:52.000Z","State":"Karnataka","mflow__DeleteRecord__c":false,"SystemModstamp":"2021-11-10T08:52:48.000Z","Longitude":34.34,"City":"Mangalore","IsDeleted":false,"IsDefault":true,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","mflow__YearsLivedAtCurrentAddress__c":3.0,"mflow__MonthsLivedAtCurrentAddress__c":2.0,"Name":"Nithesh K","UsageType":"Home","Latitude":34.34,"PostalCode":"575017","LastModifiedDate":"2021-11-10T08:52:48.000Z"}],"CreatedDate":"2021-11-10T07:59:52.000Z","mflow__DeleteRecord__c":false,"SystemModstamp":"2021-11-23T18:03:08.000Z","mflow__LastName__c":"Last Name","LastViewedDate":"2021-11-19T17:55:39.000Z","IsDeleted":false,"mflow__ApplicantType__c":"Primary","mflow__IdentificationDocuments__r":[{"FinServ__IssuingCountry__c":"United States","CreatedDate":"2021-11-10T07:59:52.000Z","mflow__DeleteRecord__c":false,"SystemModstamp":"2021-11-10T08:52:48.000Z","FinServ__DocumentNumber__c":"23432","FinServ__IssueDate__c":"2021-10-04","FinServ__ExpirationDate__c":"2021-10-07","IsDeleted":false,"FinServ__DocumentType__c":"License","LastModifiedDate":"2021-11-10T08:52:48.000Z"}],"mflow__ApplicantNumber__c":"A-0009","mflow__FirstName__c":"First Name","mflow__Email__c":"nithesh.k@digitalalign.com","mflow__IsPhoneNumberVerified__c":true,"mflow__Employments__r":[{"FinServ__Position__c":"1","CreatedDate":"2021-11-10T07:59:52.000Z","FinServ__EmploymentStatus__c":"Employed","mflow__DeleteRecord__c":false,"SystemModstamp":"2021-11-10T08:52:48.000Z","Name":"Employed","FinServ__AnnualIncome__c":23232.0,"FinServ__Occupation__c":"Sales","IsDeleted":false,"LastModifiedDate":"2021-11-10T08:52:48.000Z"}],"Name":"First Name Last Name","mflow__IsExistingCustomer__c":false,"LastReferencedDate":"2021-11-19T17:55:39.000Z","mflow__IsEmailVerified__c":false,"mflow__Phone__c":"7892981668","mflow__OTPExpireTime__c":"2021-11-18T11:16:22.000Z","LastModifiedDate":"2021-11-23T18:03:08.000Z"}],"FinServ__TotalInsurance__c":0.0,"FinServ__TotalLiabilitiesPrimaryOwner__c":0.0,"FinServ__TotalNonfinancialAssets__c":0.0,"FinServ__TotalNumberOfFinAccounts__c":0.0,"FinServ__TotalBankDepositsPrimaryOwner__c":0.0,"mflow__isMemberFlow__c":false,"Name":"App-001","FinServ__TotalFinancialAccounts__c":0.0,"FinServ__TotalOutstandingCredit__c":0.0,"FinServ__TotalAUMPrimaryOwner__c":0.0,"LastModifiedDate":"2021-11-22T10:15:47.000Z"}';

//---Complete application with applicants and related records
string js = '{"dau01__SessionToken__c":"pyh8mYAVjrnj1iy5gF7JFONvS2ENRY3tJ2dmX4xaGrRCE4JwBKxR+cY7mP+SxEOhxZXJQfpcnPTa0IuMxJk4x2ZcxpETlJ9ajwrc7OEz2txnpG4A1pVKhkV83jsYZCMy/9yoKASuHaZJgasHHQGgxL1SGCz4RxHhWnypd55icuc=","dau01__CreatedChannel__c":"Virtual","CreatedDate":"2021-11-15T06:32:06.000Z","dau01__DeleteRecord__c":false,"dau01__Version__c":"0.1","FinServ__BranchName__c":"Manhattan","dau01__IsCountyEligible__c":true,"FinServ__CustomerType__c":"Consumer","dau01__SubmittedDate__c":"2021-11-12","dau01__Applicants__r":[{"dau01__Revenues__r":[{"CreatedDate":"2021-11-15T13:35:34.000Z","dau01__DeleteRecord__c":false,"FinServ__Date__c":"2019-11-06","FinServ__Amount__c":2500.0,"SystemModstamp":"2021-11-16T12:07:56.000Z","Name":"REV-000000000","FinServ__Type__c":"Fees","FinServ__SubType__c":"Transaction","dau01__Order__c":1.0,"IsDeleted":false,"LastModifiedDate":"2021-11-16T12:07:56.000Z"}],"dau01__ContactPointAddresses__r":[{"AddressType":"Primary","Country":"India","Street":"street one","IsPrimary":true,"CreatedDate":"2021-11-15T06:29:14.000Z","State":"karnataka","dau01__DeleteRecord__c":false,"SystemModstamp":"2021-11-16T12:11:48.000Z","Name":"00101","City":"CA","LastReferencedDate":"2021-11-19T12:01:36.000Z","PostalCode":"34323","LastViewedDate":"2021-11-19T12:01:36.000Z","dau01__Order__c":1.0,"IsDeleted":false,"LastModifiedDate":"2021-11-16T12:11:48.000Z","IsDefault":false},{"AddressType":"Document","Country":"India","Street":"street one","IsPrimary":false,"CreatedDate":"2021-11-15T13:32:48.000Z","State":"karnataka","dau01__DeleteRecord__c":false,"SystemModstamp":"2021-11-16T12:11:58.000Z","Name":"002","City":"CA","LastReferencedDate":"2021-11-16T12:18:56.000Z","PostalCode":"34323","LastViewedDate":"2021-11-16T12:18:56.000Z","dau01__Order__c":2.0,"IsDeleted":false,"LastModifiedDate":"2021-11-16T12:11:58.000Z","IsDefault":false}],"dau01__MembershipAccountNumber__c":"3453452","dau01__EmploymentStatus__c":"Manual","CreatedDate":"2021-11-15T06:28:09.000Z","dau01__SmsOtp__c":"5678","dau01__SSN__c":"569863215","dau01__DeleteRecord__c":false,"SystemModstamp":"2021-11-16T12:05:51.000Z","dau01__LastName__c":"Doe","LastViewedDate":"2021-11-23T04:21:20.000Z","dau01__IncomeVerificationStatus__c":"Approved","dau01__KYCStatus__c":"Passed","IsDeleted":false,"dau01__SentiLinkFraudScore__c":650.0,"dau01__ApplicantType__c":"Primary","dau01__AssetsAndLiabilities__r":[{"FinServ__AssetsAndLiabilitiesType__c":"Other","FinServ__AssetsAndLiabilitiesSource__c":"Manual Entry","CreatedDate":"2021-11-15T13:36:01.000Z","dau01__DeleteRecord__c":false,"FinServ__Amount__c":2500.0,"SystemModstamp":"2021-11-16T12:19:05.000Z","Name":"car","LastReferencedDate":"2021-11-16T12:19:05.000Z","LastViewedDate":"2021-11-16T12:19:05.000Z","dau01__Order__c":1.0,"FinServ__Ownership__c":"Individual","IsDeleted":false,"LastModifiedDate":"2021-11-16T12:19:05.000Z"}],"dau01__EmailOtp__c":"1234","dau01__CreditScore__c":120.0,"dau01__IdentificationDocuments__r":[{"dau01__Gender__c":"Male","dau01__Nationality__c":"USA","CreatedDate":"2021-11-15T13:33:51.000Z","dau01__Weight__c":"69","dau01__DeleteRecord__c":false,"SystemModstamp":"2021-11-16T12:09:30.000Z","LastViewedDate":"2021-11-19T12:48:35.000Z","FinServ__DocumentNumber__c":"DL-009","FinServ__IssueDate__c":"2010-11-03","FinServ__ExpirationDate__c":"2027-11-10","IsDeleted":false,"dau01__Height__c":"5.4","FinServ__IssuingCountry__c":"United States","dau01__IssuedRegion__c":"New york","Name":"DOC-000000000","LastReferencedDate":"2021-11-19T12:48:35.000Z","dau01__Order__c":1.0,"FinServ__DocumentType__c":"License","LastModifiedDate":"2021-11-16T12:09:30.000Z"}],"dau01__ApplicantNumber__c":"A-0001","dau01__FirstName__c":"john","dau01__Email__c":"qa@digitalalign.com","dau01__SentiLinkStatus__c":"Passsed","dau01__IsPhoneNumberVerified__c":true,"dau01__Employments__r":[{"CreatedDate":"2021-11-15T13:34:29.000Z","FinServ__EmploymentStatus__c":"Employed","dau01__DeleteRecord__c":false,"dau01__PayCycle__c":"Bi-Weekly","SystemModstamp":"2021-11-17T16:44:56.000Z","dau01__GrossMonthlySalary__c":5000.0,"dau01__EmploymentType__c":"Current","LastViewedDate":"2021-11-17T16:44:56.000Z","dau01__EmploymentDuration__c":5.0,"IsDeleted":false,"dau01__IncomeType__c":"Interest","dau01__PayGrade__c":"For Goverment/DOD","dau01__DocumentType__c":"W2","FinServ__Position__c":"Lead","dau01__EmploymentVerificationType__c":"Manual","Name":"DA","LastReferencedDate":"2021-11-17T16:44:56.000Z","dau01__Order__c":1.0,"LastModifiedDate":"2021-11-17T16:44:56.000Z"}],"Name":"john doe","dau01__IsExistingCustomer__c":false,"dau01__FraudStatus__c":"Less","LastReferencedDate":"2021-11-23T04:21:20.000Z","dau01__IdentityVerificationStatus__c":"Verified","dau01__IsEmailVerified__c":true,"dau01__SentiLinkRemarks__c":"SentiLink fraud screw: 650","dau01__Phone__c":"6789876567","dau01__Order__c":1.0,"dau01__MiddleName__c":"d","dau01__CustomerNumber__c":"345654","dau01__OTPExpireTime__c":"2021-11-16T20:00:00.000Z","LastModifiedDate":"2021-11-16T12:05:51.000Z","dau01__Birthdate__c":"1990-11-01"},{"dau01__Revenues__r":[{"CreatedDate":"2021-11-15T14:15:50.000Z","dau01__DeleteRecord__c":false,"FinServ__Date__c":"2021-11-04","FinServ__Amount__c":1000.0,"SystemModstamp":"2021-11-16T12:14:28.000Z","Name":"REV-000000001","FinServ__Type__c":"Fees","FinServ__SubType__c":"Planning","dau01__Order__c":1.0,"IsDeleted":false,"LastModifiedDate":"2021-11-16T12:14:28.000Z"}],"dau01__ContactPointAddresses__r":[{"AddressType":"Primary","Country":"USA","Street":"street one","IsPrimary":true,"CreatedDate":"2021-11-15T14:13:55.000Z","State":"CA","dau01__DeleteRecord__c":false,"SystemModstamp":"2021-11-16T12:13:31.000Z","Name":"001","City":"city","LastReferencedDate":"2021-11-16T12:13:32.000Z","PostalCode":"10001","LastViewedDate":"2021-11-16T12:13:32.000Z","dau01__Order__c":1.0,"IsDeleted":false,"LastModifiedDate":"2021-11-16T12:13:31.000Z","IsDefault":false}],"dau01__MembershipAccountNumber__c":"42343243","dau01__EmploymentStatus__c":"Manual","CreatedDate":"2021-11-15T14:13:00.000Z","dau01__SSN__c":"8790987899","dau01__DeleteRecord__c":false,"SystemModstamp":"2021-11-24T06:26:36.000Z","dau01__LastName__c":"Doe","LastViewedDate":"2021-11-24T12:00:36.000Z","dau01__IncomeVerificationStatus__c":"In Progress","dau01__KYCStatus__c":"Passed","IsDeleted":false,"dau01__SentiLinkFraudScore__c":444.0,"dau01__ApplicantType__c":"Joint","dau01__AssetsAndLiabilities__r":[{"FinServ__AssetsAndLiabilitiesType__c":"Gold","CreatedDate":"2021-11-15T14:16:20.000Z","dau01__DeleteRecord__c":false,"FinServ__Amount__c":2300.0,"SystemModstamp":"2021-11-16T12:18:53.000Z","Name":"Gold","LastReferencedDate":"2021-11-16T12:18:53.000Z","LastViewedDate":"2021-11-16T12:18:53.000Z","dau01__Order__c":1.0,"FinServ__Ownership__c":"Joint","IsDeleted":false,"LastModifiedDate":"2021-11-16T12:18:53.000Z"}],"dau01__CreditScore__c":333.0,"dau01__IdentificationDocuments__r":[{"dau01__Gender__c":"Female","dau01__Nationality__c":"USA","CreatedDate":"2021-11-15T14:14:45.000Z","dau01__Weight__c":"56","dau01__DeleteRecord__c":false,"SystemModstamp":"2021-11-16T12:14:12.000Z","LastViewedDate":"2021-11-16T12:14:12.000Z","FinServ__DocumentNumber__c":"DL-pp0098","FinServ__IssueDate__c":"2011-11-01","FinServ__ExpirationDate__c":"2021-11-26","IsDeleted":false,"dau01__Height__c":"5.3","FinServ__IssuingCountry__c":"United States","dau01__IssuedRegion__c":"New york","Name":"DOC-000000001","LastReferencedDate":"2021-11-16T12:14:12.000Z","dau01__Order__c":1.0,"FinServ__DocumentType__c":"License","LastModifiedDate":"2021-11-16T12:14:12.000Z"}],"dau01__ApplicantNumber__c":"A-0002","dau01__FirstName__c":"Jane","dau01__Email__c":"qa@digitalalign.com","dau01__SentiLinkStatus__c":"Passsed","dau01__IsPhoneNumberVerified__c":true,"dau01__Employments__r":[{"dau01__DocumentType__c":"W2","FinServ__Position__c":"Lead","CreatedDate":"2021-11-15T14:15:17.000Z","FinServ__EmploymentStatus__c":"Self-Employed","dau01__DeleteRecord__c":false,"dau01__EmploymentVerificationType__c":"Manual","SystemModstamp":"2021-11-16T12:16:51.000Z","Name":"DA","dau01__GrossMonthlySalary__c":150000.0,"dau01__EmploymentType__c":"Current","LastReferencedDate":"2021-11-16T12:16:51.000Z","LastViewedDate":"2021-11-16T12:16:51.000Z","dau01__Order__c":1.0,"dau01__EmploymentDuration__c":1.0,"IsDeleted":false,"LastModifiedDate":"2021-11-16T12:16:51.000Z","dau01__PayGrade__c":"For Goverment/DOD"}],"Name":"Jane","dau01__IsExistingCustomer__c":false,"dau01__FraudStatus__c":"Less","LastReferencedDate":"2021-11-24T12:00:36.000Z","dau01__IdentityVerificationStatus__c":"Verified","dau01__IsEmailVerified__c":true,"dau01__SentiLinkRemarks__c":"Sentilink score:456","dau01__Phone__c":"3434567655","dau01__Order__c":2.0,"dau01__MiddleName__c":"d","dau01__CustomerNumber__c":"876890","LastModifiedDate":"2021-11-24T06:26:36.000Z","dau01__Birthdate__c":"2004-11-04"}],"dau01__UserAccountType__c":"CustomerApplication","FinServ__Status__c":"Completed","dau01__FlowState__c":"Final-Confirmation","FinServ__BranchCode__c":"002","dau01__ApplicationNumber__c":"App-0001","dau01__IPAddress__c":"59.90.16.140","dau01__isMemberFlow__c":false,"Name":"app","dau01__SubStatus__c":"Verified"}';
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000011CP4PAAW',
  '',
  'Primary',
  'ApplicationFlow'
);
Request.data = js;
//request.currentPage = 'personal-information';
ApexResponse res = ApplicationController.saveApplication(request);
system.debug('Full Json : ' + res.data);

//---------------------------------------------------------------------------------------------------------------
// #3 Delete Entity

ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000010fl06AAA',
  '',
  'Primary',
  'ApplicationFlow'
);
request.setHeader(
  new Map<String, String>{ 'recordId' => '0010p000011AG7oAAG' }
);
// request.setHeader(
//   new Map<String, Object>{
//     'recordIds' => new List<String>{
//       'a0b0p0000026jWaAAI',
//       'a0b0p0000026jWbAAI'
//     }
//   }
// );

ApexResponse res = ApplicationController.deleteEntity(request);
system.debug('Full Json : ' + res.data);

//------------------------------------------------------------------------------
// #4 Review information
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0016D00000ZAr5lQAD',
  '',
  'Primary',
  'ApplicationFlow'
);
system.debug(request.token);
ApexResponse res = ApplicationController.reviewInformationSubmit(request);
system.debug('Full Json : ' + res.data);

//--------------------------------------------------------------------------------
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
