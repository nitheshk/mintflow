/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GeocodingProvider extends AbstractService {
  @TestVisible
  private static GeocodingProvider serviceInstance;

  public GeocodingProvider() {
    super(GeocodingProvider.class);
  }

  /**
   * @description Provides a singleton instance of GeocodingProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static GeocodingProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (GeocodingProvider) getInstance(
        GeocodingProvider.class
      );
    }
    return serviceInstance;
  }
  /**
   * @description
   * @author Digital Align | 10-26-2021
   * @param Map<String object> params
   * @return GeocodingDTO.ReturnResponse
   **/
  global virtual object validateCountyUsingGoogleApi(
    Map<String, object> params
  ) {
    log?.fine('Inside invokeAPI -> params -> ' + Json.serialize(params));

    try {
      HttpResponse response = HttpBuilder.httpCallOut(null, null);
      flow.setSubFlowResponse(response?.getBody());
      system.debug('response : ' + response);

      if (response.getStatusCode() != 200) {
        return HttpBuilder.buildResponse(response);
      }
      GeocodingDTO.Response dto = (GeocodingDTO.Response) JSON.deserialize(
        response.getBody(),
        GeocodingDTO.Response.class
      );

      Map<String, Object> result = new Map<String, Object>();
      Boolean isCountyEligible = false;
      result.put('isCountyEligible', isCountyEligible);

      if (dto?.status != 'OK') {
        return HttpBuilder.buildResponse(
          response.getStatusCode(),
          response.getStatus(),
          result
        );
      }

      Map<String, Object> mathcingResult = new Map<String, Object>();
      for (
        GeocodingDTO.AddressComponents addresses : dto.results[0]
          .address_components
      ) {
        for (string type : addresses.types) {
          switch on type {
            when 'country', 'locality', 'neighborhood' {
              mathcingResult.put(type, addresses.long_name);
              break;
            }
            when 'postal_code' {
              mathcingResult.put('zipcode', addresses.long_name);
              break;
            }
            when 'administrative_area_level_2' {
              mathcingResult.put('county', addresses.long_name);
              break;
            }
            when 'administrative_area_level_1' {
              mathcingResult.put('state', addresses.long_name);
              if (
                addresses.long_name == 'oregaon' ||
                addresses.long_name == 'Idhaho' ||
                addresses.long_name == 'Washington'
              ) {
                isCountyEligible = true;
              }
              break;
            }
          }
        }
      }
      result.put('matchingAddress', new List<Object>{ mathcingResult });
      result.put('isCountyEligible', isCountyEligible);
      return HttpBuilder.buildResponse(
        response.getStatusCode(),
        response.getStatus(),
        result
      );
    } catch (Exception ex) {
      log?.error(ex);
      return HttpBuilder.buildResponse(400, ex.getMessage(), null);
    }
  }
}
