/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description IdScanProvider to perform customer due diligence
 **/
global virtual with sharing class IdScanProvider extends AbstractService {
  @TestVisible
  private static IdScanProvider serviceInstance;

  public IdScanProvider() {
    super(IdScanProvider.class);
  }

  /**
   * @description Provides a singleton instance of IdScanProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 12/28/2021
   * @return Object  singleton
   **/
  public static IdScanProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (IdScanProvider) getInstance(IdScanProvider.class);
    }
    return serviceInstance;
  }

  /**
   * @description Provides a singleton instance of PlaidProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 12/28/2021
   * @return HttpBuilder.HttpResponse
   **/
  public static HttpBuilder.Response idScanCheck(IdScanDueDiligenceDTO.Request customer) {
    HttpBuilder.setAPISetting(APINames.DueDiligence);
    //body
    String requestBody = JSON.serialize(customer, true);
    Flow.setSubFlow(APINames.DueDiligence);
    Flow.setSubFlowRequest(requestBody);
    system.debug('requestbody::' + requestBody);
    //header
    Map<String, String> header = new Map<String, String>();
    header.put('Content-Type', 'application/json');
    header.put('Authorization', 'Bearer ' + '{!$Credential.Password}');
    header.put('api-version', '1.0');
    //APi Call
    HttpResponse response = HttpBuilder.httpCallOut(requestBody, header);
    Flow.setSubFlowResponse(response.getBody());
    return HttpBuilder.buildResponse(response);
  }
}
