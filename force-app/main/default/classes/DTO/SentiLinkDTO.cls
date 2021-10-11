@SuppressWarnings('PMD.VariableNamingConventions')
public with sharing class SentiLinkDTO extends AbstractDTO {
  public class Request {
    public Application application;
    public List<Scores> scores;
    public List<ReqExtraData> extra_data;
    // public Request() {

    // }
  }
  public class Application {
    public String application_id;
    public String application_created;
    public String user_id;
    public String user_created;
    public String first_name;
    public String middle_name;
    public String last_name;
    public String dob;
    public String ssn;
    public String address_line_1;
    public String address_line_2;
    public String country_code;
    public String city;
    public String state_code;
    public String zipcode;
    public String phone;
    public String email;
    public String ip_address;
    public String device_id;
    public String business_name;
    public String business_url;
    public String lead_type;
    public String loan_amount;
    public String loan_currency;
    public Metadata metadata;
    public String alt_address_line_1;
    public String alt_address_line_2;
    public String alt_country_code;
    public String alt_city;
    public String alt_state_code;
    public String alt_zipcode;
    public String alt_phone;
    public String alt_email;
    public String sentilink_application_sid;
  }
  public class ReqExtraData {
    public String type;
  }

  public class Scores {
    public String score_name;
  }
  public class Metadata {
    public String any_additional_data;
  }
  public class Response {
    public String application_id;
    public String customer_id;
    public String environment;
    public Integer latency_ms;
    public String notes;
    public List<ResScores> scores;
    public ResExtraData extra_data;
    public String timestamp;
    public String transaction_id;
  }
  public class ResExtraData {
    public ConsumerHistory consumer_history;
    public Clusters clusters;
  }

  public class Attribute {
    public String value;
    public String attribute_type;
  }

  public class IssuanceInfo {
    public IssuanceLowerBound issuance_lower_bound;
    public IssuanceLowerBound issuance_upper_bound;
    public String location;
  }

  public class ResScores {
    public String name;
    public String version;
    public Integer score;
    public List<ReasonCodes> reason_codes;
  }

  public class Attributes {
    public Integer ssn_shared_count;
    public Integer name_dob_shared_count;
    public Boolean ssn_issuance_dob_mismatch;
    public Boolean ssn_issued_before_dob;
    public Boolean name_ssn_synthetic_address;
    public Boolean ssn_bogus;
    public Integer ssn_history_longer_months;
  }

  public class ReasonCodes {
    public String code;
    public Integer rank;
    public String direction;
    public String explanation;
  }

  public class Edges {
    public Integer from_index;
    public Integer to_index;
  }

  public class Names {
    public String first_name;
    public String last_name;
  }

  public class Addresses {
    public String street_address;
    public String zip;
    public String city;
    public String state;
    public FirstReported first_reported;
  }

  public class FirstReported {
    public Integer year;
    public Integer month;
  }

  public class PiiCorrections {
    public String corrected_ssn;
  }

  public class Phones {
    public String phone;
    public FirstReportedZ first_reported;
    public FirstReportedZ last_reported;
    public Boolean is_possible;
    public String phone_type;
  }

  public class MatchFields {
    public String field;
    public String match_type;
    public Integer match_index;
  }

  public class Clusters {
    public DataZ data;
  }

  public class Emails {
    public String email;
    public Boolean format_verified;
    public Boolean is_valid;
    public FirstReportedZ first_reported;
    public FirstReportedZ last_reported;
  }

  public class Identity {
    public List<Names> names;
    public List<Addresses> addresses;
    public List<Ssns> ssns;
    public List<FirstReportedZ> dobs;
    public List<FirstReportedZ> origination_dates;
    public List<FraudCodes> fraud_codes;
    public List<Phones> phones;
    public List<Emails> emails;
  }

  public class Identities {
    public MatchInfo match_info;
    public Identity identity;
  }

  public class ConsumerHistory {
    public Data data;
  }

  public class Ssns {
    public String ssn;
    public IssuanceInfo issuance_info;
  }

  public class Data {
    public Attributes attributes;
    public List<Identities> identities;
    public PiiCorrections pii_corrections;
  }

  public class FraudCodes {
    public String code;
    public String value;
  }

  public class Nodes {
    public String node_type;
    public Integer index;
    public Application application;
    public Attribute attribute;
  }

  public class MatchInfo {
    public List<MatchFields> match_fields;
    public List<MatchFields> match_details;
  }

  public class DataZ {
    public List<Nodes> nodes;
    public List<Edges> edges;
  }

  public class FirstReportedZ {
    public Integer year;
    public Integer month;
    public Integer day;
  }

  public class IssuanceLowerBound {
    public Integer year;
  }

  // public class Application {
  //   public String application_id;
  //   public String sentilink_application_sid;
  //   public String application_created;
  // }
}
