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
   * @description generate otp
   * @author Digital Align Team | 11-05-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse generateOTP(ApexRequest request) {
    try {
      log?.fine('Inside generateOTP');
      validateRequest(request);
      log?.debug('params : ' + ApexRequest.request.params);
      ID applicantId = (Id) ApexRequest.getParams('applicantId');
      return ApexResponse.ok(
        ApplicantService.getInstance().generateOTP(applicantId)
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
}
