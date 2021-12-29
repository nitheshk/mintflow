/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class PlaidProvider extends AbstractService {
  @TestVisible
  private static PlaidProvider serviceInstance;
  private String accessToken;

  public PlaidProvider() {
    super(PlaidProvider.class);
  }

  /**
   * @description Provides a singleton instance of PlaidProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 12/28/2021
   * @return Object  singleton
   **/
  public static PlaidProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (PlaidProvider) getInstance(PlaidProvider.class);
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align Team | 12-29-2021
   * @param Map<String Object> params
   * @return HttpBuilder.Response
   **/
  global virtual HttpBuilder.Response generatelinkToken(
    Map<String, Object> params
  ) {
    //api setting
    HttpBuilder.setAPISetting(APINames.PlaidLinkToken);
    //body
    PlaidTokenDTO.LinkTokenRequest requestDTO = new PlaidTokenDTO.LinkTokenRequest();
    requestDTO.client_id = '{!$Credential.UserName}';
    requestDTO.secret = '{!$Credential.Password}';
    requestDTO.client_name = 'Digital Align Inc';
    requestDTO.country_codes = new List<String>{ 'US' };
    requestDTO.language = 'en';
    requestDTO.user.client_user_id = String.valueOf(Datetime.now().getTime());
    requestDTO.products = new List<String>{ 'auth' };

    String requestBody = JSON.serialize(requestDTO);
    Flow.setSubFlowRequest(requestBody);
    //header
    Map<String, String> header = new Map<String, String>();
    header.put('accept', 'application/json');
    header.put('Content-Type', 'application/json');
    //APi Call
    HttpResponse response = HttpBuilder.httpCallOut(requestBody, header);
    Flow.setSubFlowResponse(response.getBody());
    return HttpBuilder.buildResponse(response);
  }

  /**
   * @description Generate Exchange Token
   * @author Digital Align Team | 12-29-2021
   * @param Map<String Object> params
   * @return HttpBuilder.Response
   **/
  global virtual HttpBuilder.Response generateExchangeToken(
    Map<String, Object> params
  ) {
    if (params.get('publicToken') == null) {
      throw new CustomException('Invalid Public Token');
    }
    //api setting
    HttpBuilder.setAPISetting(APINames.PlaidTokenExchange);
    //body
    Map<String, Object> body = new Map<String, Object>();
    body.put('client_id', '{!$Credential.UserName}');
    body.put('secret', '{!$Credential.Password}');
    body.put('public_token', params.get('publicToken'));
    String requestBody = JSON.serialize(body);
    Flow.setSubFlowRequest(requestBody);
    //header
    Map<String, String> header = new Map<String, String>();
    header.put('accept', 'application/json');
    header.put('Content-Type', 'application/json');
    //APi Call
    HttpResponse response = HttpBuilder.httpCallOut(requestBody, header);
    Flow.setSubFlowResponse(response.getBody());
    return HttpBuilder.buildResponse(response);
  }

  /**
   * @description retrieve auth
   * @author Digital Align Team | 12-29-2021
   * @param Map<String Object> params
   * @return HttpBuilder.Response
   **/
  global virtual HttpBuilder.Response retrieveAuth(Map<String, Object> params) {
    //api setting
    HttpBuilder.setAPISetting(APINames.PlaidRetrieveAuth);
    //body
    Map<String, Object> body = new Map<String, Object>();
    body.put('client_id', '{!$Credential.UserName}');
    body.put('secret', '{!$Credential.Password}');
    body.put('access_token', params.get('accessToken'));
    String requestBody = JSON.serialize(body);
    Flow.setSubFlowRequest(requestBody);
    //header
    Map<String, String> header = new Map<String, String>();
    header.put('accept', 'application/json');
    header.put('Content-Type', 'application/json');
    //APi Call
    HttpResponse response = HttpBuilder.httpCallOut(requestBody, header);
    Flow.setSubFlowResponse(response.getBody());
    return HttpBuilder.buildResponse(response);
  }
}
