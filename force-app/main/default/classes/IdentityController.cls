/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class IdentityController extends AbstractController {
  private static logger log = logger.getInstance(IdentityController.class);
  //Allow to expose the controller in Visualforce remoting
  global IdentityController(AbstractController controller) {
    super(IdentityController.class);
  }
  /**
   * @description verify county eligibility
   * @author Digital Align Team | 11-01-2021
   * @param Map<String object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse verifyCounty(ApexRequest request) {
    try {
      log?.fine('Inside verifyCounty');
      validateRequest(request);
      return ApexResponse.ok(
        IdentityService.getInstance().verifyCounty(ApexRequest.getParams())
      );
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete verifyCounty');
      Flow.finalize();
      Logger.persist();
    }
  }

  /**
   * @description Document Scan functionality for identity verify
   * @author Digital Align Team | 11-01-2021
   * @param Map<String object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse scanIdentityDocument(ApexRequest request) {
    try {
      log?.fine('Inside scanIdentityDocument');
      validateRequest(request);
      return ApexResponse.ok(
        IdentityService.getInstance()
          .scanIdentityDocument(ApexRequest.getParams())
      );
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete scanIdentityDocument');
      Flow.finalize();
      Logger.persist();
    }
  }

  /**
   * @description SentiLink's synthetic fraud and identity theft solutions
   * @author Digital Align Team | 11-01-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse identityVerify(ApexRequest request) {
    try {
      log?.fine('Inside identityVerify');
      validateRequest(request);
      return ApexResponse.ok(
        IdentityService.getInstance().identityVerify(ApexRequest.getParams())
      );
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete identityVerify');
      Logger.persist();
    }
  }

  /**
   * @description generate Url For Identity Upload
   * @author Digital Align Team | 02-08-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse generateUrlForIdentityUpload(ApexRequest request) {
    try {
      log?.fine('Inside generateUrlForIdentityUpload');
      validateRequest(request);
      return ApexResponse.ok(
        IdentityService.getInstance()
          .generateUrlForIdentityUpload(ApexRequest.getApplicantId())
      );
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete generateUrlForIdentityUpload');
      Logger.persist();
    }
  }

  /**
   * @description generate Url For Identity Upload
   * @author Digital Align Team | 02-08-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse customerDueDiligence(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.ok(
        IdentityService.getInstance()
          .customerDueDiligence(ApexRequest.getParams())
      );
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete customerDueDiligence');
      Logger.persist();
      Flow.finalize();
    }
  }
}
