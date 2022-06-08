//#1  onlinePortalAuthenticate
ApexRequest request = new ApexRequest();
request.setHeader(
  new Map<String, String>{ 'lastName' => 'Griffin', 'email' => 'nithesh.k@digitalalign.com', 'ssn' => '4545454545' }
);
ApexResponse res = OnlinePortalController.onlinePortalAuthenticate(request);
system.debug('Full Json : ' + res.data);

//#2 onlinePortalAuthorize
ApexRequest request = new ApexRequest();
request.setHeader(new Map<String, String>{ 'sessionId' => 'a0R1y000000o0HtEAI', 'email' => '2442' });
ApexResponse res = OnlinePortalController.onlinePortalAuthorize(request);
system.debug('Full Json : ' + res.data);
