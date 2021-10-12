/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description main application controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicationController extends AbstractController {
  public ApplicationController(AbstractController controller) {
  }
  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse startApplication(Map<String, String> params) {
    try {
      return ApexResponse.ok(
        ApplicationService.getInstance().startApplication(params)
      );
    } catch (CustomException ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    }
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse createLead(Map<String, String> params) {
    try {
      return ApexResponse.success(
        ApplicationService.getInstance().createLead(params)
      );
    } catch (CustomException ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    }
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse resumeApplication(Map<String, String> params) {
    try {
      return ApexResponse.ok(
        ApplicationService.getInstance().resumeApplication(params)
      );
    } catch (CustomException ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    }
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse readLead(Map<String, String> params) {
    try {
      return ApexResponse.success(
        ApplicationService.getInstance().readLead(params)
      );
    } catch (CustomException ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    }
  }

  /**
   * @description
   * @author Digital Align Team | 10-05-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse saveLead(Map<String, String> params) {
    try {
      Lead leadObj = ApplicationService.getInstance().saveLead(params);
      return ApexResponse.success(leadObj);
    } catch (CustomException ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    }
  }
}
