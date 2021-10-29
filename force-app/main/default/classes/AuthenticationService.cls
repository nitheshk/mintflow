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
}
