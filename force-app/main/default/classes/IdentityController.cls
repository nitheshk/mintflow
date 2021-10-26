/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class IdentityController extends AbstractController {
  @AuraEnabled
  @RemoteAction
  global static ApexResponse verifyCounty(Map<String, object> params) {
    try {
      object res = IdentityService.getInstance().verifyCounty(params);
      if (res != null) {
        return ApexResponse.ok(res);
      } else {
        return ApexResponse.fail(res);
      }
    } catch (CustomException ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    }
  }
  global static ApexResponse scanDL(Map<String, object> params) {
    try {
      return ApexResponse.ok(IdentityService.getInstance().scanDL(params));
    } catch (CustomException ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    }
  }
}
