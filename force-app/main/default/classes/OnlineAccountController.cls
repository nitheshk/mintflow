/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description Online Account controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global without sharing class OnlineAccountController extends AbstractController {
  private String id { get; set; }
  private Account application { get; set; }
  global String initialData { get; set; }

  global OnlineAccountController() {
    super(OnlineAccountController.class);
    application = new Account();
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   **/
  global PageReference initializeApplication() {
    try {
      Map<String, Object> params = (Map<String, Object>) Json.deserializeUntyped(
        Json.serialize(PageUtils.getCurrentPageParameters())
      );
      //virtual mintflow(vmf)
      String vmf = PageUtils.getCurrentPageParameters('vmf');
      //Product Name
      String pid = PageUtils.getCurrentPageParameters('pid');
      Cookie pageToken = PageUtils.getCookie('token');
      log?.debug('Cookie: ' + pageToken?.getValue());
      // When Cookies is present on refresh of page
      if (pageToken != null && String.isNotBlank(pageToken.getValue())) {
        this.application = ApplicationService.getInstance().refreshPage(params);
        this.id = application.Id;
      } else if (String.isNotBlank(vmf) && String.isNotBlank(pid)) {
        log?.debug('params in if=' + params);
        ApplicationService.getInstance().cloneAppFromMembership(params);
        this.id = (String) params.get('applicationId');
      } else if (String.isNotBlank(vmf)) {
        //resume application mapping
        ApplicationService.getInstance().resumeApplication(params);
        this.id = (String) params.get('applicationId');
      } else {
        this.application = ApplicationService.getInstance()
          .createApplication(params);
        this.id = application.Id;
      }

      params.put('sftoken', UserInfo.getSessionId());
      params.put('token', ApexRequest.getToken());
      params.put('timezone', UserInfo.getTimeZone().getID());
      params.put('isResume', String.isNotBlank(vmf));
      Map<String, Object> initialData = new Map<String, Object>{
        'id' => this.id,
        'application' => SObjectConstructor.writeFieldsAsMap(
          (SObject) this.application
        ),
        'params' => params,
        'applicationConfig' => ApplicationConfiguration__c.getInstance(),
        'siteConfig' => ApplicationRepository.readSiteSetting()
      };
      this.initialData = JSON.serialize(initialData);
      return null;
    } catch (CustomException ex) {
      log?.error(ex);
      //PageUtils.addPageErrorMessage(ex.getMessage());
      PageReference error = Page.Error;
      error.setRedirect(true);
      return error;
    } catch (Exception ex) {
      log?.error(ex);
      //PageUtils.addPageErrorMessage('Unknown Exception');
      PageReference error = Page.Error;
      error.setRedirect(true);
      return error;
    } finally {
      Logger.persist();
    }
  }
}
