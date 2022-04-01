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
  global ApplicantController(AbstractController controller) {
    super(ApplicantController.class);
  }

  /**
   * @description calling read method for applicants by passging list of ids in header
   * params: applicantIds -> ['id1','id2']
   * @author Digital Align Team | 09-29-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse readApplicantsWithChild(ApexRequest request) {
    try {
      validateRequest(request);
      Set<Id> applicantIds = new Set<Id>();
      for (Object obj : (List<Object>) ApexRequest.getParams().get('applicantIds')) {
        applicantIds.add(String.valueOf(Obj));
      }
      return ApexResponse.ok(ApplicantService.getInstance().readApplicantsWithChild(applicantIds));
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
   * @param ApexRequest request
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

      applicants = ApplicantService.getInstance().saveApplicants(applicants, ApexRequest.getApplicationId());

      ApplicationService.getInstance().updateFlowState(applicants);

      return ApexResponse.ok(ApplicantService.getInstance().readApplicantsWithChild(applicants));
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
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse saveApplicant(ApexRequest request) {
    try {
      validateRequest(request);
      Applicant__c applicant = (Applicant__c) SObjectConstructor.deserialize(request.data, Applicant__c.class);

      applicant = ApplicantService.getInstance().saveApplicant(applicant, ApexRequest.getApplicationId());

      ApplicationService.getInstance().updateFlowState(applicant);

      return ApexResponse.ok(applicant);
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
      return ApexResponse.ok(AuthenticationService.getInstance().generateOTP(applicantId));
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
      return ApexResponse.ok(AuthenticationService.getInstance().validateOTP(ApexRequest.getParams()));
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
      log?.fine('Atomic FI authenticated successfully');
      validateRequest(request);
      ID applicantId = (Id) ApexRequest.getParams('applicantId');
      ID employerId = (Id) ApexRequest.getParams('employerId');
      if (String.isEmpty(applicantId) || String.isempty(employerId)) {
        return ApexResponse.ok('Applicant Id or Employer Id is missing in the request');
      }
      return ApexResponse.ok(EmploymentService.getInstance().atomicAuthenticate(applicantId, employerId));
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      Flow.finalize();
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
      return ApexResponse.ok(EmploymentService.getInstance().getAtomicResponse(applicantId, employerId));
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
      log?.fine('Generate PaySlips and W2');
      validateRequest(request);
      ID applicantId = (Id) ApexRequest.getParams('applicantId');
      ID employerId = (Id) ApexRequest.getParams('employerId');
      Employment__c employmentObj = EmploymentService.getInstance().readEmployerbyId(employerId);
      if (employmentObj != null && employmentObj.isDocumentGenerated__c == false) {
        return ApexResponse.ok(EmploymentService.getInstance().generatePaySlipsW2(applicantId, employerId));
      } else {
        return ApexResponse.ok('The files are already generated, so skipping ');
      }
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
   * @description  validate atomic fi report has genreated
   * @author Digital Align Team | 03-16-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse validateAtomicFi(ApexRequest request) {
    try {
      log?.fine('Inside validateAtomicFi');
      validateRequest(request);
      return ApexResponse.ok(EmploymentService.getInstance().validateAtomicFi(ApexRequest.getParams()));
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Completed validateAtomicFi');
      Logger.persist();
    }
  }
  /**
   * @description Fetch Accounts For Transaction
   * @author Digital Align Team | 12-29-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @RemoteAction
  global static ApexResponse verifyKYC(ApexRequest request) {
    if (SystemSetting__c.getOrgDefaults().mflow__KYCEvaluation__c) {
      try {
        validateRequest(request);
        log?.fine('Inside Appliant KYC');
        return ApexResponse.ok(AlloyService.getInstance().verifyKYC(ApexRequest.getApplicantId()));
      } catch (CustomException ex) {
        log?.error(ex);
        return ApexResponse.exception(ex);
      } catch (Exception ex) {
        log?.error(ex);
        return ApexResponse.fail(ex);
      } finally {
        log?.fine('Completed Applicant KYC');
        Logger.persist();
      }
    } else
      return null;
  }

  /**
   * @description
   * @author Digital Align Team | 03-28-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse validateExistingCustomer(ApexRequest request) {
    try {
      log?.fine('Inside validateExistingCustomer');
      validateRequest(request);
      return ApexResponse.ok(ApplicantService.getInstance().validateExistingCustomer(ApexRequest.getApplicationId()));
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      log?.fine('Completed validateExistingCustomer');
    }
  }
}
