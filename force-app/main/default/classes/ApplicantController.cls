/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description main application controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicantController extends AbstractController {
  private static logger log = logger.getInstance(ApplicantController.class);
  public ApplicantController(AbstractController controller) {
    super(ApplicantController.class);
  }

  /**
   * @description calling read method for applicants by passging list of ids in header
   * params: applicantIds -> ['id1','id2']
   * @author Digital Align Team | 09-29-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse readApplicantsWithChild(ApexRequest request) {
    try {
      validateRequest(request);
      Set<Id> applicantIds = new Set<Id>();
      for (
        Object obj : (List<Object>) ApexRequest.getParams().get('applicantIds')
      ) {
        applicantIds.add(String.valueOf(Obj));
      }
      return ApexResponse.success(
        ApplicantService.getInstance().readApplicantsWithChild(applicantIds)
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
   * @description Save Application record
   * @author Digital Align Team | 10-05-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse saveApplicants(ApexRequest request) {
    Savepoint sp = Database.setSavepoint();
    try {
      validateRequest(request);
      log?.debug('params : ' + ApexRequest.request.params);
      List<Applicant__c> applicants = (List<Applicant__c>) Json.deserialize(
        request.data,
        List<Applicant__c>.class
      );
      return ApexResponse.success(
        ApplicantService.getInstance()
          .saveApplicants(applicants, ApexRequest.getApplicationId())
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
   * @description Save Application record
   * @author Digital Align Team | 10-05-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse saveApplicant(ApexRequest request) {
    Savepoint sp = Database.setSavepoint();
    try {
      validateRequest(request);
      Applicant__c applicant = (Applicant__c) Json.deserialize(
        request.data,
        Applicant__c.class
      );
      return ApexResponse.success(
        ApplicantService.getInstance()
          .saveApplicant(applicant, ApexRequest.getApplicationId())
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
      validateRequest(request, true);
      log?.debug('params : ' + ApexRequest.getParams());
      ID applicantId = (Id) ApexRequest.getParams('applicantId');
      return ApexResponse.Success(
        AuthenticationService.getInstance().generateOTP(applicantId)
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
      validateRequest(request, true);
      log?.debug('params : ' + ApexRequest.getParams());
      return ApexResponse.Success(
        AuthenticationService.getInstance().validateOTP(ApexRequest.getParams())
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
