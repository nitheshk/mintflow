/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OnlineAccountLoginController {
  global PageReference forwardToAccountOpeningPage() {
    SiteSetting__c siteSetting = SiteSetting__c.getInstance();
    return Site.login(
      siteSetting.OnlineSiteUserName__c,
      siteSetting.OnlineSitePassword__c,
      PageUtils.getCurrentPageParameters('startURL')
    );
  }
}
