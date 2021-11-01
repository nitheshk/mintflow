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
  global static ApexResponse scanDL(Map<String, object> params) {
    try {
      log?.fine('Inside scanDL');
      return ApexResponse.ok(IdentityService.getInstance().scanDL(params));
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Complete scanDL');
      Logger.persist();
    }
  }
}
