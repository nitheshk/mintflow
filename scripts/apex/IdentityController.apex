/** Geocoding */
//Generate Token first and use in the next method, for api call
System.debug(
  SecurityUtils.generateTokenForTesting(
    '0010p000011AFiIAAW',
    '',
    'Primary',
    'ApplicationFlow'
  )
);
//random input // ERROR OUTPUT
ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFONvS2ENRY3tJ2dmX4xaGrQZeoO8jqZp2PUltZQE0PkmlWbAj/kvtSqjKVPiVhCpQ0timwgg9ICys9ycH6hGX+H6bnTSpKIvp0IuNCunKqMPsAvcuXPdI9LAVkW2mM0sig8pkN5XlLalSGuZuWZuHGM=';
request.setHeader(new Map<String, String>{ 'zipcode' => '*^' });
ApexResponse res = IdentityController.verifyCounty(request);
system.debug('res=+' + JSON.serialize(res));

// not eligible zipcode
ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFONvS2ENRY3tJ2dmX4xaGrQZeoO8jqZp2PUltZQE0PkmlWbAj/kvtSqjKVPiVhCpQ0timwgg9ICys9ycH6hGX+H6bnTSpKIvp0IuNCunKqMPsAvcuXPdI9LAVkW2mM0sig8pkN5XlLalSGuZuWZuHGM='; //account ID
request.setHeader(new Map<String, String>{ 'zipcode' => '10001' });
ApexResponse res = IdentityController.verifyCounty(request);
system.debug('res=+' + JSON.serialize(res));

//eligible zipcode
ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFONvS2ENRY3tJ2dmX4xaGrQZeoO8jqZp2PUltZQE0PkmlWbAj/kvtSqjKVPiVhCpQ0timwgg9ICys9ycH6hGX+H6bnTSpKIvp0IuNCunKqMPsAvcuXPdI9LAVkW2mM0sig8pkN5XlLalSGuZuWZuHGM='; //account ID
request.setHeader(new Map<String, String>{ 'zipcode' => '98013' });
ApexResponse res = IdentityController.verifyCounty(request);
system.debug('res=+' + JSON.serialize(res));

/** ID Analyser */

// #1 IdentityController.scanIdentityDocument
ApexRequest request = new ApexRequest();
request.applicationId = '0019D00000IVnGrQAL'; //account ID
request.setHeader(
  new Map<String, Object>{ 'contentDocumentId' => '0019D00000IVnGrWRF' }
);
ApexResponse res = IdentityController.scanIdentityDocument(request);
system.debug('res=+' + JSON.serialize(res));

// #2

//Working
ApexRequest request = new ApexRequest();
request.applicationId = '0019D00000IVnGrQAL'; //account ID
request.setHeader(
  new Map<String, String>{ 'contentDocumentId' => '0699D000000k1TBQAY' }
);
ApexResponse res = IdentityController.scanIdentityDocument(request);
system.debug('res = ' + Json.serialize(res));

// #3

ContentVersion cv = FileService.getInstance()
  .fetchContentVersionByCD('0699D000000k1TBQAY', false);
DocumentScanDTO.Request requestDTO = new DocumentScanDTO.Request();
requestDTO.file_base64 = EncodingUtil.base64Encode(cv.VersionData);
requestDTO.apikey = 'rfdNfcbatBLzmdtTHqVaMLphOQQdLNw2';
requestDTO.authenticate = 'true';
requestDTO.authenticate_module = '2';
requestDTO.verify_expiry = 'true';
requestDTO.dualsidecheck = 'true';
Map<String, String> header = new Map<String, String>();
header.put('Content-Type', 'application/json');
header.put('Accept', 'application/json');
HttpBuilder.setAPISetting(APINames.IdScanAnalyzer);
HttpResponse response = HttpBuilder.httpCallOut(
  Json.serialize(requestDTO),
  header
);
