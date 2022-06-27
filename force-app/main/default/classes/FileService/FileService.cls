/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class FileService extends AbstractService {
  @TestVisible
  private static FileService serviceInstance;

  public FileService() {
    super(FileService.class);
  }

  /**
   * @description Provides a singleton instance of FileService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-22-2021
   * @return Object  singleton
   **/
  public static FileService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (FileService) getInstance(FileService.class);
    }
    return serviceInstance;
  }

  /**
   * @description create file using fileDto
   * @author Digital Align Team | 07-30-2021
   * @param FileDTO fileDto
   * @return ContentVersion
   * @example FileService.getInstance()
   * .createFile(
   *     new FileDTO(
   *      'testFile4.txt',
   *   blob.valueof('test'),
   *   '0061y000003yIldAAE',
   *   'Address',
   *   'Other'
   * )
   * );
   **/
  global virtual ContentVersion createFile(FileDTO fileDto) {
    ContentVersion cVersion = new ContentVersion();
    cVersion.Title = fileDto.title;
    cVersion.PathOnClient = fileDto.pathOnClient;
    cVersion.VersionData = fileDto.versionData;

    if (String.isNotBlank(fileDto.fileType)) {
      cVersion.contentType__c = fileDto.fileType;
    }
    if (String.isNotBlank(fileDto.fileSubType)) {
      cVersion.contentSubType__c = fileDto.fileSubType;
    }
    if (String.isNotBlank(fileDto.ownerID)) {
      cVersion.OwnerId = fileDto.ownerID;
    }

    FileRepository.upsertRecord(cVersion);

    String contentVersionId = cVersion.id;
    cVersion = null;

    cVersion = FileRepository.fetchContentVersionById(contentVersionId, true);

    if (String.isNotBlank(fileDto.parentID)) {
      ContentDocumentLink cDocLink = new ContentDocumentLink();
      cDocLink.ContentDocumentId = cVersion.ContentDocumentId;
      cDocLink.LinkedEntityId = fileDto.parentID;
      cDocLink.ShareType = fileDto.shareType.Name();
      cDocLink.Visibility = fileDto.visibility.Name();
      FileRepository.upsertRecord(cDocLink);
    }

    return cVersion;
  }

  /**
   * @description create a multiple file using filedto's
   * @author Digital Align Team | 07-30-2021
   * @param List<FileDTO> fileDtos
   * @return ContentVersion
   * @example  list<FileDTO> lst = new List<FileDTO>{
   * new FileDTO(
   * 'testFile4.txt',
   *  blob.valueof('test'),
   *  '0061y000003yIldAAE',
   *  'Address',
   *  'Other'
   * ),
   * new FileDTO('testFile4.txt', blob.valueof('test'), '0061y000003yIldAAE')
   * };
   * FileService.getInstance().createFiles(lst);
   **/
  global virtual List<ContentVersion> createFiles(List<FileDTO> fileDtos) {
    Map<FileDTO, ContentVersion> contentMapping = new Map<FileDTO, ContentVersion>();

    for (FileDTO fileDto : fileDtos) {
      ContentVersion cVersion = new ContentVersion();
      cVersion.Title = fileDto.title;
      cVersion.PathOnClient = fileDto.pathOnClient;
      cVersion.VersionData = fileDto.versionData;

      if (String.isNotBlank(fileDto.fileType)) {
        cVersion.contentType__c = fileDto.fileType;
      }
      if (String.isNotBlank(fileDto.fileSubType)) {
        cVersion.contentSubType__c = fileDto.fileSubType;
      }
      if (String.isNotBlank(fileDto.ownerID)) {
        cVersion.OwnerId = fileDto.ownerID;
      }
      contentMapping.put(fileDto, cVersion);
    }

    FileRepository.upsertRecords(contentMapping.values());

    Map<FileDTO, Id> contentKeyMapping = new Map<FileDTO, Id>();
    for (FileDTO fileDto : contentMapping.keySet()) {
      contentKeyMapping.put(fileDto, contentMapping.get(fileDto).Id);
      fileDto.versionData = null;
    }
    contentMapping = null;

    Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>(
      FileRepository.fetchContentVersionsByIds(contentKeyMapping.values(), true)
    );

    List<ContentDocumentLink> cDocLinks = new List<ContentDocumentLink>();
    for (FileDTO fileDto : contentKeyMapping.keySet()) {
      ContentDocumentLink cDocLink = new ContentDocumentLink();
      cDocLink.ContentDocumentId = contentVersionMap.get(contentKeyMapping.get(fileDto)).ContentDocumentId;
      cDocLink.LinkedEntityId = fileDto.parentID;
      cDocLink.ShareType = fileDto.shareType.Name();
      cDocLink.Visibility = fileDto.visibility.Name();
      cDocLinks.add(cDocLink);
    }
    FileRepository.upsertRecords(cDocLinks);

    return contentVersionMap.values();
  }

  /**
   * @description link content document id with parent SObject ids
   * @author Digital Align Team | 08-23-2021
   * @param Id contentDocumentId
   * @param List<Id> entityIds
   * @return List<ContentDocumentLink>
   **/
  global virtual List<ContentDocumentLink> linkContentDocumentWithEntity(Id contentDocumentId, List<Id> entityIds) {
    List<ContentDocumentLink> cDocLinks = new List<ContentDocumentLink>();
    for (Id entityId : entityIds) {
      ContentDocumentLink cDocLink = new ContentDocumentLink();
      cDocLink.ContentDocumentId = contentDocumentId;
      cDocLink.LinkedEntityId = entityId;
      cDocLink.ShareType = 'V';
      cDocLink.Visibility = 'AllUsers';
      cDocLinks.add(cDocLink);
    }
    FileRepository.upsertRecords(cDocLinks);
    return cDocLinks;
  }

  /**
   * @description link content document id with parent record id
   * @author Digital Align Team | 11-10-2021
   * @param List<FileDTO> fileDtos
   * @return virtual
   **/
  global virtual List<ContentDocumentLink> linkContentDocumentWithEntity(List<FileDTO> fileDtos) {
    List<ContentDocumentLink> cDocLinks = new List<ContentDocumentLink>();
    for (FileDTO dto : fileDtos) {
      ContentDocumentLink cDocLink = new ContentDocumentLink();
      cDocLink.ContentDocumentId = dto.contentDocumentId;
      cDocLink.LinkedEntityId = dto.parentID;
      cDocLink.ShareType = dto.shareType.name();
      cDocLink.Visibility = dto.visibility.name();
      cDocLinks.add(cDocLink);
    }
    FileRepository.upsertRecords(cDocLinks);
    return cDocLinks;
  }

  /**
   * @description fetch content version by content version id
   * @author Digital Align Team | 07-30-2021
   * @param Id contentVersionId
   * @param Boolean ignoreVersionData
   * @return ContentVersion
   **/
  global virtual ContentVersion fetchContentVersionById(Id contentVersionId, Boolean ignoreVersionData) {
    return FileRepository.fetchContentVersionById(contentVersionId, ignoreVersionData);
  }

  /**
   * @description fetch content version by content version ids
   * @author Digital Align Team | 07-30-2021
   * @param List<Id> contentVersionIds
   * @param Boolean ignoreVersionData
   * @return List<ContentVersion>
   **/
  global virtual List<ContentVersion> fetchContentVersionsByIds(List<Id> contentVersionIds, Boolean ignoreVersionData) {
    return FileRepository.fetchContentVersionsByIds(contentVersionIds, ignoreVersionData);
  }

  /**
   * @description fetch content version by content document id
   * @author Digital Align Team | 08-02-2021
   * @param Id contentDocumentId
   * @param Boolean ignoreVersionData
   * @return ContentVersion
   **/
  global virtual ContentVersion fetchContentVersionByCD(Id contentDocumentId, Boolean ignoreVersionData) {
    return FileRepository.fetchContentVersionByCD(contentDocumentId, ignoreVersionData);
  }

  /**
   * @description  fetch content version by content document ids
   * @author Digital Align Team | 08-02-2021
   * @param String contentDocumentIds
   * @param Boolean ignoreVersionData
   * @return List<ContentVersion>
   **/
  global virtual List<ContentVersion> fetchContentVersionsByCD(List<Id> contentDocumentIds, Boolean ignoreVersionData) {
    return FileRepository.fetchContentVersionsByCD(contentDocumentIds, ignoreVersionData);
  }

  /**
   * @description fetch content version by Linked Entity Id
   * @author Digital Align Team | 08-02-2021
   * @param Id entityId
   * @param Boolean ignoreVersionData
   * @return List<ContentVersion>
   **/
  global virtual List<ContentVersion> fetchContentVersionByEntityId(Id entityId, Boolean ignoreVersionData) {
    list<Id> contentDocumentIds = new List<Id>();
    for (ContentDocumentLink cdl : FileRepository.fetchContentDocumentLinks(entityId)) {
      contentDocumentIds.add(cdl.ContentDocumentId);
    }
    return FileRepository.fetchContentVersionsByCD(contentDocumentIds, ignoreVersionData);
  }

  /**
   * @description fetch content version by Linked list of Entity Ids
   * @author Digital Align | 12-02-2021
   * @param list<Id> entityIds
   * @param Boolean ignoreVersionData
   * @return virtual
   **/
  global virtual List<ContentVersion> fetchContentVersionByEntityIds(list<Id> entityIds, Boolean ignoreVersionData) {
    list<Id> contentDocumentIds = new List<Id>();
    for (ContentDocumentLink cdl : FileRepository.fetchContentDocumentLinks(entityIds)) {
      contentDocumentIds.add(cdl.ContentDocumentId);
    }

    return FileRepository.fetchContentVersionsByCD(contentDocumentIds, ignoreVersionData);
  }

  /**
   * @description fetch content version by entiry id and content types
   * @author Digital Align Team | 08-02-2021
   * @param Id entityId
   * @param String contentType
   * @param String contentSubType
   * @param Boolean ignoreVersionData
   * @return List<ContentVersion>
   **/
  @SuppressWarnings('PMD.ExcessiveParameterList')
  global virtual List<ContentVersion> fetchContentVersionByFileType(
    Id entityId,
    String contentType,
    String contentSubType,
    Boolean ignoreVersionData
  ) {
    list<Id> contentDocumentIds = new List<Id>();
    for (ContentDocumentLink cdl : FileRepository.fetchContentDocumentLinks(entityId)) {
      contentDocumentIds.add(cdl.ContentDocumentId);
    }
    return FileRepository.fetchContentVersions(contentDocumentIds, contentType, contentSubType, ignoreVersionData);
  }

  /**
   * @description delete content version by content documetn id
   * @author Digital Align Team | 08-02-2021
   * @param Id contentDocumentId
   **/
  global virtual void deleteContentVersion(Id contentDocumentId) {
    deleteContentVersions(new List<Id>{ contentDocumentId });
  }

  /**
   * @description delete content version by content documetn ids
   * @author Digital Align Team | 08-02-2021
   * @param List<Id> contentDocumentIds
   **/
  global virtual void deleteContentVersions(List<Id> contentDocumentIds) {
    FileRepository.deleteRecords(FileRepository.fetchContentDocument(contentDocumentIds));
  }

  /**
   * @description delete content version by  entity id
   * @author Digital Align Team | 08-02-2021
   * @param Id entityId
   * @return void
   **/
  global virtual void deleteContentVersionByEntityId(Id entityId) {
    list<Id> contentDocumentIds = new List<Id>();
    for (ContentDocumentLink cdl : FileRepository.fetchContentDocumentLinks(entityId)) {
      contentDocumentIds.add(cdl.ContentDocumentId);
    }
    deleteContentVersions(contentDocumentIds);
  }

  /**
   * @description generate public url for file
   * This function doesn't work for guest user as Profile doesn't allow to create content distribution
   * This can be resolve alternative by using platform event, Running into system mode.
   * @author Digital Align Team | 09-13-2021
   * @param Id contentVersionId
   * @return ContentDistribution
   **/
  global virtual ContentDistribution generatePublicUrl(Id contentVersionId) {
    //FileRepository.deleteRecords(FileRepository.fetchContentDistributionsById(contentVersionId));

    ContentVersion cv = FileRepository.fetchContentVersionById(contentVersionId, true);
    ContentDistribution cd = new ContentDistribution();
    cd.Name = cv.Title;
    cd.ContentVersionId = cv.id;
    cd.PreferencesAllowViewInBrowser = true;
    cd.PreferencesLinkLatestVersion = true;
    cd.PreferencesNotifyOnVisit = false;
    cd.PreferencesPasswordRequired = false;
    cd.PreferencesAllowOriginalDownload = true;
    cd.PreferencesExpires = true;
    cd.ExpiryDate = Datetime.now().addMinutes(5);
    FileRepository.upsertRecord(cd);
    return FileRepository.fetchContentDistributionById(cd.Id);
  }
}
