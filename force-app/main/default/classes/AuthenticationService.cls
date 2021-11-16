/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AuthenticationService extends AbstractService {
  @TestVisible
  private static AuthenticationService serviceInstance;
  private String mintFlowAuthToken;

  public AuthenticationService() {
    super(AuthenticationService.class);
  }
  /**
   * @description Provides a singleton instance of AuthenticationService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static AuthenticationService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (AuthenticationService) getInstance(
        AuthenticationService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description Generate AUth Token for AWS service
   * @author Digital Align Team | 10-29-2021
   * @return String
   **/
  global String getAuthToken() {
    if (String.isNotBlank(mintFlowAuthToken)) {
      return mintFlowAuthToken;
    }
    HttpBuilder.setAPISetting(APINames.AWSAuth);
    HttpBuilder.Response response = (HttpBuilder.Response) AuthenticationProvider.getInstance()
      .generateToken(null);
    if (response.statusCode == 200) {
      return String.valueOf(response.data);
    }
    return null;
  }

  /**
   * @description create session token for application
   * @author Digital Align Team | 11-15-2021
   * @param Account application
   * @return Account
   **/
  global static Account createSessionForApplication(Account application) {
    Map<String, Object> mf = new Map<String, Object>{
      'appId' => application.Id,
      'edt' => Datetime.now().addMinutes(10)
    };
    application.SessionToken__c = SecurityUtils.encryptBase64(
      Json.serialize(mf)
    );
    ApexRequest.getRequest().token = application.SessionToken__c;
    return application;
  }

  /**
   * @description extract data from token
   * @author Digital Align Team | 11-15-2021
   * @param String encryptedToken
   * @return Map<String, Object>
   **/
  global static Map<String, Object> extractToken(String encryptedToken) {
    return (Map<String, Object>) JSON.deserializeUntyped(
      SecurityUtils.decryptBase64(encryptedToken)
    );
  }
}
