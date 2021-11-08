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
  global static ApexResponse scanIdentityDocument(ApexRequest request) {
    try {
      log?.fine('Inside scanIdentityDocument');
      validateRequest(request);
      return ApexResponse.success(
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
      Logger.persist();
    }
  }

  /**
   * @description SentiLink's synthetic fraud and identity theft solutions
   * @author Digital Align Team | 11-01-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  global static ApexResponse identityVerify(ApexRequest request) {
    try {
      log?.fine('Inside identityVerify');
      validateRequest(request);
      return ApexResponse.success(
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
   * @description generate otp
   * params: Id applicantId
   * @author Digital Align Team | 11-05-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse generateOTP(ApexRequest request) {
    try {
      log?.fine('Inside generateOTP');
      validateRequest(request);
      log?.debug('params : ' + ApexRequest.getParams());
      ID applicantId = (Id) ApexRequest.getParams('applicantId');
      return ApexResponse.ok(
        IdentityService.getInstance().generateOTP(applicantId)
      );
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      Flow.finalize();
      log?.fine('Completed generateOTP');
      Logger.persist();
    }
  }

  /**
   * @description validate otp for applicant
   * @author Digital Align Team | 11-05-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse validateOTP(ApexRequest request) {
    try {
      log?.fine('Inside validateOTP');
      validateRequest(request);
      log?.debug('params : ' + ApexRequest.getParams());
      return ApexResponse.ok(
        IdentityService.getInstance().validateOTP(ApexRequest.getParams())
      );
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Completed validateOTP');
      Logger.persist();
    }
  }
}
