public with sharing class GeocodingProvider {
  public static Map<String, object> invokeAPI(Map<String, object> params) {
    GeocodingDTO.Response response;
    GeocodingDTO.ReturnResponse returnResponse = new GeocodingDTO.ReturnResponse();

    try {
      if (params != null) {
        setApiConfiguration(params);
        HttpResponse res = ExternalAPICallOut.execute(null, null);
        if (res.getBody() != null) {
          response = (GeocodingDTO.Response) JSON.deserialize(
            res.getBody(),
            GeocodingDTO.Response.class
          );
          for (GeocodingDTO.Results results : response.results) {
            List<GeocodingDTO.MatchingAddress> matchingAddresses = new List<GeocodingDTO.MatchingAddress>();
            GeocodingDTO.matchingAddress add = new GeocodingDTO.matchingAddress();
            for (
              GeocodingDTO.AddressComponents addresses : results.address_components
            ) {
              System.debug('addresses.types =' + addresses.types);
              for (string type : addresses.types) {
                System.debug('types =' + type);
                switch on type {
                  when 'country' {
                    add.country = addresses.long_name;
                    // matchingAddresses.add(add);
                    break;
                  }
                  when 'postal_code' {
                    add.zipcode = addresses.long_name;
                    // matchingAddresses.add(add);
                    break;
                  }
                  when 'locality' {
                    add.locality = addresses.long_name;
                    // matchingAddresses.add(add);
                    break;
                  }
                  when 'administrative_area_level_2' {
                    add.county = addresses.long_name;
                    // matchingAddresses.add(add);
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
                    matchingAddresses.add(add);
                    break;
                  }
                  when 'neighborhood' {
                    add.neighborhood = addresses.long_name;
                    // matchingAddresses.add(add);
                    break;
                  }
                  when else {
                    System.debug('in else types =' + type);
                    break;
                  }
                }
              }
            }
            matchingAddresses.add(add);
            System.debug('matchingAddresses =' + matchingAddresses);
            returnResponse.matchingAddress = matchingAddresses;
            System.debug('returnResponse =' + returnResponse.matchingAddress);
          }
          system.debug('DTO response = ' + response);
          return (new Map<String, Object>());
        } else {
          throw new CustomException('Empty Parameter Passed');
        }
      } else {
        throw new CustomException('empty params');
      }
    } catch (Exception ex) {
      return (new Map<String, object>{
        'Status' => '400',
        'StatusMessage' => ex.getMessage(),
        'Data' => null
      });
    }
  }
  private static void setApiConfiguration(Map<String, object> params) {
    string zipcode = (string) params.get('zipcode');
    if (string.isBlank(zipcode)) {
      throw new CustomException('Zipcode value notset');
    }
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
        zipcode
      );
    } else {
      throw new CustomException('Requested API is disabled');
    }
  }
}
