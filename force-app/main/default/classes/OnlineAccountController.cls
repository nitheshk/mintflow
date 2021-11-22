/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description Online Account controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OnlineAccountController extends AbstractController {
  global String id { get; set; }
  global String application { get; set; }
  global String params { get; set; }

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
      //virtual mintflow(vmf)
      String vmf = PageUtils.getCurrentPageParameters('vmf');
      log?.debug('vmf:' + vmf);
      Cookie pageToken = PageUtils.getCookie('token');
      log?.debug(pageToken?.getValue());

      if (pageToken != null && String.isNotBlank(pageToken.getValue())) {
        Account application = ApplicationService.getInstance()
          .refreshPage(params);
        this.id = application.Id;
        this.application = Json.serialize(application);
        this.params = Json.serialize(params, true);
      } else if (String.isNotBlank(vmf)) {
        //resume application mapping
        ApplicationService.getInstance().resumeApplication(params);
        this.id = (String) params.get('applicationId');
        this.params = Json.serialize(params, true);
      } else {
        Account application = ApplicationService.getInstance()
          .createApplication(params);
        this.id = application.Id;
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
