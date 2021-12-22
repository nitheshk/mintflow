// calling read method for applicants by passging list of ids
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000010fl06AAA',
  'a0b0p0000026aUnAAI',
  'Joint',
  'ApplicationFlow'
);
request.setHeader(
  new Map<String, Object>{
    'applicantIds' => (new List<String>{ 'a0b0p0000026aUsAAI' })
  }
);
ApexResponse res = ApplicantController.readApplicantsWithChild(request);
system.debug('Full Json : ' + res.data);

// calling Save method for applicants
String js = '[{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"mflow__IsEmailVerified__c":false,"mflow__LastName__c":"Last Name","mflow__IsExistingCustomer__c":false,"mflow__ApplicantType__c":"Primary;Joint;Family Member","mflow__Application__c":"0010p000010fXFhAAM","Name":"Applicant new","SystemModstamp":"2021-10-26T11:52:55.000+0000","mflow__Employments__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:56:39.000+0000","IsDeleted":false,"FinServ__Occupation__c":"Sales","FinServ__AnnualIncome__c":23232.0,"Name":"Employed","SystemModstamp":"2021-10-26T11:56:39.000+0000","mflow__DeleteRecord__c":false,"FinServ__EmploymentStatus__c":"Employed","CreatedDate":"2021-10-26T11:56:39.000+0000","FinServ__Position__c":"1"},{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"FinServ__Occupation__c":"Sales","FinServ__AnnualIncome__c":23232.0,"LastViewedDate":"2021-10-26T11:46:00.000+0000","LastReferencedDate":"2021-10-26T11:46:00.000+0000","Name":"Employed","SystemModstamp":"2021-10-26T11:52:55.000+0000","mflow__DeleteRecord__c":false,"FinServ__EmploymentStatus__c":"Employed","CreatedDate":"2021-10-26T11:45:58.000+0000","FinServ__Position__c":"1"}]},"mflow__IsPhoneNumberVerified__c":false,"mflow__DeleteRecord__c":false,"mflow__FirstName__c":"First Name","CreatedDate":"2021-10-25T15:08:33.000+0000","mflow__IdentificationDocuments__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:56:39.000+0000","FinServ__DocumentType__c":"License","IsDeleted":false,"FinServ__ExpirationDate__c":"2021-10-07","FinServ__IssueDate__c":"2021-10-04","FinServ__DocumentNumber__c":"23432","Name":"DOC-000000003","SystemModstamp":"2021-10-26T11:56:39.000+0000","mflow__DeleteRecord__c":false,"CreatedDate":"2021-10-26T11:56:39.000+0000","FinServ__IssuingCountry__c":"United States"},{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","FinServ__DocumentType__c":"License","IsDeleted":false,"FinServ__ExpirationDate__c":"2021-10-07","FinServ__IssueDate__c":"2021-10-04","FinServ__DocumentNumber__c":"23432","LastViewedDate":"2021-10-26T08:16:30.000+0000","LastReferencedDate":"2021-10-26T08:16:30.000+0000","Name":"DOC-000000002","SystemModstamp":"2021-10-26T11:52:55.000+0000","mflow__DeleteRecord__c":false,"CreatedDate":"2021-10-26T08:16:26.000+0000","FinServ__IssuingCountry__c":"United States"}]},"mflow__ContactPointAddresses__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","mflow__deleteRecord__c":false,"PostalCode":"575017","Latitude":34.34,"UsageType":"Home","Name":"Nithesh K","mflow__MonthsLivedAtCurrentAddress__c":2.0,"mflow__YearsLivedAtCurrentAddress__c":3.0,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","IsDefault":true,"IsDeleted":false,"City":"Mangalore","Longitude":34.34,"SystemModstamp":"2021-10-26T11:52:55.000+0000","State":"Karnataka","CreatedDate":"2021-10-26T07:54:15.000+0000","IsPrimary":false,"Country":"India","AddressType":"Billing"},{"LastModifiedDate":"2021-10-26T11:56:39.000+0000","mflow__deleteRecord__c":false,"PostalCode":"575017","Latitude":34.34,"UsageType":"Home","Name":"Nithesh K","mflow__MonthsLivedAtCurrentAddress__c":2.0,"mflow__YearsLivedAtCurrentAddress__c":3.0,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","IsDefault":true,"IsDeleted":false,"City":"Mangalore","Longitude":34.34,"SystemModstamp":"2021-10-26T11:56:39.000+0000","State":"Karnataka","CreatedDate":"2021-10-26T11:56:39.000+0000","IsPrimary":false,"Country":"India","AddressType":"Billing"}]},"mflow__Revenues__r":{"totalSize":2,"done":true,"records":[{"IsDeleted":false,"FinServ__SubType__c":"Transaction","FinServ__Type__c":"Commission","Name":"REV-000000013","SystemModstamp":"2021-10-26T11:56:39.000+0000","FinServ__Amount__c":10.0,"FinServ__Date__c":"2021-10-26","mflow__DeleteRecord__c":false,"CreatedDate":"2021-10-26T11:56:39.000+0000"},{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"FinServ__SubType__c":"Transaction","FinServ__Type__c":"Commission","Name":"REV-000000003","SystemModstamp":"2021-10-26T11:52:55.000+0000","FinServ__Amount__c":10.0,"FinServ__Date__c":"2021-10-26","mflow__DeleteRecord__c":false}]}}]';
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000011AFiIAAW',
  '',
  'Primary',
  'ApplicationFlow'
);
Request.data = js;
ApexResponse res = ApplicantController.saveApplicants(request);
system.debug('Full Json : ' + res.data);

// calling Save method for applicant
String js = '{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"mflow__IsEmailVerified__c":false,"mflow__LastName__c":"Last Name","mflow__IsExistingCustomer__c":false,"mflow__ApplicantType__c":"Primary;Joint;Family Member","mflow__Application__c":"0010p000010fXFhAAM","Name":"Applicant new","SystemModstamp":"2021-10-26T11:52:55.000+0000","mflow__Employments__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:56:39.000+0000","IsDeleted":false,"FinServ__Occupation__c":"Sales","FinServ__AnnualIncome__c":23232.0,"Name":"Employed","SystemModstamp":"2021-10-26T11:56:39.000+0000","mflow__DeleteRecord__c":false,"FinServ__EmploymentStatus__c":"Employed","CreatedDate":"2021-10-26T11:56:39.000+0000","FinServ__Position__c":"1"},{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"FinServ__Occupation__c":"Sales","FinServ__AnnualIncome__c":23232.0,"LastViewedDate":"2021-10-26T11:46:00.000+0000","LastReferencedDate":"2021-10-26T11:46:00.000+0000","Name":"Employed","SystemModstamp":"2021-10-26T11:52:55.000+0000","mflow__DeleteRecord__c":false,"FinServ__EmploymentStatus__c":"Employed","CreatedDate":"2021-10-26T11:45:58.000+0000","FinServ__Position__c":"1"}]},"mflow__IsPhoneNumberVerified__c":false,"mflow__DeleteRecord__c":false,"mflow__FirstName__c":"First Name","CreatedDate":"2021-10-25T15:08:33.000+0000","mflow__IdentificationDocuments__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:56:39.000+0000","FinServ__DocumentType__c":"License","IsDeleted":false,"FinServ__ExpirationDate__c":"2021-10-07","FinServ__IssueDate__c":"2021-10-04","FinServ__DocumentNumber__c":"23432","Name":"DOC-000000003","SystemModstamp":"2021-10-26T11:56:39.000+0000","mflow__DeleteRecord__c":false,"CreatedDate":"2021-10-26T11:56:39.000+0000","FinServ__IssuingCountry__c":"United States"},{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","FinServ__DocumentType__c":"License","IsDeleted":false,"FinServ__ExpirationDate__c":"2021-10-07","FinServ__IssueDate__c":"2021-10-04","FinServ__DocumentNumber__c":"23432","LastViewedDate":"2021-10-26T08:16:30.000+0000","LastReferencedDate":"2021-10-26T08:16:30.000+0000","Name":"DOC-000000002","SystemModstamp":"2021-10-26T11:52:55.000+0000","mflow__DeleteRecord__c":false,"CreatedDate":"2021-10-26T08:16:26.000+0000","FinServ__IssuingCountry__c":"United States"}]},"mflow__ContactPointAddresses__r":{"totalSize":2,"done":true,"records":[{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","mflow__deleteRecord__c":false,"PostalCode":"575017","Latitude":34.34,"UsageType":"Home","Name":"Nithesh K","mflow__MonthsLivedAtCurrentAddress__c":2.0,"mflow__YearsLivedAtCurrentAddress__c":3.0,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","IsDefault":true,"IsDeleted":false,"City":"Mangalore","Longitude":34.34,"SystemModstamp":"2021-10-26T11:52:55.000+0000","State":"Karnataka","CreatedDate":"2021-10-26T07:54:15.000+0000","IsPrimary":false,"Country":"India","AddressType":"Billing"},{"LastModifiedDate":"2021-10-26T11:56:39.000+0000","mflow__deleteRecord__c":false,"PostalCode":"575017","Latitude":34.34,"UsageType":"Home","Name":"Nithesh K","mflow__MonthsLivedAtCurrentAddress__c":2.0,"mflow__YearsLivedAtCurrentAddress__c":3.0,"Street":"Amrutha nilaya, Kerebail Gudde Thokkottu","IsDefault":true,"IsDeleted":false,"City":"Mangalore","Longitude":34.34,"SystemModstamp":"2021-10-26T11:56:39.000+0000","State":"Karnataka","CreatedDate":"2021-10-26T11:56:39.000+0000","IsPrimary":false,"Country":"India","AddressType":"Billing"}]},"mflow__Revenues__r":{"totalSize":2,"done":true,"records":[{"IsDeleted":false,"FinServ__SubType__c":"Transaction","FinServ__Type__c":"Commission","Name":"REV-000000013","SystemModstamp":"2021-10-26T11:56:39.000+0000","FinServ__Amount__c":10.0,"FinServ__Date__c":"2021-10-26","mflow__DeleteRecord__c":false,"CreatedDate":"2021-10-26T11:56:39.000+0000"},{"LastModifiedDate":"2021-10-26T11:52:55.000+0000","IsDeleted":false,"FinServ__SubType__c":"Transaction","FinServ__Type__c":"Commission","Name":"REV-000000003","SystemModstamp":"2021-10-26T11:52:55.000+0000","FinServ__Amount__c":10.0,"FinServ__Date__c":"2021-10-26","mflow__DeleteRecord__c":false}]}}';
ApexRequest request = new ApexRequest();
Request.data = js;
request.token = SecurityUtils.generateTokenForTesting(
  '0010p000011AFiIAAW',
  '',
  'Primary',
  'ApplicationFlow'
);
ApexResponse res = ApplicantController.saveApplicant(request);
system.debug('Full Json : ' + res.data);

// generateOTP
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0016D00000aYc5zQAC',
  '',
  'Primary',
  'ApplicationFlow'
);
request.setHeader(
  new Map<String, String>{
    'applicantId' => 'a0b6D0000022poMQAQ',
    'otpMode' => 'EMAIL;SMS'
  }
);
ApexResponse res = ApplicantController.generateOTP(request);
system.debug('Full Json : ' + res.data);

// validateOTP
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0016D00000aYc5zQAC',
  '',
  'Primary',
  'ApplicationFlow'
);
request.setHeader(
  new Map<String, String>{
    'applicantId' => 'a0b6D0000022poMQAQ',
    'otpMode' => 'EMAIL;SMS',
    'sms' => '5468',
    'email' => '9269'
  }
);
ApexResponse res = ApplicantController.validateOTP(request);
system.debug('Full Json : ' + res.data);

// Method to authenticate AtomicFI token
ApexRequest request = new ApexRequest();
request.setHeader(
 new Map<String, String>{ 'applicantId' => 'a0b1y000001NMpiAAG','employerId' => 'a0A1y0000029HgVEAU' }
);
ApexResponse res = ApplicantController.atomicAuthenticate(request);

system.debug('Full Json : ' + res.data);

// Method to get json  of an employer
ApexRequest request = new ApexRequest();
request.setHeader(
  new Map<String, String>{
    'applicantId' => 'a0b0w00000F1mMDAAZ',
    'employerId' => 'a0A0w000003hRagEAE'
  }
);
ApexResponse res = ApplicantController.getAtomicResponse(request);
system.debug('Full Json : ' + res.data);

List<AtomicFI_Employer__e> events = new List<AtomicFI_Employer__e>();
AtomicFI_Employer__e atomicFI = new AtomicFI_Employer__e();
atomicFI.ApplicantId__c = 'a0b1y000001NMpiAAG';
atomicFI.EmployerId__c = 'a0A1y0000029HgVEAU';
events.add(atomicFI);
List<Database.SaveResult> results = EventBus.publish(events);

// Inspect publishing result for each event
for (Database.SaveResult sr : results) {
  if (sr.isSuccess()) {
    System.debug('Successfully published event.');
  } else {
    for (Database.Error err : sr.getErrors()) {
      System.debug(
        'Error returned: ' +
        err.getStatusCode() +
        ' - ' +
        err.getMessage()
      );
    }
  }
}

// To generate Payslips and W2
ApexRequest request = new ApexRequest();
request.setHeader(
  new Map<String, String>{ 'applicantId' => 'a0b1y000001NMpiAAG','employerId' => 'a0A1y0000029HgVEAU' }
);
ApexResponse res = ApplicantController.generatePaySlipsW2(request);

system.debug('Payslips and W2 : ' + res);

}
