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
    PageUtils.setCookie(new Cookie('id', null, null, -1, true));
    SiteSetting__c siteSetting = SiteSetting__c.getInstance();
    return Site.login(
      siteSetting.OnlineSiteUserName__c,
      siteSetting.OnlineSitePassword__c,
      siteSetting.OnlineAccountOpeningUrl__c
    );
  }
}
