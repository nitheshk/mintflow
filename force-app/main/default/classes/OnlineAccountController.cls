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
  private Application__c application { get; set; }
  global String initialData { get; set; }

  global OnlineAccountController() {
    super(OnlineAccountController.class);
    application = new Application__c();
  }

  /**
   * @description
   * @author Digital Align Team | 11-22-2021
   * @return PageReference
   **/
  global PageReference initializeOpenAccount() {
    try {
      log?.debug('initializeOpenAccount');
      PageReference openAccountPage;
      String cvmf = PageUtils.getCurrentPageParameters('cvmf');
      String vuePath = PageUtils.getCurrentPageParameters('vue');
      log?.debug('cvmf : ' + cvmf + ' , vuePath: ' + vuePath);

      //set cookie to 0, to delete
      if (PageUtils.getCookie('token') != null) {
        PageUtils.setCookie(new Cookie('token', null, null, -1, false));
      }

      if (String.isNotBlank(cvmf)) {
        //Clone Application
        PageUtils.setCurrentPageParameter('vmf', (String) ApplicationService.getInstance().startReferralApplication());
        PageUtils.removeCurrentPageParameter('cvmf');
      }

      vuePath = String.isNotBlank(vuePath) ? '#' + vuePath : '';
      openAccountPage = new PageReference('/OnlineAccount' + vuePath);
      PageUtils.removeCurrentPageParameter('vue');
      openAccountPage.getParameters().putAll(PageUtils.getCurrentPageParameters());
      log?.debug('Completed initializeOpenAccount');
      return openAccountPage;
    } catch (CustomException ex) {
      log?.error(ex);
      PageReference error = Page.Error;
      error.getParameters().put('exception', ex.getMessage());
      return error;
    } catch (Exception ex) {
      log?.error(ex);
      return Page.Error;
    } finally {
      Logger.persist();
    }
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   **/
  global PageReference initializeApplication() {
    try {
      log?.Fine('Inside initializeApplication');
      Map<String, Object> params = (Map<String, Object>) Json.deserializeUntyped(
        Json.serialize(PageUtils.getCurrentPageParameters())
      );
      //virtual mintflow(vmf)
      String vmf = PageUtils.getCurrentPageParameters('vmf');
      log?.info('vmf :' + vmf);
      Cookie pageToken = PageUtils.getCookie('token');
      log?.debug('Cookie: ' + pageToken?.getValue());
      // When Cookies is present on refresh of page
      if (pageToken != null && String.isNotBlank(pageToken.getValue())) {
        this.application = ApplicationService.getInstance().refreshPage(params);
        this.id = application.Id;
      } else if (String.isNotBlank(vmf)) {
        //resume application mapping
        ApplicationService.getInstance().resumeApplication(params);
        this.id = (String) params.get('applicationId');
      } else {
        this.application = ApplicationService.getInstance().createApplication(params);
        this.id = application.Id;
      }

      params.put('sftoken', UserInfo.getSessionId());
      params.put('token', ApexRequest.getToken());
      params.put('timezone', UserInfo.getTimeZone().getID());
      params.put('isResume', String.isNotBlank(vmf));
      Map<String, Object> initialData = new Map<String, Object>{
        'id' => this.id,
        'application' => SObjectConstructor.writeFieldsAsMap((SObject) this.application),
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

  /**
   * @description
   * @author Digital Align Team | 06-02-2022
   * @return PageReference
   **/
  global PageReference initializeOnlinePortal() {
    try {
      log?.Fine('Inside initializeOnlinePortal');
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
      log?.Fine('Exit initializeOnlinePortal');
      Logger.persist();
    }
  }

  /**
   * @description
   * @author Digital Align Team | 02-21-2022
   * @return String
   **/
  global String getStaticUrl() {
    return System.PageReference.forResource(ApplicationConfiguration__c.getInstance().UiStaticResourceName__c).getUrl();
  }
}
