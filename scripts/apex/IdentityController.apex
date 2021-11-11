// generateOTP
ApexRequest request = new ApexRequest();
request.setHeader(
  new Map<String, String>{ 'applicantId' => 'a0b9D000002h0JcQAI' }
);
ApexResponse res = IdentityController.generateOTP(request);
system.debug('Full Json : ' + res.data);

// validateOTP
ApexRequest request = new ApexRequest();
request.setHeader(
  new Map<String, String>{
    'applicantId' => 'a0b9D000002h0JcQAI',
    'sms' => '9458',
    'email' => '9567'
  }
);
ApexResponse res = IdentityController.validateOTP(request);
system.debug('Full Json : ' + res.data);

// IdentityController.scanIdentityDocument
ApexRequest request = new ApexRequest();
request.setApplicationId('0019D00000IVnGrQAL'); //account ID
request.setHeader(
  new Map<String, Object>{ 'contentDocumentId' => '0019D00000IVnGrWRF' }
);
ApexResponse res = IdentityController.scanIdentityDocument(request);
system.debug('res=+' + JSON.serialize(res));
