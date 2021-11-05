/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description Geocoding DTO
 **/

@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
global with sharing class GeocodingDTO extends AbstractDTO {
  //Response from API
  global class Response {
    global List<Results> results;
    global String status;
  }

  global class AddressComponents {
    global String long_name;
    global String short_name;
    global List<String> types;
  }

  global class Geometry {
    global Bounds bounds;
    global Northeast location;
    global String location_type;
    global Bounds viewport;
  }
  global class Results {
    global List<AddressComponents> address_components;
    global String formatted_address;
    global Geometry geometry;
    global String place_id;
    global List<String> types;
  }

  global class Bounds {
    global Northeast northeast;
    global Northeast southwest;
  }

  global class Northeast {
    global Double lat;
    global Double lng;
  }
}
