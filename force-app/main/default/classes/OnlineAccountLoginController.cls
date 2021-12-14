/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OnlineAccountLoginController {
  /**
   * @description redirect to online account page when user is not logged into portal
   * Issue: Start Url Paramteter are get decode while passing to next page reference,
   * Encode twice so that it will keep the paramter on same state for next page
   * @author Digital Align Team | 11-22-2021
   * @return PageReference
   **/
  global PageReference forwardToAccountOpeningPage() {
    Logger log = Logger.getInstance(OnlineAccountLoginController.class);
    try {
      /**
       * For Community user salesforce doesn't decode start url(parameter) while passing to next url
       * we are using community plus user for login purpose here
       */
      SiteSetting__c siteSetting = SiteSetting__c.getInstance();
      return Site.login(
        siteSetting.OnlineSiteUserName__c,
        siteSetting.OnlineSitePassword__c,
        PageUtils.getCurrentPageParameters('startURL')
      );

      /**
       * salesforce issue with url parsing
       * https://{Domain}/Online/mflow__onlineaccount#/membership/joints/welcome
       * Above url after #get ignore on page redirection
       * Below code to avoid that issue of redirecting
       */
      /*
      SiteSetting__c siteSetting = SiteSetting__c.getInstance();
      String url = PageUtils.getCurrentPageParameters('startURL');
      if (String.isNotBlank(url)) {
        List<String> urlStr = url.split('\\?');
        if (urlStr.size() > 1) {
          List<String> urlParams = urlStr[1].split('&');

          List<String> encodedParams = new List<String>();
          String vuePath;
          for (String param : urlParams) {
            List<String> keyValue = param.split('=');
            if (keyValue.size() == 2) {
              encodedParams.add(keyValue[0] + '=' + keyValue[1]);
              if (keyValue[0] == 'vue') {
                vuePath = keyValue[1];
              }
            } else if (keyValue.size() == 1) {
              encodedParams.add(keyValue[0]);
              if (keyValue[0] == 'vue') {
                vuePath = keyValue[1];
              }
            }
          }
          if (!encodedParams.isEmpty()) {
            url = String.join(encodedParams, '&');
            if (String.isNotBlank(vuePath)) {
              url = urlStr[0] + '#' + vuePath + '?' + url;
            } else {
              url = urlStr[0] + '?' + url;
            }
          }
        }
      }
      log?.debug('start url :' + url);
      return Site.login(
        siteSetting.OnlineSiteUserName__c, //standard user
        siteSetting.OnlineSitePassword__c,
        url
      );
      */
      /**
       * For Standard user salesforce does decode start url(parameter) while passing to next url
       * So we are double encoding parameter, So it will sent parameter in required format
       */
      /*
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
        siteSetting.OnlineSiteUserName__c, //standard user
        siteSetting.OnlineSitePassword__c,
        url
      ); */
    } catch (Exception ex) {
      log?.error(ex);
      // Redirect to error Page
      return null;
    } finally {
      Logger.persist();
    }
  }
}
