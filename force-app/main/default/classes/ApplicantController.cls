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
      applicants = ApplicantService.getInstance()
        .beforeSaveApplicants(applicants);
      applicants = ApplicationPersistService.getInstance()
        .saveApplicants(ApexRequest.getApplicationId(), applicants);
      applicants = ApplicantService.getInstance()
        .afterSaveApplicants(applicants);
      return ApexResponse.success(applicants);
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
      log?.debug('params : ' + ApexRequest.request.params);
      Applicant__c applicant = (Applicant__c) Json.deserialize(
        request.data,
        Applicant__c.class
      );
      applicant = ApplicantService.getInstance().beforeSaveApplicant(applicant);
      applicant = ApplicationPersistService.getInstance()
        .saveApplicant(ApexRequest.getApplicationId(), applicant);
      applicant = ApplicationPersistService.getInstance()
        .saveApplicantChild(applicant);
      applicant = ApplicantService.getInstance().afterSaveApplicant(applicant);
      return ApexResponse.success(applicant);
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
}
