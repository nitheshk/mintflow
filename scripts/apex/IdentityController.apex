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
