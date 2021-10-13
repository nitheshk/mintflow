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
  global static ApexResponse verifyCounty(Map<String, String> params) {
    try {
      return ApexResponse.ok(
        IdentityService.getInstance().verifyCounty(params)
      );
    } catch (CustomException ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    }
  }
}
