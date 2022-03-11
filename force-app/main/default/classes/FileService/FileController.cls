/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description File Manager COntroller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FileController extends AbstractController {
  private static Logger log = Logger.getInstance(IdentityController.class);

  global FileController(AbstractController controller) {
    super(FileController.class);
  }
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
  global static ApexResponse fetchContentVersionByEntityId(ApexRequest request) {
    try {
      // Upsert dealer record
      log?.fine('Inside fetchContentVersionByEntityId');
      validateRequest(request);
      Id entityId = (Id) ApexRequest.getParams('entityId');
      Boolean ignoreVersionData = ApexRequest.getParams('ignoreVersionData') != null
        ? (Boolean) ApexRequest.getParams('ignoreVersionData')
        : true;
      return ApexResponse.ok(FileService.getInstance().fetchContentVersionByEntityId(entityId, ignoreVersionData));
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
      Id contentDocumentId = (Id) ApexRequest.getParams('contentDocumentId');
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
  @RemoteAction
  global static ApexResponse generatePublicUrl(ApexRequest request) {
    try {
      log?.fine('Inside generatePublicUrl');
      validateRequest(request);
      Id contentVersionId = (Id) ApexRequest.getParams('contentVersionId');
      return ApexResponse.ok(FileService.getInstance().generatePublicUrl(contentVersionId));
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete generatePublicUrl');
      Logger.persist();
    }
  }

  /**
   * @description create file
   * params: String title,String parentID,String fileType,Stirng fileSubType
   * data : base64 String
   * @author Digital Align Team | 11-05-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse createFile(ApexRequest request) {
    try {
      log?.fine('Inside createFile');
      validateRequest(request);
      FileDTO dto = new FileDTO(
        (String) ApexRequest.getParams('title'),
        EncodingUtil.base64Decode((String) JSON.deserialize(request.data, String.class)),
        (String) ApexRequest.getParams('parentID'),
        (String) ApexRequest.getParams('fileType'),
        (String) ApexRequest.getParams('fileSubType')
      );
      if (ApexRequest.getParams('shareType') != null) {
        dto.shareType = FileDTO.FileShareType.valueOf((String) ApexRequest.getParams('shareType'));
      }
      if (ApexRequest.getParams('visibility') != null) {
        dto.visibility = FileDTO.FileVisibility.valueOf((String) ApexRequest.getParams('visibility'));
      }
      return ApexResponse.ok(FileService.getInstance().createFile(dto));
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete createFile');
      Logger.persist();
    }
  }

  /**
   * @description fetch content version by content document Id
   * Params : Id contentDocumentId, Boolean ignoreVersionData
   * @author Digital Align Team | 11-05-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse fetchContentVersionByCD(ApexRequest request) {
    try {
      log?.fine('Inside fetchContentVersionByCD');
      validateRequest(request);
      Id contentDocumentId = (Id) ApexRequest.getParams('contentDocumentId');
      Boolean ignoreVersionData = ApexRequest.getParams('ignoreVersionData') != null
        ? (Boolean) ApexRequest.getParams('ignoreVersionData')
        : true;
      return ApexResponse.ok(FileService.getInstance().fetchContentVersionByCD(contentDocumentId, ignoreVersionData));
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete fetchContentVersionByCD');
      Logger.persist();
    }
  }
}
