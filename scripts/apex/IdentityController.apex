// IdentityController.scanIdentityDocument
ApexRequest request = new ApexRequest();
request.setApplicationId('0019D00000IVnGrQAL'); //account ID
request.setHeader(
  new Map<String, Object>{ 'contentDocumentId' => '0019D00000IVnGrWRF' }
);
ApexResponse res = IdentityController.scanIdentityDocument(request);
system.debug('res=+' + JSON.serialize(res));
