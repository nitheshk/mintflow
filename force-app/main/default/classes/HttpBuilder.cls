/**
 * Copyright (c) 2021 Digital Align
 * @group Builder
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class HttpBuilder {
  private static APISetting__mdt apiSetting { get; set; }

  global static APISetting__mdt getAPISetting(APINames apiName) {
    return APISetting__mdt.getInstance(apiName.Name());
  }

  global static APISetting__mdt getAPISetting() {
    return apiSetting;
  }

  global static APISetting__mdt setAPISetting(APINames apiName) {
    apiSetting = APISetting__mdt.getInstance(apiName.Name());
    return apiSetting;
  }

  global static Boolean isActiveApiSetting(APINames apiName) {
    return APISetting__mdt.getInstance(apiName.Name())?.isActive__c;
  }

  global static Boolean isActiveApiSetting() {
    return apiSetting.isActive__c;
  }

  global static APISetting__mdt replaceEndpoint(
    String oldValue,
    String newValue
  ) {
    apiSetting?.EndPoint__c?.replace(oldValue, newValue);
    return apiSetting;
  }

  /**
   * @description returns value of API constants from metadata developer name.
   * @author Digital Align Team | 07-12-2021
   * @return String
   **/
  global static String getApiConstant(String developerName) {
    APIConstant__mdt apiConstant = APIConstant__mdt.getInstance(developerName);
    if (apiConstant.isActive__c) {
      return apiconstant.Value__c;
    }
    return null;
  }

  global class Response {
    global Integer statusCode { get; set; }
    global String status { get; set; }
    global Object data { get; set; }
    global Response(Integer statusCode, String message, Object data) {
      this.statusCode = statusCode;
      this.status = status;
      this.data = data;
    }
  }

  /**
   * @description Build response
   * @author Digital Align Team | 10-29-2021
   * @param Integer statusCode
   * @param String status
   * @param Object data
   * @return Response
   **/
  global static Response buildResponse(
    Integer statusCode,
    String status,
    Object data
  ) {
    return new Response(statusCode, status, data);
  }

  /**
   * @description Build response
   * @author Digital Align Team | 10-29-2021
   * @param HttpResponse httpResponseObj
   * @return Response
   **/
  global static Response buildResponse(HttpResponse httpResponseObj) {
    return new Response(
      httpResponseObj.getStatusCode(),
      httpResponseObj.getStatus(),
      httpResponseObj.getBody()
    );
  }

  /**
   * @description Http generic call out method with api configuration setting
   * @author Digital Align Team | 10-29-2021
   * @param String requestBody
   * @param Map<String String> header
   * @return HttpResponse
   **/
  global static HttpResponse httpCallOut(
    String requestBody,
    Map<String, String> header
  ) {
    HttpRequest req = new HttpRequest();
    req.setTimeout(Integer.valueOf(HttpBuilder.apiSetting.Timeout__c));
    req.setEndpoint(HttpBuilder.apiSetting.EndPoint__c);
    req.setMethod(HttpBuilder.apiSetting.Method__c);
    if (
      String.isNotBlank(requestBody) &&
      (HttpBuilder.apiSetting.Method__c != 'GET' ||
      HttpBuilder.apiSetting.Method__c != 'DELETE')
    ) {
      req.setBody(requestBody);
    }
    if (header != null) {
      for (String key : header.keySet()) {
        req.setHeader(key, header.get(key));
      }
    }
    return (new Http()).send(req);
  }
}
