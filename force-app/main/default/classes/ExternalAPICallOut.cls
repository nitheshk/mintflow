/** Copyright (c) 2021 Digital Align
 * @group API
 * @author Digital Align Team
 * @reference
 * @description Class of making Http call outs
 **/

public with sharing class ExternalAPICallOut {
  public static HttpResponse execute(
    String requestBody,
    Map<String, String> header
  ) {
    HttpResponse response;
    try {
      HttpRequest req = new HttpRequest();
      req.setTimeout(
        Integer.valueOf(APIConfigurationService.getAPISettings().Timeout__c)
      );
      req.setEndpoint(APIConfigurationService.getAPISettings().EndPoint__c);
      req.setMethod(APIConfigurationService.getAPISettings().Method__c);
      if (
        String.isNotBlank(requestBody) &&
        (APIConfigurationService.getAPISettings().Method__c != 'GET' ||
        APIConfigurationService.getAPISettings().Method__c != 'DELETE')
      ) {
        req.setBody(requestBody);
        System.debug('header::' + header);
        System.debug('requestBody::' + requestBody);
      }
      if (header != null) {
        for (String key : header.keySet()) {
          req.setHeader(key, header.get(key));
        }
      }
      Http http = new Http();
      response = http.send(req);
      System.debug('response ::' + response.getbody());
    } catch (Exception ex) {
      throw new CustomException(' There was some issue on the API call');
    } finally {
    }
    return response;
  }
}
