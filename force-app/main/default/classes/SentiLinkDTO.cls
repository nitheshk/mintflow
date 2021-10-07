@SuppressWarnings('PMD.VariableNamingConventions')
public with sharing class SentiLinkDTO extends AbstractDTO {
  public class Request {
    public Application application;
    public List<Scores> scores;
  }
  public class Metadata {
    public String account_id;
    public Integer fico;
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
  public class IdCompletionResponse {
    public Application application;
    public String customer_id;
    public String environment;
    public Integer latency_ms;
    public String timestamp;
    public String transaction_id;
    public List<String> updated_fields;
    public String confidence_level;
  }

  public class EcbsvResponse {
    public String application_id;
    public Boolean ssa_verified;
    public Boolean deceased;
    public String customer_id;
    public String environment;
    public Integer latency_ms;
    public String timestamp;
    public String transaction_id;
  }
  public class ScoresResponse {
    public String application_id;
    public String customer_id;
    public String environment;
    public Integer latency_ms;
    public String notes;
    public List<Scores> scores;
    public Extra_data extra_data;
    public String timestamp;
    public String transaction_id;
  }
  public class Issuance_lower_bound {
    public Integer year;
  }
  public class First_reported_Z {
    public Integer year;
    public Integer month;
    public Integer day;
  }
  public class Data_Z {
    public List<Nodes> nodes;
    public List<Edges> edges;
  }
  public class Match_info {
    public List<Match_fields> match_fields;
    public List<Match_fields> match_details;
  }
  public class Nodes {
    public String node_type;
    public Integer index;
    public Application application;
    public Attribute attribute;
  }
  public class Fraud_codes {
    public String code;
    public String value;
  }
  public class Data {
    public Attributes attributes;
    public List<Identities> identities;
    public Pii_corrections pii_corrections;
  }
  public class Ssns {
    public String ssn;
    public Issuance_info issuance_info;
  }
  public class Consumer_history {
    public Data data;
  }
  public class Identities {
    public Match_info match_info;
    public Identity identity;
  }
  public class Identity {
    public List<Names> names;
    public List<Addresses> addresses;
    public List<Ssns> ssns;
    public List<First_reported_Z> dobs;
    public List<First_reported_Z> origination_dates;
    public List<Fraud_codes> fraud_codes;
    public List<Phones> phones;
    public List<Emails> emails;
  }
  public class Emails {
    public String email;
    public Boolean format_verified;
    public Boolean is_valid;
    public First_reported_Z first_reported;
    public First_reported_Z last_reported;
  }
  public class Clusters {
    public Data_Z data;
  }
  public class Match_fields {
    public String field;
    public String match_type;
    public Integer match_index;
  }
  public class Phones {
    public String phone;
    public First_reported_Z first_reported;
    public First_reported_Z last_reported;
    public Boolean is_possible;
    public String phone_type;
  }
  public class Extra_data {
    public Consumer_history consumer_history;
    public Clusters clusters;
  }

  public class Attribute {
    public String value;
    public String attribute_type;
  }

  public class Issuance_info {
    public Issuance_lower_bound issuance_lower_bound;
    public Issuance_lower_bound issuance_upper_bound;
    public String location;
  }

  public class Scores {
    public String name;
    public String version;
    public Integer score;
    public List<Reason_codes> reason_codes;
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

  public class Reason_codes {
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
    public First_reported first_reported;
  }

  public class First_reported {
    public Integer year;
    public Integer month;
  }

  public class Pii_corrections {
    public String corrected_ssn;
  }
}
