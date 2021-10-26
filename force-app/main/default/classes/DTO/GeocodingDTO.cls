@SuppressWarnings('PMD.VariableNamingConventions')
public with sharing class GeocodingDTO extends AbstractDTO {
  // Formatted response
  public class ReturnResponse {
    public List<MatchingAddress> matchingAddress;
    public Boolean isCountyEligible;
  }
  public class MatchingAddress {
    public string country;
    public String state;
    public String county;
    public String locality;
    public String neighborhood;
    public String zipcode;
  }

  //Response from API
  public class Response {
    public List<Results> results;
    public String status;
  }

  public class AddressComponents {
    public String long_name;
    public String short_name;
    public List<String> types;
  }

  public class Geometry {
    public Bounds bounds;
    public Northeast location;
    public String location_type;
    public Bounds viewport;
  }
  public class Results {
    public List<AddressComponents> address_components;
    public String formatted_address;
    public Geometry geometry;
    public String place_id;
    public List<String> types;
  }

  public class Bounds {
    public Northeast northeast;
    public Northeast southwest;
  }

  public class Northeast {
    public Double lat;
    public Double lng;
  }
}
