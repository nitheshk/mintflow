/**
 * Copyright (c) 2021 Digital Align
 * @group Constant
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class SentiLinkAdapter {
  /**
   * @description
   * @author Digital Align | 10-12-2021
   * @param Map<String object> params
   * @return Map<String, object>
   **/
  public static Map<String, object> invokeAPI(Map<String, object> params) {
    Map<String, Object> data = params.clone();
    try {
      if (params != null) {
        setApiConfiguration(data);
        return (new SentiLinkProvider()).executeRequest(data);
      } else {
        throw new CustomException('Empty Parameter Passed');
      }
    } catch (Exception ex) {
      return (new Map<String, object>{
        'Status' => '400',
        'StatusMessage' => ex.getMessage(),
        'Data' => null
      });
    }
  }

  /**
   * @description
   * @param Map<String object> params
   * @return void
   **/
  private static void setApiConfiguration(Map<String, object> params) {
    if (
      ((String) params.get('APIName') == 'SentiLink') &&
      (APIConfigurationService.getAPISettings(APINames.SentiLink).isActive__c)
    ) {
      APIConfigurationService.setAPISettings(APINames.SentiLink);
    } else if (
      ((String) params.get('APIName') == 'SentiLinkIdCompletion') &&
      (APIConfigurationService.getAPISettings(APINames.SentiLinkIdCompletion)
        .isActive__c)
    ) {
      APIConfigurationService.setAPISettings(APINames.SentiLinkIdCompletion);
    } else {
      throw new CustomException('API Name not found');
    }
  }
}
