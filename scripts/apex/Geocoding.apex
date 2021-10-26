//random input
Map<String, object> params = new Map<String, object>();
params.put('zipcode', '*^');
system.debug('params=+' + params);
system.debug(IdentityController.verifyCounty(params));

// not eligible zipcode
Map<String, object> params = new Map<String, object>();
params.put('zipcode', '10001');
system.debug('params=+' + params);
system.debug(IdentityController.verifyCounty(params));

//eligible zipcode
Map<String, object> params = new Map<String, object>();
params.put('zipcode', '98013');
system.debug('params=+' + params);
system.debug(IdentityController.verifyCounty(params));
