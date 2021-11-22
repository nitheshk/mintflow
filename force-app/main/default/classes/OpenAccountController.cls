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
    Pagereference openAccountPage = Page.OnlineAccount;
    //set cookie to 0, to delete
    PageUtils.setCookie(new Cookie('token', null, null, 0, true));
    openAccountPage.getParameters()
      .putAll(PageUtils.getCurrentPageParameters());
    return openAccountPage;
  }
}
