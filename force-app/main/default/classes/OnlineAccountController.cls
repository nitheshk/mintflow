/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description Online Account controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OnlineAccountController extends AbstractController {
  public String id { get; set; }
  public String application { get; set; }
  public String params { get; set; }

  global OnlineAccountController() {
    super(OnlineAccountController.class);
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   **/
  global void initializeApplication() {
    try {
      Map<String, Object> params = PageUtils.getCurrentPageParameters();
      //virtual MintFlow
      String vmf = PageUtils.getCurrentPageParameters('vmf');
      log?.debug('vmf:' + vmf);

      if (String.isNotBlank(vmf)) {
        //decrypt the url
        Map<String, Object> decryptedParams;
        try {
          decryptedParams = (Map<String, Object>) JSON.deserializeUntyped(
            SecurityUtils.decryptUrl(vmf)
          );
        } catch (Exception ex) {
          throw new CustomException('The specified URL was corrupted');
        }
        //check link validity
        Datetime dt = (Datetime) decryptedParams.get('edt');
        if (dt < Datetime.now()) {
          throw new CustomException('The specified URL was Expired');
        }

        String applicationId = (String) decryptedParams.get('appId');
        String applicantId = (String) decryptedParams.get('aplId');
        String applicantType = (String) decryptedParams.get('aplType');
        params.put('applicationId', applicationId);
        params.put('applicantId', applicantId);
        params.put('applicationId', applicantType);
        if (applicantType == 'py') {
          params.put('applicantType', 'Primary');
        } else if (applicantType == 'jt') {
          params.put('applicantType', 'Joint');
        }
        this.id = applicationId;
        this.params = Json.serialize(params);
      } else {
        Account application = ApplicationService.getInstance()
          .createApplication(params);
        this.id = application.Id;
        params.put('applicationId', application.Id);
        params.put('applicationId', 'Primary');
        this.application = Json.serialize(application);
        this.params = Json.serialize(params);
      }
    } catch (Exception ex) {
      log?.error(ex);
    } finally {
      Logger.persist();
    }
  }
}
