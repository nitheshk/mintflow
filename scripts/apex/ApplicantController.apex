// calling read method
ApexRequest request = new ApexRequest();
request.setHeader(
  new Map<String, String>{ 'applicantId' => 'a0b9D000002h0JcQAI' }
);
ApexResponse res = ApplicantController.generateOTP(request);
system.debug('Full Json : ' + res.data);
