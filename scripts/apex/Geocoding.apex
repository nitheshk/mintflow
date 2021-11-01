//random input
ApexRequest request = new ApexRequest();
request.setApplicationId('0019D00000IVnGrQAL'); //account ID
request.setHeader(new Map<String, String>{ 'zipcode' => '*^' });
ApexResponse res = IdentityController.verifyCounty(request);
system.debug('res=+' + JSON.serialize(res));

// not eligible zipcode
ApexRequest request = new ApexRequest();
request.setApplicationId('0019D00000IVnGrQAL'); //account ID
request.setHeader(new Map<String, String>{ 'zipcode' => '10001' });
ApexResponse res = IdentityController.verifyCounty(request);
system.debug('res=+' + JSON.serialize(res));

//eligible zipcode
ApexRequest request = new ApexRequest();
request.setApplicationId('0019D00000IVnGrQAL'); //account ID
request.setHeader(new Map<String, String>{ 'zipcode' => '98013' });
ApexResponse res = IdentityController.verifyCounty(request);
system.debug('res=+' + JSON.serialize(res));
