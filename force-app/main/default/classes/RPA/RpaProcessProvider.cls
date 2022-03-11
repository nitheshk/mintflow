/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class RpaProcessProvider extends AbstractService {
  @TestVisible
  private static RpaProcessProvider serviceInstance;

  public RpaProcessProvider() {
    super(RpaProcessProvider.class);
  }

  /**
   * @description Provides a singleton instance of RpaProcessProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 11/25/2021
   * @return Object  singleton
   **/
  public static RpaProcessProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (RpaProcessProvider) getInstance(RpaProcessProvider.class);
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align Team | 12-08-2021
   * @param Map<String object> params
   * @return HttpBuilder.Response
   **/
  global virtual HttpBuilder.Response addKycReviewQueue(Map<String, Object> params) {
    String token = (String) params.get('token');
    params.remove('token');

    Map<String, String> header = new Map<String, String>();
    if (String.isNotBlank(token)) {
      header.put('Authorization', 'Bearer ' + token);
    }
    header.put('Content-Type', 'application/json');
    header.put('Accept', 'application/json');
    header.put('X-UIPATH-OrganizationUnitId', HttpBuilder.getApiConstant('UipathOrgUnitId'));

    String requestBody = JSON.serialize(params, true);
    Flow.setSubFlowRequest(requestBody);

    HttpResponse response = HttpBuilder.httpCallOut(requestBody, header);
    Flow.setSubFlowResponse(response.getBody());

    return HttpBuilder.buildResponse(response.getStatusCode(), response.getStatus(), response.getBody());
  }
}
