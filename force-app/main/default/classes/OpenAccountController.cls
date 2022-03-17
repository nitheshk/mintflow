/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/

@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OpenAccountController {
  /**
   * @description
   * @author Digital Align Team | 11-22-2021
   * @return PageReference
   **/
  global PageReference initOpenAccount() {
    PageReference openAccountPage;
    String cvmf = PageUtils.getCurrentPageParameters('cvmf');
    if (String.isNotBlank(cvmf)) {
      //Clone Application
      String vuePath = PageUtils.getCurrentPageParameters('vue');
      vuePath = String.isNotBlank(vuePath) ? '#' + vuePath : '';
      openAccountPage = new PageReference('/OnlineAccount' + vuePath);
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
    return openAccountPage;
  }
}
