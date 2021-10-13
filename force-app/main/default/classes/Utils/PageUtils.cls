/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class PageUtils {
  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @return Map<String, String>
   **/
  global static Map<String, String> getCurrentPageParameters() {
    Map<String, String> params = new Map<String, String>();
    if (ApexPages.currentPage() != null) {
      params = ApexPages.currentPage().getParameters();
    }
    return params;
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @param String key
   * @return String
   **/
  global static String getCurrentPageParameters(String key) {
    return PageUtils.getCurrentPageParameters().get(key);
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @param String key
   * @return Cookie
   **/
  global static Cookie getCookie(String key) {
    return ApexPages.currentPage()?.getCookies()?.get(key);
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @param Cookie cookie
   **/
  global static void setCookie(Cookie cookieObj) {
    List<Cookie> cookieList = new List<Cookie>();
    if (ApexPages.currentPage() != null) {
      cookieList = ApexPages.currentPage().getCookies().values();
      cookieList.add(cookieObj);
      ApexPages.currentPage().setCookies(cookieList);
    }
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @return Map<String, String>
   **/
  global static Map<String, String> getHeaders() {
    if (ApexPages.currentPage() != null) {
      return ApexPages.currentPage().getHeaders();
    }
    return new Map<String, String>();
  }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   * @param String key
   * @return String
   **/
  global static String getHeader(String key) {
    return PageUtils.getHeaders().get(key);
  }
}
