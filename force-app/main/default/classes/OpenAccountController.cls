/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/

@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OpenAccountController extends AbstractController {
  /**
   * Default Constructor
   */
  global OpenAccountController() {
    super(OpenAccountController.class);
  }
  /**
   * @description
   * @author Digital Align Team | 11-22-2021
   * @return PageReference
   **/
  global PageReference initOpenAccount() {
    try {
      log?.debug('initOpenAccount');
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
      log?.debug('Completed initOpenAccount');
      return openAccountPage;
    } catch (CustomException ex) {
      log?.error(ex);
      PageReference error = Page.Error;
      error.getParameters().put('exception', ex.getMessage());
      return error;
    } catch (Exception ex) {
      log?.error(ex);
      PageReference error = Page.Error;
      return error;
    } finally {
      Logger.persist();
    }
  }
}
