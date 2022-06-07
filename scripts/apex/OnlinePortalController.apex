ApexRequest request = new ApexRequest();
request.setHeader(
  new Map<String, String>{ 'lastName' => 'Griffin', 'email' => 'nithesh.k@digitalalign.com', 'ssn' => '4545454545' }
);
ApexResponse res = OnlinePortalController.onlinePortalAuthenticate(request);
system.debug('Full Json : ' + res.data);
