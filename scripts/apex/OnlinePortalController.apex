//#1  onlinePortalAuthenticate
ApexRequest request = new ApexRequest();
request.setHeader(
  new Map<String, String>{ 'lastName' => 'PATIL', 'email' => 'nithesh.k@digitalalign.com', 'ssn' => '456455686' }
);
ApexResponse res = OnlinePortalController.onlinePortalAuthenticate(request);
system.debug('Full Json : ' + res.data);

//#2 onlinePortalAuthorize
ApexRequest request = new ApexRequest();
request.setHeader(new Map<String, String>{ 'sessionId' => 'a0R1y000000o5LnEAI', 'email' => '2612' });
ApexResponse res = OnlinePortalController.onlinePortalAuthorize(request);
system.debug('Full Json : ' + res.data);

//#3 fetchMyApplication
ApexRequest request = new ApexRequest();
request.token = 'P8L+tCdmyoH2weWniLVjsd0z9qxDud7mcwxA4LbFVFcZoioxfqaygm+fg0Odk4oJeB0mH437Z42Bf5VeDHPxgcAVWWE6cAbBJnrzywxXBukGLjcs25NQWQ2B+43YBWq7h6uUWVmpO/dhG2ZqxkFL5g==';
ApexResponse res = OnlinePortalController.fetchMyApplication(request);
system.debug('Full Json : ' + res.data);

//#4 readApplicationWithChild
ApexRequest request = new ApexRequest();
request.token = 'P8L+tCdmyoH2weWniLVjsRYYxrRAk3SO6AHEg8HaxLnRKVGxfNgQhKrShI/yxFhThudgI22nX6Lto2Zo8FGA8DHdR/4FyuibZPIu5ejgQDeakLTL6ad21mnTLzkwDZU9wD/VB7eXwFuJpiaM7K9fcQ==';
request.setHeader(new Map<String, String>{ 'applicationId' => 'a021y000007fhCRAAY' });
ApexResponse res = OnlinePortalController.readApplicationWithChild(request);
system.debug('Full Json : ' + res.data);

// #5
ApexRequest request = new ApexRequest();
request.token = 'P8L+tCdmyoH2weWniLVjsRYYxrRAk3SO6AHEg8HaxLnRKVGxfNgQhKrShI/yxFhThudgI22nX6Lto2Zo8FGA8DHdR/4FyuibZPIu5ejgQDeakLTL6ad21mnTLzkwDZU9wD/VB7eXwFuJpiaM7K9fcQ==';
request.setHeader(
  new Map<String, String>{
    'applicationId' => 'a021y000007gNoZAAU',
    'applicantId' => 'a001y000005gdNPAAY',
    'resumeType' => 'url'
  }
);
ApexResponse res = OnlinePortalController.resumeApplication(request);
system.debug('Full Json : ' + res);
