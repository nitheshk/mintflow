//Working
ApexRequest request = new ApexRequest();
request.setApplicationId('0019D00000IVnGrQAL'); //account ID
request.setHeader(
  new Map<String, String>{
    'applicantId' => 'a0b9D000002h0JcQAI',
    'apiName' => 'SentiLink'
  }
);
ApexResponse res = IdentityController.identityVerify(request);
system.debug('res = ' + Json.serialize(res));

//OLD

String str = ' {"scores":[{"score_name":"sentilink_abuse_score"},{"score_name":"sentilink_first_party_synthetic_score"},{"score_name":"sentilink_third_party_synthetic_score"},{"score_name":"sentilink_id_theft_score"}],"extra_data":[{"type":"consumer_history"},{"type":"clusters"}],"application":{"phone":"3444562334","application_id":"123","zipcode":"32407","user_id":"a0b9D000002h0JcQAI","state_code":"CA","ssn":"123-45-6789","last_name":"Doe","first_name":"John","dob":"1990-01-01","country_code":"USA","city":"Pleasantville","address_line_1":"123 Main Street","email":"test@test.com"}}';
Map<String, String> header = new Map<String, String>();
header.put('Content-Type', 'application/json');
header.put('Accept', 'application/json');
header.put(
  'Authorization',
  'Basic ' +
  EncodingUtil.base64Encode(
    Blob.valueOf(
      APIConfigurationService.getAPIConstants('SentiLinkAccount') +
      ':' +
      (APIConfigurationService.getAPIConstants('SentiLinkToken'))
    )
  )
);
APIConfigurationService.setAPISettings(APINames.SentiLink);
HttpResponse response = ExternalAPICallOut.execute(str, header);
system.debug(response.getBody());

// REQUIRED FIELDS
//     LastName,
//     FirstName,
//     Company,
//     City,
//     Street,
//     PostalCode, - 5 digit
//     State, - state value should be two letter abrivation ex: CA, AA
//     Country,
//     Address,
//     Phone,
//     Email,
//     LeadSource,
//     dau01__SSN__c, 458968987 or 123-36-3698
//     dau01__Birthdate__c

