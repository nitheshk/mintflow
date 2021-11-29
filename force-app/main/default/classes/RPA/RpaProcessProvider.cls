/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class RpaProcessProvider extends AbstractService {
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
      serviceInstance = (RpaProcessProvider) getInstance(
        RpaProcessProvider.class
      );
    }
    return serviceInstance;
  }

  global virtual HttpBuilder.Response addKycReviewQueue(
    Map<String, object> params
  ) {
    map<string, object> request = new Map<string, object>();
    request.put('Name', params.get('NameOfTheQueue'));
    request.put('Priority', params.get('Normal'));
    request.put('SpecificContent', params.get('applicationId'));
    flow.setSubFlowRequest(json.serialize(request, true));
    log?.debug('Request : ' + json.serialize(request, true));
    HttpResponse response = HttpBuilder.httpCallOut(
      json.serialize(request, true),
      getHeader(params)
    );
    if (response.getStatusCode() != 200) {
      throw new CustomException(response.getStatus());
    }
    return HttpBuilder.buildResponse(
      response.getStatusCode(),
      response.getStatus(),
      response.getBody()
    );
  }
  private Map<String, String> getHeader(Map<String, object> params) {
    Map<String, String> header = new Map<String, String>();
    header.put('Content-Type', 'application/json');
    header.put('Accept', 'application/json');
    header.put(
      'Authorization',
      'Bearer ' + EncodingUtil.base64Encode(Blob.valueOf('Token'))
    );
    header.put(
      'X-UIPATH-OrganizationUnitId',
      HttpBuilder.getApiConstant('UipathOrgUnitId')
    );
    return header;
  }
}
