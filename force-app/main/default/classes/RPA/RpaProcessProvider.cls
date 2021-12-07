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
    flow.setSubFlowRequest(json.serialize(params, true));
    HttpResponse response = HttpBuilder.httpCallOut(
      json.serialize(params, true),
      getHeader()
    );
    if (response.getStatusCode() != 201) {
      throw new CustomException(response.getBody());
    }
    return HttpBuilder.buildResponse(
      response.getStatusCode(),
      response.getStatus(),
      response.getBody()
    );
  }
  private Map<String, String> getHeader() {
    Map<String, String> header = new Map<String, String>();
    header.put('Content-Type', 'application/json');
    header.put('Accept', 'application/json');
    header.put(
      'Authorization',
      'Bearer ' +
      'eyJhbGciOiJSUzI1NiIsImtpZCI6IkExRTAxNjE4MkYxMTI5QjMwNTIxOUY2OUQ2REY0N0UzMEQzRDJGQzJSUzI1NiIsInR5cCI6IkpXVCIsIng1dCI6Im9lQVdHQzhSS2JNRklaOXAxdDlINHcwOUw4SSJ9.eyJuYmYiOjE2Mzg4OTQ3MzYsImV4cCI6MTYzODg5ODYzNiwiaXNzIjoiaHR0cHM6Ly9jbG91ZC51aXBhdGguY29tL2lkZW50aXR5XyIsImF1ZCI6IlVpUGF0aC5PcmNoZXN0cmF0b3IiLCJjbGllbnRfaWQiOiI3Njc1MzBlMi1mZGQ1LTQ0MGQtYmZhMy1lMDI3YTIyNjIzNmMiLCJwcnRfaWQiOiIyZmZkZTZhMy0wNzZlLTRiNDEtOGZhNC1jNGJkMDVkODRkODQiLCJqdGkiOiJBQ0EyMDk5MzY5OEQ2MTMxN0FEMUZFQjBFQ0Q3RkI4MiIsImlhdCI6MTYzODg5NTAzNiwic2NvcGUiOlsiT1IuUXVldWVzIl19.EDhVJOPdIJLNfSYlUxYpFUrEXpMDi6uIVfOnqZgxJPA8tYzCTXC258byNBAuCIw9jB1w3H1X9A0JJ4WrLE1eG6nvOaclFRSurU1c7f3kycF1iFyNgKaw7BqEc86KMktQyvJSB1AeSnEe2hYGs1lxWgvH5iYwetUOU8HUSXic_Jl0E8AM-i6sVjXvdszt3yZdxXuQVcgBmc5aP7zMtc_YqGoGqaHP9MXj63EjCJ1lrVyYoJxR-XbvZWWYnIYexbHWFab5Vj1M3N4dRP2S81_Ine7A-W7ekha3NQOhkvt_ULUJd3JaUr8sDAi_VjIf5hajrhnVv5k-CtsrjWTFsdy3ng'
      //EncodingUtil.base64Encode(Blob.valueOf('Token')) //#pending
    );
    header.put(
      'X-UIPATH-OrganizationUnitId',
      HttpBuilder.getApiConstant('UipathOrgUnitId')
    );
    return header;
  }
}
