Map<String, object> params = new Map<String, object>();
params.put('zipcode', '98013');
system.debug('params=+' + params);
system.debug(GeocodingProvider.invokeAPI(params));
