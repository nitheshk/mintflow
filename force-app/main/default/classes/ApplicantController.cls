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
      return ApexResponse.ok(
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
    try {
      validateRequest(request);
      log?.debug('params : ' + ApexRequest.request.params);
      List<Applicant__c> applicants = (List<Applicant__c>) SObjectConstructor.deserialize(
        request.data,
        List<Applicant__c>.class
      );

      applicants = ApplicantService.getInstance()
        .saveApplicants(applicants, ApexRequest.getApplicationId());
      return ApexResponse.ok(
        ApplicantService.getInstance()
          .readApplicantsWithChild(
            (new Map<id, Applicant__c>(applicants)).keyset()
          )
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
  global static ApexResponse saveApplicant(ApexRequest request) {
    try {
      validateRequest(request);
      Applicant__c applicant = (Applicant__c) SObjectConstructor.deserialize(
        request.data,
        Applicant__c.class
      );
      return ApexResponse.ok(
        ApplicantService.getInstance()
          .saveApplicant(applicant, ApexRequest.getApplicationId())
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
      return ApexResponse.ok(
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
      return ApexResponse.ok(
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

  /**
   * @description authenticate AtomicFI API for applicant
   * @author Digital Align Team | 11-05-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  public static ApexResponse atomicAuthenticate(ApexRequest request) {
    try {
      log?.fine('Inside atomicAuthenticate');
      validateRequest(request);
      ID applicantId = (Id) ApexRequest.getParams('applicantId');
      return ApexResponse.ok(
        EmploymentService.getInstance().atomicAuthenticate(applicantId)
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
   * @description Get  AtomicFI response of employment verification
   * @author Digital Align Team | 11-05-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  public static ApexResponse getAtomicResponse(ApexRequest request) {
    try {
      // Method to return the first employment content version json of applicant ::TODO
      log?.fine('Inside getAtomicResponse');
      validateRequest(request);
      ID applicantId = (Id) ApexRequest.getParams('applicantId');
      ID employerId = (Id) ApexRequest.getParams('employerId');
      return ApexResponse.ok(
        EmploymentService.getInstance()
          .getAtomicResponse(applicantId, employerId)
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
   * @description Generate payslips and W2 for applicant on employment verification
   * @author Digital Align Team | 11-05-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  public static ApexResponse generatePaySlipsW2(ApexRequest request) {
    try {
      log?.fine('Inside generatePaySlipsW2');
      validateRequest(request);
      ID applicantId = (Id) ApexRequest.getParams('applicantId');
      ID employerId = (Id) ApexRequest.getParams('employerId');
      return ApexResponse.ok(
        EmploymentService.getInstance()
          .generatePaySlipsW2(applicantId, employerId)
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
}
