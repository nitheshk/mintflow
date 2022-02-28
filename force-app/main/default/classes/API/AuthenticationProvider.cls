/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class AuthenticationProvider extends AbstractService {
  @TestVisible
  private static AuthenticationProvider serviceInstance;
  private String mintFlowAuthToken;
  private String uiPathToken;

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
        System.Label.Util_ThereIsSomeIssueOnTheApiCall,
        null
      );
    }
  }

  /**
   * @description generate token for rpa connect
   * @author Digital Align Team | 12-08-2021
   * @param Map<String Object> params
   * @return String
   **/
  public String generateUiPathToken() {
    try {
      if (String.isNotBlank(uiPathToken)) {
        return uiPathToken;
      }
      APISetting__mdt apiSetting = HttpBuilder.getAPISetting();
      @SuppressWarnings('PMD.ApexOpenRedirect')
      PageReference endpoint = new PageReference(apiSetting.EndPoint__c);
      endpoint.getParameters().put('grant_type', 'client_credentials');
      apiSetting.EndPoint__c = endpoint.getUrl();
      Map<String, String> formParams = new Map<String, String>();
      formParams.put('grant_type', 'client_credentials');
      formParams.put('client_id', apiSetting.ClientId__c);
      formParams.put('client_secret', apiSetting.ClientSecret__c);
      formParams.put('scope', apiSetting.Scope__c);
      String encodedParams = '';
      for (String key : formParams.keySet()) {
        encodedParams += (String.isEmpty(encodedParams) ? '' : '&');
        encodedParams += key + '=' + formParams.get(key);
      }
      Map<String, String> header = new Map<String, String>();
      header.put('accept', '*/*');
      header.put(
        'Content-Type',
        'application/x-www-form-urlencoded;charset=UTF-8'
      );
      HttpResponse response = HttpBuilder.httpCallOut(encodedParams, header);

      if (response.getStatusCode() == 200) {
        OAuthProvider.TokenResponse parsedResponse = (OAuthProvider.TokenResponse) System.JSON.deserialize(
          response.getBody(),
          OAuthProvider.TokenResponse.class
        );
        uiPathToken = parsedResponse.access_token;
        return parsedResponse.access_token;
      } else {
        return null;
      }
    } catch (Exception ex) {
      log?.error(ex);
      return null;
    }
  }
}
