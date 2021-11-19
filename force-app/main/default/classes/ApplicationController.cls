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
      Id applicationId;
      if (String.isNotBlank(ApexRequest.getApplicationId())) {
        applicationId = (Id) ApexRequest.getApplicationId();
      } else {
        applicationId = (Id) ApexRequest.getParams().get('applicationId');
      }
      if (ApexRequest.getFlowType() == 'Primary') {
        return ApexResponse.success(
          ApplicationService.getInstance()
            .readApplicationWithChild(applicationId)
        );
      } else if (ApexRequest.getFlowType() == 'Joint') {
        return ApexResponse.success(
          ApplicationService.getInstance()
            .readApplicationWithChild(
              applicationId,
              ApexRequest.getApplicantId()
            )
        );
      }
      throw new customException('Flow not Found');
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
   * @description Save Application record
   * @author Digital Align Team | 10-05-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse saveApplication(ApexRequest request) {
    Savepoint sp = Database.setSavepoint();
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
      Database.rollback(sp);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      Database.rollback(sp);
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }

  /**
   * @description delete any record by id
   * Header need to pass with recordId key need to delete
   * @author Digital Align Team | 10-28-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse deleteEntity(ApexRequest request) {
    Savepoint sp = Database.setSavepoint();
    try {
      validateRequest(request);
      Id recordId = (Id) ApexRequest.getParams('recordId');
      return ApexResponse.ok(
        ApplicationPersistService.getInstance().deleteEntity(recordId)
      );
    } catch (CustomException ex) {
      log?.error(ex);
      Database.rollback(sp);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      Database.rollback(sp);
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }

  /**
   * @description review information submit
   * Send email to primary and joint applicant for start application
   * @author Digital Align Team | 11-15-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse reviewInformationSubmit(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.success(
        ReviewInformationService.getInstance()
          .reviewInformationSubmit(ApexRequest.getApplicationId())
      );
    } catch (CustomException ex) {
      log?.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }

  /**
   * @description get new refreshed token
   * New token need to patch application/applicant respectvely
   * @author Digital Align Team | 11-18-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse refreshToken(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.success(SecurityUtils.refreshToken());
    } catch (CustomException ex) {
      log?.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }

  /**
   * @description expire token
   * @author Digital Align Team | 11-18-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse expireToken(ApexRequest request) {
    try {
      SecurityUtils.expireToken();
      return ApexResponse.ok();
    } catch (Exception ex) {
      log?.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }
}
