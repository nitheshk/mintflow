/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description PlaidTokenDTO
 **/
@SuppressWarnings('PMD.VariableNamingConventions,PMD.ExcessivePublicCount')
public with sharing class AlloyDTO extends AbstractDTO {
  public class IDVRequest {
    public String name_first;
    public String name_last;
    public String document_ssn;
    public String address_line_1;
    public String address_city;
    public String address_state;
    public String address_postal_code;
    public String address_country_code;
    public String birth_date;
    public String email_address;
    public String phone_number;
    public String iovation_blackbox;
    public String ip_address_v4;
    public String document_license;
    public String document_license_state;
    public String document_token_front;
    public String document_token_back;
    public Meta meta;
  }

  public class Meta {
  }

  public static String generateRequest(Object requestObj) {
    return System.JSON.serializePretty(requestObj);
  }

  public class IDVResponse {
    public Integer status_code;
    public Error error;
    public Long timestamp;
    public String evaluation_token;
    public String entity_token;
    //public Object parent_entity_token;
    public String application_token;
    public Integer application_version_id;
    //public Object champion_challenger_id;
    public Summary summary;
    public Matching matching;
    //public Object audit_archive;
    public FormattedResponses formatted_responses;
  }

  public class FormattedResponses {
    public QualiFile QualiFile;
  }

  public class QualiFile {
    public Data data;
  }

  public class Data {
    public SubQualiFile qualifile;
  }
  public class SubQualiFile {
    public Integer score;
  }

  public class Error {
    public String minor_code;
    public String type;
    public String message;
    public String error_token;
  }

  public class Summary {
    public String result;
    public Double score;
    public List<String> tags;
    public String outcome;
    public Services services;
    //public Object alloy_fraud_score;
  }

  public class Services {
    public String WhitePagesPro;
    public String Socure30;
    public String Iovation;
    public String QualiFile;
  }

  public class Matching {
    public MatchingItems email;
    public MatchingItems name;
    public MatchingItems address;
    public MatchingItems dob;
    public MatchingItems phone;
    public MatchingItems ssn;
    public Double average_score;
  }

  public class MatchingItems {
    public Double score;
    public List<String> matched;
  }

  public class RawQualiFile {
    public CallChexSystemsService callChexSystemsServiceV001Return;
  }

  public class CallChexSystemsService {
    public String txtReport;
  }

  public static IDVResponse parseIDVResponse(String json) {
    return (IDVResponse) System.JSON.deserialize(replaceJson(json), IDVResponse.class);
  }

  private static String replaceJson(String json) {
    json.replace('White Pages Pro', 'WhitePagesPro');
    json.replace('Socure 30', 'Socure30');
    return json;
  }

  public class CreateDocumentRequest {
    public String name;
    public String extension;
    public String type;
  }

  public class CreateDocumentResponse {
    public String document_token;
  }

  public static CreateDocumentResponse parseCreateDocumentResponse(String json) {
    return (CreateDocumentResponse) System.JSON.deserialize(json, CreateDocumentResponse.class);
  }

  public class UploadDocumentResponse {
    public String document_token;
    public Boolean uploaded;
  }

  public static UploadDocumentResponse parseUploadDocumentResponse(String json) {
    return (UploadDocumentResponse) System.JSON.deserialize(json, UploadDocumentResponse.class);
  }
}
