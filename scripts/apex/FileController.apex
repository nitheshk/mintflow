// #1
//FileService.getInstance().createFiles
list<FileDTO> lst = new List<FileDTO>{
  new FileDTO('testFile4.txt', blob.valueof('test'), 'a0b0p0000026aUnAAI', 'Address', 'Other'),
  new FileDTO('testFile4.txt', blob.valueof('test'), 'a0b0p0000026aUnAAI')
};

FileService.getInstance().createFiles(lst);

// #2
//FileService.getInstance().createFile
FileService.getInstance()
  .createFile(new FileDTO('testFile4.txt', blob.valueof('test'), '0010p000011AG7oAAG', 'Address', 'Other'));

// #3

FileService.getInstance().deleteContentVersionByEntityId('a0b0p0000026aUnAAI');

// #4

List<ContentVersion> cvs = FileService.getInstance().fetchContentVersionByEntityId('0010p000011AG7oAAG', false);

System.debug(' cvs  : ' + JSON.serialize(cvs));

// #5

//FileController.fetchContentVersionByEntityId
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting('0010p000011AG7oAAG', '', 'Primary', 'ApplicationFlow');
request.setHeader(new Map<String, Object>{ 'entityId' => '0010p000011AG7oAAG', 'ignoreVersionData' => true });
ApexResponse res = FileController.fetchContentVersionByEntityId(request);
system.debug('res=+' + JSON.serialize(res));

//#6
//FileController.createFile create content version only
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting('0010p000011AG7oAAG', '', 'Primary', 'ApplicationFlow');
request.setHeader(new Map<String, Object>{ 'title' => 'test.txt', 'fileType' => 'Address', 'fileSubType' => 'Other' });
request.data = EncodingUtil.base64Encode(blob.valueof('test value 2'));
ApexResponse res = FileController.createFile(request);
system.debug('res=+' + JSON.serialize(res));

// #7
//FileController.fetchContentVersionByCD
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting('0016D00000ZBBd7QAH', '', 'Primary', 'ApplicationFlow');
request.setHeader(new Map<String, Object>{ 'contentDocumentId' => '0696D0000018Lo2QAE', 'ignoreVersionData' => false });
ApexResponse res = FileController.fetchContentVersionByCD(request);
system.debug('res=+' + JSON.serialize(res));

//FileController.generatePublicUrl
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  'a02N000000MvBUqIAN',
  'a00N000000REIJIIA5',
  'Primary',
  'ApplicationFlow'
);
request.setHeader(new Map<String, Object>{ 'contentVersionId' => '068N0000002HZC9IAO' });
ApexResponse res = FileController.generatePublicUrl(request);
system.debug('res=+' + res);
