/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description This class implement basic function
 * for some generic functionality
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GenericUtils {
  /**
   * @description Custom execption by message and binding values
   * @author Digital Align | 05-04-2021
   * @param Object obj
   * @param List<String> values
   **/
  global static void customException(String mesage, list<String> values) {
    throw new CustomException(String.format(mesage, values));
  }

  /**
   * @description fetch login url
   * @author Digital Align Team | 09-13-2021
   * @return String
   **/
  @AuraEnabled(cacheable=true)
  global static String fetchLoginURL() {
    String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
    if (UtilsRepository.getUserById(UserInfo.getUserId()).ContactId != null) {
      baseUrl = fetchExperienceURL();
    }
    return baseUrl;
  }

  /**
   * @description fetch community url
   * @author Digital Align Team | 09-13-2021
   * @return String
   **/
  private static String fetchExperienceURL() {
    String baseUrl = Network.getLoginUrl(Network.getNetworkId());
    baseURL = baseURL.replace('/s/login', '');
    baseURL = baseURL.replace('/s/Login', '');
    baseURL = baseURL.replace('/login', '');
    baseURL = baseURL.replace('/Login', '');
    return baseURL;
  }
}
