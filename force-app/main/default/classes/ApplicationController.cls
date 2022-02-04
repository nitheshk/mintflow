/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description main application controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicationController extends AbstractController {
  private static Logger log = Logger.getInstance(ApplicationController.class);

  public ApplicationController(AbstractController controller) {
    super(ApplicationController.class);
  }
  /**
   * @description Generate start application url
   * @author Digital Align Team | 09-29-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse startApplication(ApexRequest request) {
    try {
      validateRequest(request, true);
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
   * @description Read Full Application with with child record
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

      log?.debug('request' + request);
      Account application;
      if (ApexRequest.getApplicantType() == 'Primary') {
        application = ApplicationService.getInstance()
          .readApplicationWithChild(applicationId);
      } else if (ApexRequest.getApplicantType() == 'Joint') {
        application = ApplicationService.getInstance()
          .readApplicationWithChild(
            applicationId,
            ApexRequest.getApplicantId()
          );
      } else {
        throw new CustomException(System.Label.Applicant_ApplicantTypeNotFound);
      }

      return ApexResponse.ok(application);
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
    try {
      validateRequest(request);
      log?.debug('params : ' + ApexRequest.request.params);
      Account application = (Account) SObjectConstructor.deserialize(
        request.data,
        Account.class
      );
      application = ApplicationService.getInstance()
        .saveApplication(application);
      return ApexResponse.ok(
        ApplicationService.getInstance().updateFlowState(application)
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
   * @description delete any record by id
   * Header need to pass with recordId key need to delete
   * @author Digital Align Team | 10-28-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse deleteEntity(ApexRequest request) {
    try {
      validateRequest(request);
      List<Id> recordIds = new List<Id>();
      if (ApexRequest.getParams('recordId') != null) {
        recordIds.add((Id) ApexRequest.getParams('recordId'));
      } else if (ApexRequest.getParams('recordIds') != null) {
        for (
          Object recordId : (List<Object>) ApexRequest.getParams()
            .get('recordIds')
        ) {
          recordIds.add(String.valueOf(recordId));
        }
      }
      return ApexResponse.ok(
        ApplicationService.getInstance().deleteEntities(recordIds)
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
      return ApexResponse.ok(
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
      return ApexResponse.ok(SecurityUtils.refreshToken());
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

  /**
   * @description  fetch consent based on the custom fitler
   * @author Digital Align Team | 12-22-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse fetchConsents(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.ok(
        ConsentResolver.getInstance().fetchConsents(request.data)
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
   * @description
   * @author Digital Align | 12-27-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse fetchSurvey(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.ok(
        SurveyResolver.getInstance().fetchSurvey(request.data)
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
   * @description final application submit
   * @author Digital Align Team | 01-25-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse submitApplication(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.ok(
        ApplicationSubmissionService.getInstance()
          .submitApplication(request.data)
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
   * @description Generat Consent Pdf Files
   * @author Digital Align Team | 02-02-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse generateConsentPdf(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.ok(
        ConsentResolver.getInstance()
          .generateConsentPdf(ApexRequest.getApplicationId())
      );
    } catch (Exception ex) {
      log?.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }
}
