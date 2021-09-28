/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description File Manager COntroller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FileController {
  /**
   * @description fetch Content Version By Entity Id
   * @author Digital Align Team | 09-13-2021
   * @param Id entityId
   * @param Boolean ignoreVersionData
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse fetchContentVersionByEntityId(
    Id entityId,
    Boolean ignoreVersionData
  ) {
    try {
      // Upsert dealer record
      return ApexResponse.ok(
        FileService.getInstance()
          .fetchContentVersionByEntityId(entityId, ignoreVersionData)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description delete content version by content documetn id
   * @author Digital Align Team | 09-13-2021
   * @param Id contentDocumentId
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse deleteContentVersion(Id contentDocumentId) {
    try {
      FileService.getInstance().deleteContentVersion(contentDocumentId);
      return ApexResponse.ok(null);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description generate public url for file
   * @author Digital Align Team | 09-13-2021
   * @param Id contentVersionId
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse generatePublicUrl(Id contentVersionId) {
    try {
      return ApexResponse.ok(
        FileService.getInstance().generatePublicUrl(contentVersionId)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }
}
