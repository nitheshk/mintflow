@SuppressWarnings('PMD.VariableNamingConventions')
public with sharing class DocumentScanDTO extends AbstractDTO {
  public class Request {
    public String file_base64;
    public String file_back_base64;
    public String biometric_threshold;
    public String authenticate;
    public String authenticate_module;
    public String checkblocklist;
    public String verify_expiry;
    public String dualsidecheck;
    public String aml_check;
    public String aml_database;
    public String aml_strict_match;
    public String contract_format;
    public String vault_save;
    public String vault_saveunrecognized;
    public String vault_noduplicate;
    public String vault_automerge;
    public String outputimage;
    public String outputface;
    public String outputmode;
    public String accuracy;
    public String return_confidence;
    public String ocr_scaledown;
    public String apikey;
  }

  public class Response {
    public Data data;
    public String displayMessage;
    public String errorMessage;
    public Integer status;
  }
  public class Validation {
    public Boolean isExpired;
    public String score;
    public Boolean imageQualityPassed;
    public Boolean securityCheckPassed;
  }
  public class Data {
    public String documentNumber;
    public String firstName;
    public String lastName;
    public String fullName;
    public String gender;
    public String height;
    public String weight;
    public String dob;
    public String expiry;
    public String issued;
    public String address1;
    public String address2;
    public String postalCode;
    public String documentType;
    public String issuerRegion;
    public String issuerCountry;
    public String nationality;
    public Validation validation;
  }
}
