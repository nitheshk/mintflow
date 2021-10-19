/**
 * Copyright (c) 2021 Digital Align
 * @group Exception
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class SentiLinkReportDTO {
  //used in LWC
  public class KYCJsonDTO {
    @AuraEnabled
    public String contentDocumentId { get; set; }
    @AuraEnabled
    public String title { get; set; }
    @AuraEnabled
    public String documentType { get; set; }
    @AuraEnabled
    public String reportUrl { get; set; }
    @AuraEnabled
    public String createDate { get; set; }
    public KYCJsonDTO(
      String contentDocumentId,
      String title,
      String documentType,
      DateTime createDate
    ) {
      this.contentDocumentId = contentDocumentId;
      this.title = title;
      this.documentType = documentType;
      this.createDate = createDate.format(
        'MM/dd/yyyy hh:mm:ss a',
        UserInfo.getTimeZone().getID()
      );
    }
  }

  // used in report display

  public GeneralInfo generalInfo { get; set; }

  public SentiLinkReportDTO() {
    generalInfo = new GeneralInfo();
  }

  public class Response {
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

  public class GeneralInfo {
    public String rawResponse { get; set; }
    public String applicationId { get; set; }
    public String timestamp { get; set; }
    public String transactionId { get; set; }

    public GeneralInfo() {
      this.rawResponse = this.applicationId = this.timestamp = this.transactionId = '';
    }
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

  public class Phones {
    public String phone;
    public First_reported_Z first_reported;
    public First_reported_Z last_reported;
    public Boolean is_possible;
    public String phone_type;
  }

  public class Match_fields {
    public String field;
    public String match_type;
    public Integer match_index;
  }

  public class Clusters {
    public Data_Z data;
  }

  public class Emails {
    public String email;
    public Boolean format_verified;
    public Boolean is_valid;
    public First_reported_Z first_reported;
    public First_reported_Z last_reported;
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

  public class Identities {
    public Match_info match_info;
    public Identity identity;
  }

  public class Consumer_history {
    public Data data;
  }

  public class Ssns {
    public String ssn;
    public Issuance_info issuance_info;
  }

  public class Data {
    public Attributes attributes;
    public List<Identities> identities;
    public Pii_corrections pii_corrections;
  }

  public class Fraud_codes {
    public String code;
    public String value;
  }

  public class Nodes {
    public String node_type;
    public Integer index;
    public Application application;
    public Attribute attribute;
  }

  public class Match_info {
    public List<Match_fields> match_fields;
    public List<Match_fields> match_details;
  }

  public class Data_Z {
    public List<Nodes> nodes;
    public List<Edges> edges;
  }

  public class First_reported_Z {
    public Integer year;
    public Integer month;
    public Integer day;
  }

  public class Issuance_lower_bound {
    public Integer year;
  }

  public class Application {
    public String application_id;
    public String sentilink_application_sid;
    public String application_created;
  }
}
