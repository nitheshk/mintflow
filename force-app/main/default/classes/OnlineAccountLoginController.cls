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
    logger log = logger.getInstance(OnlineAccountLoginController.class);
    try {
      SiteSetting__c siteSetting = SiteSetting__c.getInstance();
      String url = PageUtils.getCurrentPageParameters('startURL');
      if (String.isNotBlank(url)) {
        List<String> urlStr = url.split('\\?');
        if (urlStr.size() > 1) {
          List<String> urlParams = urlStr[1].split('&');

          List<String> doubleEncodedParams = new List<String>();
          for (String param : urlParams) {
            List<String> keyValue = param.split('=');
            if (keyValue.size() == 2) {
              doubleEncodedParams.add(
                keyValue[0] +
                '=' +
                EncodingUtil.urlEncode(keyValue[1], 'UTF-8')
              );
            } else if (keyValue.size() == 1) {
              doubleEncodedParams.add(keyValue[0]);
            }
          }
          if (!doubleEncodedParams.isEmpty()) {
            url = String.join(doubleEncodedParams, '&');
            url = urlStr[0] + '?' + url;
          }
        }
      }
      log?.debug('start url :' + url);
      return Site.login(
        siteSetting.OnlineSiteUserName__c,
        siteSetting.OnlineSitePassword__c,
        url
      );
    } catch (Exception ex) {
      log?.error(ex);
      return null;
    } finally {
      Logger.persist();
    }
  }
}
