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

///

FileService.getInstance().deleteContentVersionByEntityId('0061y000003yIldAAE');

//

List<ContentVersion> cvs = FileService.getInstance()
  .fetchContentVersionByEntityId('00Q1y000001aBC3EAM', false);

System.debug(' cvs  : ' + JSON.serialize(cvs));
