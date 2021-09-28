/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class APICaller {
  /**
   * @description
   * @author Digital Align | 08-12-2021
   * @param String requestBody
   * @return HttpResponse
   **/
  public static HttpResponse execute(String requestBody) {
    HttpResponse response;
    try {
      HttpRequest request = new HttpRequest();
      request.setTimeout(
        Integer.valueOf(APIConfiguration.getAPIConfig().Timeout__c)
      );
      request.setEndpoint(APIConfiguration.getAPIConfig().EndPoint__c);
      request.setMethod(APIConfiguration.getAPIConfig().Method__c);
      request.setBody(requestBody);
      if (!APIConfiguration.getAPIConfig().Method__c.equalsIgnoreCase('GET')) {
        request.setHeader('Content-Type', 'text/json');
      }
      request.setHeader('Accept', 'text/json');
      Http http = new Http();
      response = http.send(request);
    } catch (Exception e) {
      system.debug('Exception =' + e);
    }
    return response;
  }
}
