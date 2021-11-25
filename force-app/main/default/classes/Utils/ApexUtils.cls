/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description  This class implement utils function for some
 * basic function for handling apex class related
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class ApexUtils {
  /** Apex Rest Related */
  private final static string NAMESPACE = 'dau01';

  /**
   * @description
   * @author Digital Align Team | 11-25-2021
   * @param String classUrlMapping
   * @return String
   **/
  global static String obtainUrlSuffix(String classUrlMapping) {
    String cBaseUrl = (NAMESPACE + classUrlMapping);
    String fullUrl = System.RestContext.request.requestURI.removeEnd('/');
    return fullUrl.toLowerCase().substringAfterLast(cBaseUrl.toLowerCase());
  }
}
