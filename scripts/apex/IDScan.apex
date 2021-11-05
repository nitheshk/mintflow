//Working
ApexRequest request = new ApexRequest();
request.setApplicationId('0019D00000IVnGrQAL'); //account ID
request.setHeader(
  new Map<String, String>{ 'contentDocumentId' => '0699D000000k1TBQAY' }
);
ApexResponse res = IdentityController.scanIdentityDocument(request);
system.debug('res = ' + Json.serialize(res));

//

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
