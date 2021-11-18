// #1
//FileService.getInstance().createFiles
list<FileDTO> lst = new List<FileDTO>{
  new FileDTO(
    'testFile4.txt',
    blob.valueof('test'),
    '0061y000003yIldAAE',
    'Address',
    'Other'
  ),
  new FileDTO('testFile4.txt', blob.valueof('test'), '0061y000003yIldAAE')
};

FileService.getInstance().createFiles(lst);

// #2
//FileService.getInstance().createFile
FileService.getInstance()
  .createFile(
    new FileDTO(
      'testFile4.txt',
      blob.valueof('test'),
      '0061y000003yIldAAE',
      'Address',
      'Other'
    )
  );

// #3

FileService.getInstance().deleteContentVersionByEntityId('0061y000003yIldAAE');

// #4

List<ContentVersion> cvs = FileService.getInstance()
  .fetchContentVersionByEntityId('00Q1y000001aBC3EAM', false);

System.debug(' cvs  : ' + JSON.serialize(cvs));

// #5

//FileController.fetchContentVersionByEntityId
ApexRequest request = new ApexRequest();
request.applicationId = '0019D00000IVnGrQAL'; //account ID
request.setHeader(
  new Map<String, Object>{
    'entityId' => '0019D00000IVnGrWRF',
    'ignoreVersionData' => true
  }
);
ApexResponse res = FileController.fetchContentVersionByEntityId(request);
system.debug('res=+' + JSON.serialize(res));

//#6
//FileController.createFile create content version only
ApexRequest request = new ApexRequest();
request.applicationId = '0019D00000IVnGrQAL'; //account ID
request.setHeader(
  new Map<String, Object>{
    'title' => 'test.txt',
    'fileType' => 'Address',
    'fileSubType' => 'Other'
  }
);
request.data = EncodingUtil.base64Encode(blob.valueof('test value 2'));
ApexResponse res = FileController.createFile(request);
system.debug('res=+' + JSON.serialize(res));

// #7
//FileController.fetchContentVersionByCD
ApexRequest request = new ApexRequest();
request.applicationId = '0019D00000IVnGrQAL'; //account ID
request.setHeader(
  new Map<String, Object>{
    'contentDocumentId' => '0699D000000k5r7QAA',
    'ignoreVersionData' => false
  }
);
ApexResponse res = FileController.fetchContentVersionByCD(request);
system.debug('res=+' + JSON.serialize(res));
