/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description main application controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicationController extends AbstractController {
  private static logger log = logger.getInstance(ApplicationController.class);

  public ApplicationController(AbstractController controller) {
    super(ApplicationController.class);
  }
  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse startApplication(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.ok(
        ApplicationService.getInstance()
          .startApplication(ApexRequest.getParams())
      );
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
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
  global static ApexResponse readApplicationWithChild(ApexRequest request) {
    try {
      validateRequest(request);
      Id applicationId = (Id) ApexRequest.getParams().get('applicationId');
      return ApexResponse.success(
        ApplicationService.getInstance().readApplicationWithChild(applicationId)
      );
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
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
  global static ApexResponse saveApplication(ApexRequest request) {
    try {
      validateRequest(request);
      log?.debug('params : ' + ApexRequest.request.params);
      Account applicationObj = (Account) Json.deserialize(
        request.data,
        Account.class
      );
      applicationObj = ApplicationPersistService.getInstance()
        .saveApplication(applicationObj);

      return ApexResponse.success(applicationObj);
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
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
  global static ApexResponse resumeApplication(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.ok(
        ApplicationService.getInstance()
          .resumeApplication(ApexRequest.getParams())
      );
    } catch (CustomException ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }
}
