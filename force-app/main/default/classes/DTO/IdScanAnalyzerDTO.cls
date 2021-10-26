@SuppressWarnings('PMD.VariableNamingConventions')
public with sharing class IdScanAnalyzerDTO {
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
}
