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
      PageReference openAccountPage;
      log?.debug('initOpenAccount');
      String cvmf = PageUtils.getCurrentPageParameters('cvmf');

      if (String.isNotBlank(cvmf)) {
        //Clone Application
        log?.debug('cvmf : ' + cvmf);
        String vuePath = PageUtils.getCurrentPageParameters('vue');
        vuePath = String.isNotBlank(vuePath) ? '#' + vuePath : '';
        openAccountPage = new PageReference('/OnlineAccount' + vuePath);
        ApplicationService.getInstance().startReferralApplication();
        //System.debug('openAccountPage :' + openAccountPage.getUrl());
      } else {
        String vuePath = PageUtils.getCurrentPageParameters('vue');
        vuePath = String.isNotBlank(vuePath) ? '#' + vuePath : '';
        openAccountPage = new PageReference('/OnlineAccount' + vuePath);
        //System.debug('openAccountPage :' + openAccountPage.getUrl());
      }
      //set cookie to 0, to delete
      Cookie existingToken = PageUtils.getCookie('token');
      if (existingToken != null) {
        PageUtils.setCookie(new Cookie('token', null, null, -1, false));
      }
      openAccountPage.getParameters().putAll(PageUtils.getCurrentPageParameters());
      log?.debug('Completed initOpenAccount');
      return openAccountPage;
    } catch (Exception ex) {
      log?.error(ex);
      //throw new CustomException(ex);
      return null;
    } finally {
      Logger.persist();
    }
  }
}
