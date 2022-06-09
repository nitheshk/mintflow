//#1  onlinePortalAuthenticate
ApexRequest request = new ApexRequest();
request.setHeader(
  new Map<String, String>{ 'lastName' => 'Griffin', 'email' => 'nithesh.k@digitalalign.com', 'ssn' => '4545454545' }
);
ApexResponse res = OnlinePortalController.onlinePortalAuthenticate(request);
system.debug('Full Json : ' + res.data);

//#2 onlinePortalAuthorize
ApexRequest request = new ApexRequest();
request.setHeader(new Map<String, String>{ 'sessionId' => 'a0R1y000000o0jbEAA', 'email' => '4481' });
ApexResponse res = OnlinePortalController.onlinePortalAuthorize(request);
system.debug('Full Json : ' + res.data);

//#3 fetchMyApplication
ApexRequest request = new ApexRequest();
request.token = 'P8L+tCdmyoH2weWniLVjsd0z9qxDud7mcwxA4LbFVFcZoioxfqaygm+fg0Odk4oJeB0mH437Z42Bf5VeDHPxgcAVWWE6cAbBJnrzywxXBukGLjcs25NQWQ2B+43YBWq7h6uUWVmpO/dhG2ZqxkFL5g==';
ApexResponse res = OnlinePortalController.fetchMyApplication(request);
system.debug('Full Json : ' + res.data);
