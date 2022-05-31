/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OnlinePortalController extends AbstractController {
  global String initialData { get; set; }
  public OnlinePortalController() {
    super(OnlinePortalController.class);
  }

  global PageReference initializeApplication() {
    try {
      log?.Fine('Inside initializeApplication');
      Map<String, Object> params = (Map<String, Object>) Json.deserializeUntyped(
        Json.serialize(PageUtils.getCurrentPageParameters())
      );
      params.put('token', ApexRequest.getToken());
      params.put('timezone', UserInfo.getTimeZone().getID());
      Map<String, Object> initialData = new Map<String, Object>{
        'params' => params,
        'applicationConfig' => ApplicationConfiguration__c.getInstance(),
        'siteConfig' => SiteSetting__c.getInstance()
      };
      this.initialData = JSON.serialize(initialData);
      return null;
    } catch (CustomException ex) {
      log?.error(ex);
      PageReference error = Page.Error;
      error.getParameters().put('exception', ex.getMessage());
      return error;
    } catch (Exception ex) {
      log?.error(ex);
      return Page.Error;
    } finally {
      log?.Fine('Exit initializeApplication');
      Logger.persist();
    }
  }
}
