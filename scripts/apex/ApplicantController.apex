// calling read method for applicants by passging list of ids
ApexRequest request = new ApexRequest();
request.applicationId = '0010p000010fXFhAAM';
request.setHeader(
  new Map<String, Object>{
    'applicantIds' => new List<String>({ 'a0b0p0000026aCvAAI' })
  }
);
ApexResponse res = ApplicantController.readApplicantsWithChild(request);
system.debug('Full Json : ' + res.data);


// calling Save method for applicants
String js = '[{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"dau01__IsEmailVerified__c":false,"dau01__LastName__c":"Last Name","dau01__IsExistingCustomer__c":false,"dau01__ApplicantType__c":"Primary;Joint;Family Member","dau01__Application__c":"0010p000010fXFhAAM","Name":"Applicant new","SystemModstamp":"2021-10-26T11:52:55.000+0000","dau01__Employments__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:56:39.000+0000","IsDeleted":false,"FinServ__Occupation__c":"Sales","FinServ__AnnualIncome__c":23232.0,"Name":"Employed","SystemModstamp":"2021-10-26T11:56:39.000+0000","dau01__DeleteRecord__c":false,"FinServ__EmploymentStatus__c":"Employed","CreatedDate":"2021-10-26T11:56:39.000+0000","FinServ__Position__c":"1"},{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"FinServ__Occupation__c":"Sales","FinServ__AnnualIncome__c":23232.0,"LastViewedDate":"2021-10-26T11:46:00.000+0000","LastReferencedDate":"2021-10-26T11:46:00.000+0000","Name":"Employed","SystemModstamp":"2021-10-26T11:52:55.000+0000","dau01__DeleteRecord__c":false,"FinServ__EmploymentStatus__c":"Employed","CreatedDate":"2021-10-26T11:45:58.000+0000","FinServ__Position__c":"1"}]},"dau01__IsPhoneNumberVerified__c":false,"dau01__DeleteRecord__c":false,"dau01__FirstName__c":"First Name","CreatedDate":"2021-10-25T15:08:33.000+0000","dau01__IdentificationDocuments__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:56:39.000+0000","FinServ__DocumentType__c":"License","IsDeleted":false,"FinServ__ExpirationDate__c":"2021-10-07","FinServ__IssueDate__c":"2021-10-04","FinServ__DocumentNumber__c":"23432","Name":"DOC-000000003","SystemModstamp":"2021-10-26T11:56:39.000+0000","dau01__DeleteRecord__c":false,"CreatedDate":"2021-10-26T11:56:39.000+0000","FinServ__IssuingCountry__c":"United States"},{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","FinServ__DocumentType__c":"License","IsDeleted":false,"FinServ__ExpirationDate__c":"2021-10-07","FinServ__IssueDate__c":"2021-10-04","FinServ__DocumentNumber__c":"23432","LastViewedDate":"2021-10-26T08:16:30.000+0000","LastReferencedDate":"2021-10-26T08:16:30.000+0000","Name":"DOC-000000002","SystemModstamp":"2021-10-26T11:52:55.000+0000","dau01__DeleteRecord__c":false,"CreatedDate":"2021-10-26T08:16:26.000+0000","FinServ__IssuingCountry__c":"United States"}]},"dau01__ContactPointAddresses__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","dau01__deleteRecord__c":false,"PostalCode":"575017","Latitude":34.34,"UsageType":"Home","Name":"Nithesh K","dau01__MonthsLivedAtCurrentAddress__c":2.0,"dau01__YearsLivedAtCurrentAddress__c":3.0,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","IsDefault":true,"IsDeleted":false,"City":"Mangalore","Longitude":34.34,"SystemModstamp":"2021-10-26T11:52:55.000+0000","State":"Karnataka","CreatedDate":"2021-10-26T07:54:15.000+0000","IsPrimary":false,"Country":"India","AddressType":"Billing"},{"LastModifiedDate":"2021-10-26T11:56:39.000+0000","dau01__deleteRecord__c":false,"PostalCode":"575017","Latitude":34.34,"UsageType":"Home","Name":"Nithesh K","dau01__MonthsLivedAtCurrentAddress__c":2.0,"dau01__YearsLivedAtCurrentAddress__c":3.0,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","IsDefault":true,"IsDeleted":false,"City":"Mangalore","Longitude":34.34,"SystemModstamp":"2021-10-26T11:56:39.000+0000","State":"Karnataka","CreatedDate":"2021-10-26T11:56:39.000+0000","IsPrimary":false,"Country":"India","AddressType":"Billing"}]},"dau01__Revenues__r":{"totalSize":2,"done":true,"records":[{"IsDeleted":false,"FinServ__SubType__c":"Transaction","FinServ__Type__c":"Commission","Name":"REV-000000013","SystemModstamp":"2021-10-26T11:56:39.000+0000","FinServ__Amount__c":10.0,"FinServ__Date__c":"2021-10-26","dau01__DeleteRecord__c":false,"CreatedDate":"2021-10-26T11:56:39.000+0000"},{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"FinServ__SubType__c":"Transaction","FinServ__Type__c":"Commission","Name":"REV-000000003","SystemModstamp":"2021-10-26T11:52:55.000+0000","FinServ__Amount__c":10.0,"FinServ__Date__c":"2021-10-26","dau01__DeleteRecord__c":false}]}}]';
ApexRequest request = new ApexRequest();
Request.data = js;
request.applicationId = '0010p000010fXFhAAM';
ApexResponse res = ApplicantController.saveApplicants(request);
system.debug('Full Json : ' + res.data);


// calling Save method for applicant
String js = '{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"dau01__IsEmailVerified__c":false,"dau01__LastName__c":"Last Name","dau01__IsExistingCustomer__c":false,"dau01__ApplicantType__c":"Primary;Joint;Family Member","dau01__Application__c":"0010p000010fXFhAAM","Name":"Applicant new","SystemModstamp":"2021-10-26T11:52:55.000+0000","dau01__Employments__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:56:39.000+0000","IsDeleted":false,"FinServ__Occupation__c":"Sales","FinServ__AnnualIncome__c":23232.0,"Name":"Employed","SystemModstamp":"2021-10-26T11:56:39.000+0000","dau01__DeleteRecord__c":false,"FinServ__EmploymentStatus__c":"Employed","CreatedDate":"2021-10-26T11:56:39.000+0000","FinServ__Position__c":"1"},{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"FinServ__Occupation__c":"Sales","FinServ__AnnualIncome__c":23232.0,"LastViewedDate":"2021-10-26T11:46:00.000+0000","LastReferencedDate":"2021-10-26T11:46:00.000+0000","Name":"Employed","SystemModstamp":"2021-10-26T11:52:55.000+0000","dau01__DeleteRecord__c":false,"FinServ__EmploymentStatus__c":"Employed","CreatedDate":"2021-10-26T11:45:58.000+0000","FinServ__Position__c":"1"}]},"dau01__IsPhoneNumberVerified__c":false,"dau01__DeleteRecord__c":false,"dau01__FirstName__c":"First Name","CreatedDate":"2021-10-25T15:08:33.000+0000","dau01__IdentificationDocuments__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:56:39.000+0000","FinServ__DocumentType__c":"License","IsDeleted":false,"FinServ__ExpirationDate__c":"2021-10-07","FinServ__IssueDate__c":"2021-10-04","FinServ__DocumentNumber__c":"23432","Name":"DOC-000000003","SystemModstamp":"2021-10-26T11:56:39.000+0000","dau01__DeleteRecord__c":false,"CreatedDate":"2021-10-26T11:56:39.000+0000","FinServ__IssuingCountry__c":"United States"},{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","FinServ__DocumentType__c":"License","IsDeleted":false,"FinServ__ExpirationDate__c":"2021-10-07","FinServ__IssueDate__c":"2021-10-04","FinServ__DocumentNumber__c":"23432","LastViewedDate":"2021-10-26T08:16:30.000+0000","LastReferencedDate":"2021-10-26T08:16:30.000+0000","Name":"DOC-000000002","SystemModstamp":"2021-10-26T11:52:55.000+0000","dau01__DeleteRecord__c":false,"CreatedDate":"2021-10-26T08:16:26.000+0000","FinServ__IssuingCountry__c":"United States"}]},"dau01__ContactPointAddresses__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","dau01__deleteRecord__c":false,"PostalCode":"575017","Latitude":34.34,"UsageType":"Home","Name":"Nithesh K","dau01__MonthsLivedAtCurrentAddress__c":2.0,"dau01__YearsLivedAtCurrentAddress__c":3.0,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","IsDefault":true,"IsDeleted":false,"City":"Mangalore","Longitude":34.34,"SystemModstamp":"2021-10-26T11:52:55.000+0000","State":"Karnataka","CreatedDate":"2021-10-26T07:54:15.000+0000","IsPrimary":false,"Country":"India","AddressType":"Billing"},{"LastModifiedDate":"2021-10-26T11:56:39.000+0000","dau01__deleteRecord__c":false,"PostalCode":"575017","Latitude":34.34,"UsageType":"Home","Name":"Nithesh K","dau01__MonthsLivedAtCurrentAddress__c":2.0,"dau01__YearsLivedAtCurrentAddress__c":3.0,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","IsDefault":true,"IsDeleted":false,"City":"Mangalore","Longitude":34.34,"SystemModstamp":"2021-10-26T11:56:39.000+0000","State":"Karnataka","CreatedDate":"2021-10-26T11:56:39.000+0000","IsPrimary":false,"Country":"India","AddressType":"Billing"}]},"dau01__Revenues__r":{"totalSize":2,"done":true,"records":[{"IsDeleted":false,"FinServ__SubType__c":"Transaction","FinServ__Type__c":"Commission","Name":"REV-000000013","SystemModstamp":"2021-10-26T11:56:39.000+0000","FinServ__Amount__c":10.0,"FinServ__Date__c":"2021-10-26","dau01__DeleteRecord__c":false,"CreatedDate":"2021-10-26T11:56:39.000+0000"},{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"FinServ__SubType__c":"Transaction","FinServ__Type__c":"Commission","Name":"REV-000000003","SystemModstamp":"2021-10-26T11:52:55.000+0000","FinServ__Amount__c":10.0,"FinServ__Date__c":"2021-10-26","dau01__DeleteRecord__c":false}]}}';
ApexRequest request = new ApexRequest();
Request.data = js;
request.applicationId = '0010p000010fXFhAAM';
ApexResponse res = ApplicantController.saveApplicant(request);
system.debug('Full Json : ' + res.data);


// generateOTP
ApexRequest request = new ApexRequest();
request.setHeader(
  new Map<String, String>{ 'applicantId' => 'a0b0p0000026aUsAAI' }
);
ApexResponse res = ApplicantController.generateOTP(request);
system.debug('Full Json : ' + res.data);

// validateOTP
ApexRequest request = new ApexRequest();
request.setHeader(
  new Map<String, String>{
    'applicantId' => 'a0b0p0000026aUsAAI',
    'sms' => '1358',
    'email' => '1921'
  }
);
ApexResponse res = ApplicantController.validateOTP(request);
system.debug('Full Json : ' + res.data);

 