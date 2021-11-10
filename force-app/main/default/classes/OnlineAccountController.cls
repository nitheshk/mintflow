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
  public Account application { get; set; }
  public String applicationJSON { get; set; }
  public String applicationName { get; set; }
  public Map<String, String> pageParams { get; set; }

  public OnlineAccountController() {
    super(OnlineAccountController.class);
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   **/
  global void initializeApplication() {
    try {
      pageParams = PageUtils.getCurrentPageParameters();
      Cookie currentCookie = PageUtils.getCookie('id');
      if (
        currentCookie != null && String.isNotBlank(currentCookie.getValue())
      ) {
        this.id = currentCookie.getValue();
        pageParams.put('id', this.id);
      }

      if (String.isNotBlank(pageParams.get('id'))) {
        //resume application with recordId
        this.application = ApplicationService.getInstance()
          .readApplicationWithChild(pageParams.get('id'));
        this.id = this.application.Id;
        this.applicationName = this.application.ApplicationNUmber__c;
      } else {
        this.application = ApplicationService.getInstance()
          .createApplication(pageParams);
        this.id = this.application.Id;
        this.applicationName = this.application.ApplicationNUmber__c;
        PageUtils.setCookie(new Cookie('id', null, this.id, -1, true));
      }
      this.applicationJSON = Json.serialize(this.application);
    } catch (Exception ex) {
      log?.error(ex);
    } finally {
      Logger.persist();
    }
  }
}
