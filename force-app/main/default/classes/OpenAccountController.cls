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
    String vuePath = PageUtils.getCurrentPageParameters('vue');
    vuePath = String.isNotBlank(vuePath) ? '#' + vuePath : '';

    PageReference openAccountPage = new PageReference(
      '/mflow__OnlineAccount' + vuePath
    );

    /*
    List<String> encodedParams = new List<String>();
    for (String key : PageUtils.getCurrentPageParameters().keySet()) {
      encodedParams.add(key + '=' + PageUtils.getCurrentPageParameters(key));
    }


    if (!encodedParams.isEmpty()) {
      String params = String.join(encodedParams, '&');
      if (PageUtils.getCurrentPageParameters().containsKey('vue')) {
        openAccountPage = new PageReference(
          openAccountPage.getUrl() +
          '?' +
          params +
          '#' +
          PageUtils.getCurrentPageParameters('vue')
        );
      } else {
        openAccountPage = new PageReference(
          openAccountPage.getUrl() +
          '?' +
          params
        );
      }
    }*/

    //System.debug('openAccountPage :' + openAccountPage.getUrl());

    //set cookie to 0, to delete
    Cookie existingToken = PageUtils.getCookie('token');
    if (existingToken != null) {
      PageUtils.setCookie(new Cookie('token', null, null, -1, false));
    }
    openAccountPage.getParameters()
      .putAll(PageUtils.getCurrentPageParameters());
    return openAccountPage;
  }
}
