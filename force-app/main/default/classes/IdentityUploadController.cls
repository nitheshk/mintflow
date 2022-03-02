/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class IdentityUploadController extends AbstractController {
  private Application__c application { get; set; }
  global String initialData { get; set; }

  global IdentityUploadController() {
    super(IdentityUploadController.class);
    this.application = new Application__c();
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   **/
  global PageReference initializeApplication() {
    try {
      Map<String, Object> params = PageUtils.getCurrentPageParameters();
      //virtual mintflow(vmf)
      String vmf = PageUtils.getCurrentPageParameters('vmf');

      if (String.isNotBlank(vmf)) {
        //resume application mapping
        SecurityUtils.CipherDTO cipher;
        try {
          cipher = SecurityUtils.extractToken(vmf);
        } catch (Exception ex) {
          throw new CustomException(
            System.Label.Resume_TheSpecifiedUrlWasCorrupted
          );
        }
        if (cipher.edt < Datetime.now()) {
          throw new CustomException(
            System.Label.Resume_TheSpecifiedUrlWasExpired
          );
        }

        this.application = ApplicationService.getInstance()
          .readApplicationWithChild(cipher.appId, cipher.aplId);
        Applicant__c currentApplicant = this.application.Applicants__r[0];
        params.put('applicantType', cipher.aplType);
        params.put('channel', cipher.ch);
        params.put('applicationId', cipher.appId);
        params.put('applicantId', cipher.aplId);
        params.put('flowType', cipher.flw);
        params.put('token', currentApplicant.SessionToken__c);
        params.put('timezone', UserInfo.getTimeZone().getID());
        params.put('applicationNumber', this.application.Name);
      } else {
        throw new CustomException('Invalid Url');
      }

      Map<String, Object> initialData = new Map<String, Object>{
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
      error.setRedirect(false);
      return error;
    } catch (Exception ex) {
      log?.error(ex);
      //PageUtils.addPageErrorMessage('Unknown Exception');
      PageReference error = Page.Error;
      error.setRedirect(false);
      return error;
    } finally {
      Logger.persist();
    }
  }

  /**
   * @description
   * @author Digital Align Team | 02-21-2022
   * @return String
   **/
  global String getStaticUrl() {
    return System.PageReference.forResource(
        ApplicationConfiguration__c.getInstance().UiStaticResourceName__c
      )
      .getUrl();
  }
}
