/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AuthenticationProvider extends AbstractService {
  @TestVisible
  private static AuthenticationProvider serviceInstance;
  private String mintFlowAuthToken;

  public AuthenticationProvider() {
    super(AuthenticationProvider.class);
  }
  /**
   * @description Provides a singleton instance of AuthenticationProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static AuthenticationProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (AuthenticationProvider) getInstance(
        AuthenticationProvider.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description API Call generate token
   * @author Digital Align Team | 10-29-2021
   * @param Map<String Object> params
   * @return Object
   **/
  public Object generateToken(Map<String, Object> params) {
    try {
      Map<String, String> dto = new Map<String, String>();
      dto.put('username', 'admin'); //'{!$Credential.Username}');
      dto.put('password', 'grf37ygdN6eWnXAePhRH'); // '{!$Credential.Password}');
      Map<String, String> header = new Map<String, String>();
      header.put('accept', '*/*');
      header.put('Content-Type', 'application/json');
      HttpResponse response = HttpBuilder.httpCallOut(
        JSON.serialize(dto),
        header
      );
      return HttpBuilder.buildResponse(response);
    } catch (Exception ex) {
      log?.error(ex);
      return HttpBuilder.buildResponse(
        400,
        'There is some issue on the API call',
        null
      );
    }
  }
}
