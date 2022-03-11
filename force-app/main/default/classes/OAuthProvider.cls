/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference  https://www.eonblock.com/2020/08/custom-client-credential-grant-type.html
 * https://github.com/bobbywhitesfdc/ApigeeAuthProvider
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class OAuthProvider extends Auth.AuthProviderPluginClass {
  public static final String RESOURCE_CALLBACK = '/services/authcallback/';
  public static final String DEFAULT_TOKEN_TYPE = 'BearerToken';
  public static final String ENCODING_XML = 'application/x-www-form-urlencoded;charset=UTF-8';
  public static final String ENCODING_JSON = 'application/json';
  public static final String DUMMY_CODE = '999';
  public static final String DOUBLEQUOTE = '"';

  // This class is dependant on this Custom Metadata Type created to hold custom parameters
  public static final String CUSTOM_MDT_NAME = 'mflow__APISetting__mdt';
  public static final String MDT_FIELD_CALLBACK_URL = 'mflow__CallbackURL__c';
  public static final String MDT_FIELD_PROVIDER_NAME = 'mflow__AuthProviderName__c';
  public static final String MDT_FIELD_AUTHTOKEN_URL = 'mflow__EndPoint__c';
  public static final String MDT_FIELD_CLIENT_ID = 'mflow__ClientId__c';
  public static final String MDT_FIELD_CLIENT_SECRET = 'mflow__ClientSecret__c';
  public static final String MDT_FIELD_USE_JSON = 'mflow__UseJSONEncoding__c';
  public static final String MDT_FIELD_SCOPE = 'mflow__Scope__c';

  public static final String GRANT_TYPE_PARAM = 'grant_type';
  public static final String CLIENT_ID_PARAM = 'client_id';
  public static final String CLIENT_SECRET_PARAM = 'client_secret';
  public static final String SCOPE_PARAM = 'scope';
  public static final String GRANT_TYPE_CLIENT_CREDS = 'client_credentials';

  /**
   * Added Constructor purely for debugging purposes to have visibility as to when the class
   * is being instantiated.
   **/
  public OAuthProvider() {
    super();
    System.debug('Constructor called');
  }

  /**
   * Name of custom metadata type to store this auth provider configuration fields
   * This method is required by its abstract parent class.
   **/
  public String getCustomMetadataType() {
    return CUSTOM_MDT_NAME;
  }

  /**
   * @description Initiate callback. No End User authorization required in this flow so skip straight to the Token request.
   * The interface requires the callback url to be defined.
   * Eg: https://test.salesforce.com/services/authcallback/<authprovidername>
   * @author Digital Align Team | 12-07-2021
   * @param Map<string string> config
   * @param String stateToPropagate
   * @return PageReference
   **/
  public PageReference initiate(Map<string, string> config, String stateToPropagate) {
    System.debug('initiate');
    final PageReference pageRef = new PageReference(getCallbackUrl(config)); //NOSONAR
    pageRef.getParameters().put('state', stateToPropagate);
    pageRef.getParameters().put('code', DUMMY_CODE); // Empirically found this is required, but unused
    System.debug(pageRef.getUrl());
    return pageRef;
  }

  /**
   * @description  This method composes the callback URL automatically UNLESS it has been overridden through Configuration.
   * Normally one should not override the callback URL, but it's there in case the generated URL doesn't work.
   * @author Digital Align Team | 12-07-2021
   * @param Map<string string> config
   * @return String
   **/
  private String getCallbackUrl(Map<string, string> config) {
    // https://{salesforce-hostname}/services/authcallback/{urlsuffix}
    final String overrideUrl = config.get(MDT_FIELD_CALLBACK_URL);
    final String generatedUrl =
      URL.getSalesforceBaseUrl().toExternalForm() +
      RESOURCE_CALLBACK +
      config.get(MDT_FIELD_PROVIDER_NAME);
    return String.isBlank(overrideUrl) ? generatedUrl : overrideUrl;
  }

  /**
   * @description  Handle callback (from initial loop back "code" step in the flow).
   * In the Client Credentials flow, this method retrieves the access token directly.
   * Required by parent class.
   * Error handling here is a bit painful as the UI never displays the exception or error message
   * supplied here.  The exception is thrown for Logging/Debugging purposes only.
   * @author Digital Align Team | 12-07-2021
   * @param Map<string string> config
   * @param Auth.AuthProviderCallbackState state
   * @return Auth.AuthProviderTokenResponse
   **/
  public Auth.AuthProviderTokenResponse handleCallback(
    Map<string, string> config,
    Auth.AuthProviderCallbackState state
  ) {
    System.debug('handleCallback');
    final TokenResponse response = retrieveToken(config);

    if (response.isError()) {
      throw new CustomException(response.getErrorMessage());
    }
    return new Auth.AuthProviderTokenResponse(
      config.get(MDT_FIELD_PROVIDER_NAME),
      response.access_token,
      config.get(MDT_FIELD_CLIENT_SECRET), // No Refresh Token
      state.queryParameters.get('state')
    );
  }

  /**
   * @description  Refresh is required by the parent class and it's used if the original Access Token has expired.
   * In the Client Credentials flow, there is no Refresh token, so its implementation is exactly the
   * same as the Initiate() step.
   * @author Digital Align Team | 12-07-2021
   * @param Map<String String> config
   * @param String refreshToken
   * @return Auth.OAuthRefreshResult
   **/
  public override Auth.OAuthRefreshResult refresh(Map<String, String> config, String refreshToken) {
    System.debug('refresh');
    final TokenResponse response = retrieveToken(config);
    return new Auth.OAuthRefreshResult(response.access_token, response.token_type);
  }

  /**
   * @description getUserInfo is required by the Parent class, but not fully supported by this provider.
   * Effectively the Client Credentials flow is only useful for Server-to-Server API integrations
   * and cannot be used for other contexts such as a Registration Handler for Communities.
   * @author Digital Align Team | 12-07-2021
   * @param Map<string string> config
   * @param Auth.AuthProviderTokenResponse response
   * @return Auth.UserData
   **/
  public Auth.UserData getUserInfo(Map<string, string> config, Auth.AuthProviderTokenResponse response) {
    System.debug('getUserInfo-was-called');
    final TokenResponse token = retrieveToken(config);
    final Auth.UserData userData = new Auth.UserData(
      token.application_name, // identifier
      null, // firstName
      null, // lastName
      null, // fullName
      token.developer_email, // email
      null, // link
      token.developer_email, // userName
      null, //locale
      config.get(MDT_FIELD_PROVIDER_NAME), //provider
      null, // siteLoginUrl
      new Map<String, String>()
    );
    return userData;
  }

  /**
   * @description  Private method that gets the Auth Token using the Client Credentials Flow.
   * @author Digital Align Team | 12-07-2021
   * @param Map<String String> config
   * @return TokenResponse
   **/
  private TokenResponse retrieveToken(Map<String, String> config) {
    System.debug('retrieveToken');

    final Boolean useJSONEncoding = Boolean.valueOf(config.get(MDT_FIELD_USE_JSON));

    final HttpRequest req = new HttpRequest();

    final PageReference endpoint = new PageReference(config.get(MDT_FIELD_AUTHTOKEN_URL)); //NOSONAR -- Protected by RemoteSite Setting
    if (!useJSONEncoding) {
      // Including the Query String breaks JSON encoded OAuth
      endpoint.getParameters().put('grant_type', GRANT_TYPE_CLIENT_CREDS);
    }

    // Determine whether or not to use JSON encoding
    final String encoding = useJSONEncoding ? ENCODING_JSON : ENCODING_XML;
    final String encodedParams = encodeParameters(config, encoding);

    System.debug('Endpoint: ' + endpoint.getUrl());
    System.debug('Content-Type:' + encoding);
    //System.debug('Body:' + encodedParams);

    req.setEndpoint(endpoint.getUrl());
    req.setHeader('Content-Type', encoding);
    req.setMethod('POST');
    req.setBody(encodedParams);

    final HTTPResponse res = new Http().send(req);

    System.debug('Token Response Status: ' + res.getStatus() + ' ' + res.getStatusCode());

    if (res.getStatusCode() == 200) {
      TokenResponse token = deserializeToken(res.getBody());
      // Ensure values for key fields
      token.token_type = (token.token_type == null) ? DEFAULT_TOKEN_TYPE : token.token_type;
      return token;
    } else {
      return deserializeToken(res.getBody());
    }
  }

  //deserialise response and return token
  @testVisible
  private TokenResponse deserializeToken(String responseBody) {
    System.debug('token response:' + responseBody);
    // use default parsing for everything we can.
    TokenResponse parsedResponse = (TokenResponse) System.JSON.deserialize(responseBody, TokenResponse.class);
    // explicitly parse out the developer.email property because it's an illegal identifier
    Map<String, Object> props = (Map<String, Object>) System.JSON.deserializeUntyped(responseBody);
    parsedResponse.developer_email = (String) props.get('developer.email');
    return parsedResponse;
  }

  /**
   * @description Conditionally encode parameters as URL-style or JSON
   * @author Digital Align Team | 12-07-2021
   * @param Map<String String> config
   * @param String encoding
   * @return String
   **/
  @testVisible
  private String encodeParameters(Map<String, String> config, String encoding) {
    // Pull out the subset of configured parameters that will be sent
    Map<String, String> params = new Map<String, String>();
    params.put(GRANT_TYPE_PARAM, GRANT_TYPE_CLIENT_CREDS);
    params.put(CLIENT_ID_PARAM, config.get(MDT_FIELD_CLIENT_ID));
    params.put(CLIENT_SECRET_PARAM, config.get(MDT_FIELD_CLIENT_SECRET));
    final String scope = config.get(MDT_FIELD_SCOPE);
    if (!String.isEmpty(scope)) {
      params.put(SCOPE_PARAM, scope);
    }

    return encoding == ENCODING_JSON ? encodeAsJSON(params) : encodeAsURL(params);
  }

  /**
   * @description encode parameters as JSON
   * @author Digital Align Team | 12-07-2021
   * @param Map<String String> params
   * @return String
   **/
  private String encodeAsJSON(Map<String, String> params) {
    String output = '{';
    for (String key : params.keySet()) {
      output += (output == '{' ? '' : ', ');
      output += DOUBLEQUOTE + key + DOUBLEQUOTE + ':';
      output += DOUBLEQUOTE + params.get(key) + DOUBLEQUOTE;
    }
    output += '}';
    return output;
  }

  /**
   * @description  encode parameters as URL-style
   * @author Digital Align Team | 12-07-2021
   * @param Map<String String> params
   * @return String
   **/
  private String encodeAsURL(Map<String, String> params) {
    String output = '';
    for (String key : params.keySet()) {
      output += (String.isEmpty(output) ? '' : '&');
      output += key + '=' + params.get(key);
    }
    return output;
  }

  /**
      OAuth Response is a JSON body like this on a Successful call

      {
        "refresh_token_expires_in" : "0",
        "api_product_list" : "[helloworld, HelloWorld_OAuth2-Product]",
        "api_product_list_json" : [ "helloworld", "HelloWorld_OAuth2-Product" ],
        "organization_name" : "bobbywhite-eval",
        "developer.email" : "developer@example.com",
        "token_type" : "BearerToken",
        "issued_at" : "1520478821362",
        "client_id" : "someKey",
        "access_token" : "kRxqmPr2b223uzTUGnndQhXWv8F4",
        "application_name" : "47bc6c8d-34f3-4141-b9e6-f1679a8240e7",
        "scope" : "",
        "expires_in" : "3599",
        "refresh_count" : "0",
        "status" : "approved"
      }

      On failure, the following structure from Apigee Edge (cloud hosted Gateway)

      {
        "ErrorCode" : "invalid_client"
      , "Error" : "Client credentials are invalid"
      }

      The following response class is the Union of all responses
      **/
  @SuppressWarnings('PMD.ExcessivePublicCount,PMD.VariableNamingConventions')
  global class TokenResponse {
    global String refresh_token_expires_in { get; set; }
    global String api_product_list { get; set; }
    global List<String> api_product_list_json { get; set; }
    global String organization_name { get; set; }
    global String developer_email { get; set; }
    global String token_type { get; set; }
    global String issued_at { get; set; }
    global String client_id { get; set; }
    global String access_token { get; set; }
    global String application_name { get; set; }
    global String scope { get; set; }
    global String expires_in { get; set; }
    global String refresh_count { get; set; }
    global String status { get; set; }

    // Apigee Edge -- hosted version uses these fields for error handling
    global String ErrorCode { get; set; }
    global String Error { get; set; }

    // Apigee on premise version uses this Field for error handling
    global Fault fault { get; set; }

    global Boolean isError() {
      return Error != null || fault != null;
    }

    global String getErrorMessage() {
      if (Error != null) {
        return ErrorCode;
      }

      if (fault != null) {
        // Substitute the error code to compose
        return fault.faultString.replace('{0}', fault.detail.errorcode);
      }
      return null;
    }
  }

  global class Fault {
    global String faultstring { get; set; }
    global Detail detail { get; set; }
  }

  global class Detail {
    global String errorcode { get; set; }
  }
}
