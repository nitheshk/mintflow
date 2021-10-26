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
  global virtual object invokeAPI(Map<String, object> params) {
    log?.fine('Inside invokeAPI -> params -> ' + Json.serialize(params));
    GeocodingDTO.Response response;
    GeocodingDTO.ReturnResponse returnResponse = new GeocodingDTO.ReturnResponse();
    try {
      setApiConfiguration(params);
      HttpResponse res = ExternalAPICallOut.execute(null, null);
      response = (GeocodingDTO.Response) JSON.deserialize(
        res.getBody(),
        GeocodingDTO.Response.class
      );
      if (response.results == null) {
        return null;
      } else {
        for (GeocodingDTO.Results results : response.results) {
          List<GeocodingDTO.MatchingAddress> matchingAddresses = new List<GeocodingDTO.MatchingAddress>();
          GeocodingDTO.matchingAddress add = new GeocodingDTO.matchingAddress();
          for (
            GeocodingDTO.AddressComponents addresses : results.address_components
          ) {
            for (string type : addresses.types) {
              switch on type {
                when 'country' {
                  add.country = addresses.long_name;
                  break;
                }
                when 'postal_code' {
                  add.zipcode = addresses.long_name;
                  break;
                }
                when 'locality' {
                  add.locality = addresses.long_name;
                  break;
                }
                when 'administrative_area_level_2' {
                  add.county = addresses.long_name;
                  break;
                }
                when 'administrative_area_level_1' {
                  add.state = addresses.long_name;
                  if (
                    addresses.long_name == 'oregaon' ||
                    addresses.long_name == 'Idhaho' ||
                    addresses.long_name == 'Washington'
                  )
                    returnResponse.isCountyEligible = true;
                  else
                    returnResponse.isCountyEligible = false;
                  break;
                }
                when 'neighborhood' {
                  add.neighborhood = addresses.long_name;
                  break;
                }
                when else {
                  break;
                }
              }
            }
          }
          matchingAddresses.add(add);
          returnResponse.matchingAddress = matchingAddresses;
          break;
        }
      }
      log
        ?.info(
          'invokeAPI -> ReturnResponse -> ' + Json.serialize(returnResponse)
        );
      return returnResponse;
    } catch (Exception ex) {
      throw new CustomException(ex.getMessage());
    }
  }
  /**
   * @description
   * @author Digital Align | 10-26-2021
   * @param Map<String object> params
   **/
  private static void setApiConfiguration(Map<String, object> params) {
    if (
      APIConfigurationService.getAPISettings(APINames.Geocoding).isActive__c
    ) {
      APIConfigurationService.setAPISettings(APINames.Geocoding);
      APIConfigurationService.apiSetting.EndPoint__c = APIConfigurationService.apiSetting.EndPoint__c.replace(
        '{APIKey}',
        APIConfigurationService.getAPIConstants('GeocodingAPIKey')
      );
      APIConfigurationService.apiSetting.EndPoint__c = APIConfigurationService.apiSetting.EndPoint__c.replace(
        '{Pincode}',
        (string) params.get('zipcode')
      );
    } else {
      throw new CustomException('Requested API is disabled');
    }
  }
}
