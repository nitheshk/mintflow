/** Geocoding */
//Generate Token first and use in the next method, for api call
System.debug(
  SecurityUtils.generateTokenForTesting(
    '0010p000011QD8gAAG',
    '',
    'Primary',
    'ApplicationFlow'
  )
);
//random input // ERROR OUTPUT
ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFONvS2ENRY3tJ2dmX4xaGrScR/dDv6vV/U+HjLxYevBFbpCs3ToDb5moQBSTdlrmktUu4u0YeGEGTdACKbKBa5lpUH3YSa/TpoTFcqpsJUCSOTK4vaIChw50J9JXAAgKSo4XNcF9h39b8y2ZPnADJyU=';
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

// #6 Senti LInk
ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFONvS2ENRY3tJ2dmX4xaGrQZeoO8jqZp2PUltZQE0PkmlWbAj/kvtSqjKVPiVhCpQ0timwgg9ICys9ycH6hGX+H6bnTSpKIvp0IuNCunKqMPsAvcuXPdI9LAVkW2mM0sig8pkN5XlLalSGuZuWZuHGM='; //account ID
request.setHeader(
  new Map<String, String>{
    'applicantId' => 'a0b9D000002h0JcQAI',
    'apiName' => 'SentiLink'
  }
);
ApexResponse res = IdentityController.identityVerify(request);
system.debug('res = ' + Json.serialize(res));

/** ID Analyser */

// #1 IdentityController.scanIdentityDocument
// fetch contentdocumentID using linkedentityId
system.debug(
  'contentDocumentId =' +
  [
    SELECT Id, LinkedEntityId, ContentDocumentId
    FROM ContentDocumentLink
    WHERE LinkedEntityId = 'a0b0p000001z1FxAAI'
  ]
);

ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFONvS2ENRY3tJ2dmX4xaGrR1nXcH8qwKdFkdKwFlfD+cnoAUbF1h0HCatmkzQMQAbz608qnwz7prUNEUNYXXEEL+hTq+4tLonoOQ7nUK5fgWsi+PM/6kFWf+sntxUJQVdS3DoXpEsTS/uejZfR8+6eg='; //account ID
request.setHeader(
  new Map<String, Object>{
    'frontImageDocumentId' => '0690p000000khg7AAA',
    'backImageDocumentId' => '0690p000000ki2rAAA'
  }
);
ApexResponse res = IdentityController.scanIdentityDocument(request);
system.debug('res=' + JSON.serialize(res));

// #2

//Working
ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFONvS2ENRY3tJ2dmX4xaGrQZeoO8jqZp2PUltZQE0PkmlWbAj/kvtSqjKVPiVhCpQ0timwgg9ICys9ycH6hGX+H6bnTSpKIvp0IuNCunKqMPsAvcuXPdI9LAVkW2mM0sig8pkN5XlLalSGuZuWZuHGM='; //account ID
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

//### generateUrlForIdentityUpload

ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '0011y00000OVagqAAD',
  'a0a1y000001Ydh0AAC',
  'Primary',
  'ApplicationFlow'
);
system.debug(request.token);

ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFK47w+KxidbycgQrn9aXie+QT6+YgtnCTP1gEveFYPIBLXMxI8q9nD2C7CbaP8VumD+1GuqZp4AuYQh0lmTpo0Ke3Axkr+j+7n5V96a16xhWcnfkz5BOLonsFgcx1nMjHg=='; //account ID

ApexResponse res = IdentityController.generateUrlForIdentityUpload(request);
system.debug('Full Json : ' + res.data);
