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
  public String applicationJSON { get; set; }
  public String params { get; set; }

  public OnlineAccountController() {
    super(OnlineAccountController.class);
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   **/
  global void initializeApplication() {
    try {
      Map<String, Object> params;

      //virtual MintFlow
      String vmf = PageUtils.getCurrentPageParameters('vmf');
      log?.debug('vmf:' + vmf);

      if (String.isNotBlank(vmf)) {
        //decrypt the url
        try {
          params = (Map<String, Object>) JSON.deserializeUntyped(
            SecurityUtils.decryptUrl(vmf)
          );
        } catch (Exception ex) {
          throw new CustomException('The specified URL was corrupted');
        }

        //check link validity
        Datetime dt = (Datetime) params.get('edt');
        if (dt < Datetime.now()) {
          throw new CustomException('The specified URL was Expired');
        }

        String applicationId = (String) params.get('appId');
        String applicantId = (String) params.get('aplId');
        String applicantType = (String) params.get('aplType');

        if (applicantType == 'py') {
          applicantType = 'Primary';
          //this.application = ApplicationService.getInstance()
          //  .readApplicationWithChild(applicationId);
        } else if (applicantType == 'jt') {
          applicantType = 'Joint';
        }

        //this.id = this.application.Id;
        //this.applicationName = this.application.ApplicationNumber__c;
      } else {
        Account application = ApplicationService.getInstance()
          .createApplication(PageUtils.getCurrentPageParameters());
        this.id = application.Id;
        this.applicationJSON = Json.serialize(application);
        //this.applicationName = this.application.ApplicationNumber__c;
        //PageUtils.setCookie(new Cookie('id', null, this.id, -1, true));
      }
    } catch (Exception ex) {
      log?.error(ex);
    } finally {
      Logger.persist();
    }
  }
}
