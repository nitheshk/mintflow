/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Sent iLink SentiLinkDTODTO
 **/

@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
global with sharing class SentiLinkDTO extends AbstractDTO {
  global class Request {
    global Application application;
    global List<ReqScores> scores;
    global List<ReqExtraData> extra_data;
    global Request() {
      application = new Application();
      scores = new List<ReqScores>();
      extra_data = new List<ReqExtraData>();
    }
  }
  global class Application {
    global String application_id;
    global String application_created;
    global String user_id;
    global String user_created;
    global String first_name;
    global String middle_name;
    global String last_name;
    global String dob;
    global String ssn;
    global String address_line_1;
    global String address_line_2;
    global String country_code;
    global String city;
    global String state_code;
    global String zipcode;
    global String phone;
    global String email;
    global String ip_address;
    global String device_id;
    global String business_name;
    global String business_url;
    global String lead_type;
    global String loan_amount;
    global String loan_currency;
    global Metadata metadata;
    global String alt_address_line_1;
    global String alt_address_line_2;
    global String alt_country_code;
    global String alt_city;
    global String alt_state_code;
    global String alt_zipcode;
    global String alt_phone;
    global String alt_email;
    global String sentilink_application_sid;
  }
  global class ReqExtraData {
    global String type;
    public ReqExtraData(String type) {
      this.type = type;
    }
  }

  global class ReqScores {
    global String score_name;
    global ReqScores(String score_name) {
      this.score_name = score_name;
    }
  }
  global class Metadata {
    global String any_additional_data;
  }
  global class Response {
    global String application_id;
    global String customer_id;
    global String environment;
    global Integer latency_ms;
    global String notes;
    global List<ResScores> scores;
    global ResExtraData extra_data;
    global String timestamp;
    global String transaction_id;
  }
  global class ResExtraData {
    global ConsumerHistory consumer_history;
    global Clusters clusters;
  }

  global class Attribute {
    global String value;
    global String attribute_type;
  }

  global class IssuanceInfo {
    global IssuanceLowerBound issuance_lower_bound;
    global IssuanceLowerBound issuance_upper_bound;
    global String location;
  }

  global class ResScores {
    global String name;
    global String version;
    global Integer score;
    global List<ReasonCodes> reason_codes;
  }

  global class Attributes {
    global Integer ssn_shared_count;
    global Integer name_dob_shared_count;
    global Boolean ssn_issuance_dob_mismatch;
    global Boolean ssn_issued_before_dob;
    global Boolean name_ssn_synthetic_address;
    global Boolean ssn_bogus;
    global Integer ssn_history_longer_months;
  }

  global class ReasonCodes {
    global String code;
    global Integer rank;
    global String direction;
    global String explanation;
  }

  global class Edges {
    global Integer from_index;
    global Integer to_index;
  }

  global class Names {
    global String first_name;
    global String last_name;
  }

  global class Addresses {
    global String street_address;
    global String zip;
    global String city;
    global String state;
    global FirstReported first_reported;
  }

  global class FirstReported {
    global Integer year;
    global Integer month;
  }

  global class PiiCorrections {
    global String corrected_ssn;
  }

  global class Phones {
    global String phone;
    global FirstReportedZ first_reported;
    global FirstReportedZ last_reported;
    global Boolean is_possible;
    global String phone_type;
  }

  global class MatchFields {
    global String field;
    global String match_type;
    global Integer match_index;
  }

  global class Clusters {
    global DataZ data;
  }

  global class Emails {
    global String email;
    global Boolean format_verified;
    global Boolean is_valid;
    global FirstReportedZ first_reported;
    global FirstReportedZ last_reported;
  }

  global class Identity {
    global List<Names> names;
    global List<Addresses> addresses;
    global List<Ssns> ssns;
    global List<FirstReportedZ> dobs;
    global List<FirstReportedZ> origination_dates;
    global List<FraudCodes> fraud_codes;
    global List<Phones> phones;
    global List<Emails> emails;
  }

  global class Identities {
    global MatchInfo match_info;
    global Identity identity;
  }

  global class ConsumerHistory {
    global Data data;
  }

  global class Ssns {
    global String ssn;
    global IssuanceInfo issuance_info;
  }

  global class Data {
    global Attributes attributes;
    global List<Identities> identities;
    global PiiCorrections pii_corrections;
  }

  global class FraudCodes {
    global String code;
    global String value;
  }

  global class Nodes {
    global String node_type;
    global Integer index;
    global Application application;
    global Attribute attribute;
  }

  global class MatchInfo {
    global List<MatchFields> match_fields;
    global List<MatchFields> match_details;
  }

  global class DataZ {
    global List<Nodes> nodes;
    global List<Edges> edges;
  }

  global class FirstReportedZ {
    global Integer year;
    global Integer month;
    global Integer day;
  }

  global class IssuanceLowerBound {
    global Integer year;
  }

  // global class Application {
  //   global String application_id;
  //   global String sentilink_application_sid;
  //   global String application_created;
  // }
}
