/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier,PMD.ExcessiveParameterList')
global with sharing class FileDTO {
  global String title { get; private set; }
  global String pathOnClient { get; private set; }
  global Blob versionData { get; set; }
  global Id ownerID { get; set; }
  global Id parentID { get; private set; }
  global Id contentDocumentId { get; private set; }
  global String fileType { get; private set; }
  global String fileSubType { get; set; }
  global FileShareType shareType { get; set; }
  global FileVisibility visibility { get; set; }

  /**
   * V Viewer permission. The user can explicitly view but not edit the shared file.
   * C Collaborator permission. The user can explicitly view and edit the shared file.
   * I Inferred permission. The user’s permission is determined by the related record.
   * For shares with a library, this is defined by the permissions the user has in that library.
   * Inferred permission on shares with libraries and file owners is available in API versions 21.0 and later.
   * Inferred permission on shares with standard objects is available in API versions 36.0 and later.
   **/
  global enum FileShareType {
    I,
    V,
    C
  }

  /**
   * Visibility can have the following values.
   * AllUsers—The file is available to all users who have permission to see the file.
   * InternalUsers—The file is available only to internal users who have permission to see the file.
   * SharedUsers—The file is available to all users who can see the feed to which the file is posted.
   * SharedUsers is used only for files shared with users, and is available only when an org has private org-wide sharing on by default.
   * The SharedUsers value is available in API version 32.0 and later.
   **/
  global enum FileVisibility {
    AllUsers,
    InternalUsers,
    SharedUsers
  }

  /**
   * @description
   * @author Digital Align Team | 11-10-2021
   * @param Id contentDocumentId
   * @param Id parentID
   **/
  global FileDTO(Id contentDocumentId, Id parentID) {
    this.contentDocumentId = contentDocumentId;
    this.parentID = parentID;
    this.shareType = FileShareType.V;
    this.visibility = FileVisibility.AllUsers;
  }

  /**
   * @description
   * @author Digital Align Team | 07-29-2021
   * @param String title
   * @param Blob versionData
   * @param Id parentID
   **/
  global FileDTO(String title, Blob versionData, Id parentID) {
    this.title = title;
    this.pathOnClient = title;
    this.versionData = versionData;
    this.parentID = parentID;
    this.shareType = FileShareType.V;
    this.visibility = FileVisibility.AllUsers;
  }

  /**
   * @description
   * @author Digital Align Team | 07-29-2021
   * @param String title
   * @param Blob versionData
   * @param Id parentID
   * @param String fileType
   **/
  global FileDTO(String title, Blob versionData, Id parentID, String fileType) {
    this.title = title;
    this.pathOnClient = title;
    this.versionData = versionData;
    this.parentID = parentID;
    this.fileType = fileType;
    this.shareType = FileShareType.V;
    this.visibility = FileVisibility.AllUsers;
  }

  /**
   * @description
   * @author Digital Align Team | 07-29-2021
   * @param String title
   * @param Blob versionData
   * @param Id parentID
   * @param String fileType
   * @param String fileSubType
   **/
  global FileDTO(
    String title,
    Blob versionData,
    Id parentID,
    String fileType,
    String fileSubType
  ) {
    this.title = title;
    this.pathOnClient = title;
    this.versionData = versionData;
    this.parentID = parentID;
    this.fileType = fileType;
    this.fileSubType = fileSubType;
    this.shareType = FileShareType.V;
    this.visibility = FileVisibility.AllUsers;
  }
}
