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
   * @author Digital Align Team | 11-01-2021
   * @param Map<String object> params
   * @return HttpBuilder.Response
   **/
  global virtual HttpBuilder.Response validateCountyUsingGoogleApi(
    Map<String, object> params
  ) {
    log?.fine('Inside invokeAPI -> params -> ' + Json.serialize(params));

    HttpResponse response = HttpBuilder.httpCallOut(null, null);
    flow.setSubFlowResponse(response?.getBody());
    log?.debug('response : ' + response.getBody());

    if (response.getStatusCode() != 200) {
      throw new CustomException(response.getStatus());
    }
    GeocodingDTO.Response responseDTO = (GeocodingDTO.Response) JSON.deserialize(
      response.getBody(),
      GeocodingDTO.Response.class
    );

    return HttpBuilder.buildResponse(
      response.getStatusCode(),
      response.getStatus(),
      mapGeoLocation(
        responseDTO,
        (List<string>) params.get('eligibleCountyNameList')
      )
    );
  }

  /**
   * @description map geo location to required format
   * @author Digital Align Team | 11-01-2021
   * @param GeocodingDTO.Response responseDTO
   * @return virtual
   **/
  global virtual Map<String, Object> mapGeoLocation(
    GeocodingDTO.Response responseDTO,
    List<string> eligibleCountyNameList
  ) {
    Map<String, Object> result = new Map<String, Object>();
    Boolean isCountyEligible = false;
    result.put('isCountyEligible', isCountyEligible);

    if (responseDTO?.status != 'OK') {
      return result;
    }

    Map<String, Object> mathcingResult = new Map<String, Object>();
    for (
      GeocodingDTO.AddressComponents addresses : responseDTO.results[0]
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
            if (eligibleCountyNameList.contains(addresses.long_name)) {
              isCountyEligible = true;
            }
            break;
          }
        }
      }
    }
    result.put('matchingAddress', new List<Object>{ mathcingResult });
    result.put('isCountyEligible', isCountyEligible);

    return result;
  }
}
