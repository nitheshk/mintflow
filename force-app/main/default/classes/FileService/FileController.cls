/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description File Manager COntroller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FileController extends AbstractController {
  private static logger log = logger.getInstance(IdentityController.class);
  /**
   * @description fetch Content Version By Entity Id
   * Params : Id entityId, Boolean ignoreVersionData
   * @author Digital Align Team | 09-13-2021
   * @param Id entityId
   * @param Boolean ignoreVersionData
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse fetchContentVersionByEntityId(
    ApexRequest request
  ) {
    try {
      // Upsert dealer record
      log?.fine('Inside fetchContentVersionByEntityId');
      validateRequest(request);
      ID entityId = (ID) ApexRequest.getParams('entityId');
      Boolean ignoreVersionData = ApexRequest.getParams('ignoreVersionData') !=
        null
        ? (Boolean) ApexRequest.getParams('ignoreVersionData')
        : true;
      return ApexResponse.ok(
        FileService.getInstance()
          .fetchContentVersionByEntityId(entityId, ignoreVersionData)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete fetchContentVersionByEntityId');
      Logger.persist();
    }
  }

  /**
   * @description delete content version by content documetn id
   * Params : ID contentDocumentId
   * @author Digital Align Team | 09-13-2021
   * @param Id contentDocumentId
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse deleteContentVersion(ApexRequest request) {
    try {
      log?.fine('Inside deleteContentVersion');
      validateRequest(request);
      ID contentDocumentId = (ID) ApexRequest.getParams('contentDocumentId');
      FileService.getInstance().deleteContentVersion(contentDocumentId);
      return ApexResponse.ok(null);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete deleteContentVersion');
      Logger.persist();
    }
  }

  /**
   * @description generate public url for file
   * @author Digital Align Team | 09-13-2021
   * @param Id contentVersionId
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse generatePublicUrl(ApexRequest request) {
    try {
      log?.fine('Inside generatePublicUrl');
      validateRequest(request);
      ID contentVersionId = (ID) ApexRequest.getParams('contentVersionId');
      return ApexResponse.ok(
        FileService.getInstance().generatePublicUrl(contentVersionId)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete generatePublicUrl');
      Logger.persist();
    }
  }
}
