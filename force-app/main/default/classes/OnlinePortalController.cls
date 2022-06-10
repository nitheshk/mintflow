/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OnlinePortalController extends AbstractController {
  private static logger log = logger.getInstance(OnlinePortalController.class);
  public OnlinePortalController() {
    super(OnlinePortalController.class);
  }

  global OnlinePortalController(AbstractController controller) {
    super(OnlinePortalController.class);
  }

  /**
   * @description
   * @author Digital Align Team | 06-02-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  @RemoteAction
  global static ApexResponse productSelector(ApexRequest request) {
    try {
      validateRequest(request, true);
      return ApexResponse.ok(ProductService.getInstance().productSelector());
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    }
  }

  /**
   * @description
   * @author Digital Align Team | 06-06-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @RemoteAction
  global static ApexResponse onlinePortalAuthenticate(ApexRequest request) {
    try {
      validateRequest(request, true);
      return ApexResponse.ok(AuthenticationService.getInstance().onlinePortalAuthenticate(ApexRequest.getParams()));
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Finished onlinePortalAuthenticate');
      Logger.persist();
    }
  }

  /**
   * @description
   * @author Digital Align Team | 06-08-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @RemoteAction
  global static ApexResponse onlinePortalAuthorize(ApexRequest request) {
    try {
      validateRequest(request, true);
      return ApexResponse.ok(AuthenticationService.getInstance().onlinePortalAuthorize(ApexRequest.getParams()));
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Finished onlinePortalAuthorize');
      Logger.persist();
    }
  }

  /**
   * @description
   * @author Digital Align Team | 06-08-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @RemoteAction
  global static ApexResponse fetchMyApplication(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.ok(CustomerPortalService.getInstance().fetchMyApplication());
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Finished fetchMyApplication');
      Logger.persist();
    }
  }

  /**
   * @description
   * @author Digital Align Team | 06-09-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @RemoteAction
  global static ApexResponse readApplicationWithChild(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.ok(CustomerPortalService.getInstance().readApplicationWithChild(ApexRequest.getParams()));
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Finished readApplication');
      Logger.persist();
    }
  }
}
