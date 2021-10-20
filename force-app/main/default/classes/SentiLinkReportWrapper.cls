/**
 * Copyright (c) 2021 Digital Align
 * @group Exception
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class SentiLinkReportWrapper {
  public GeneralInfo generalInfo { get; set; }
  public List<ScoresInfo> scores { get; set; }
  public Attributes attributes { get; set; }
  public SentiLinkReportWrapper() {
    generalInfo = new GeneralInfo();
    scores = new List<ScoresInfo>();
    attributes = new Attributes();
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

  public class Attributes {
    public Integer ssn_shared_count { get; set; }
    public Integer name_dob_shared_count { get; set; }
    public Boolean ssn_issuance_dob_mismatch { get; set; }
    public Boolean ssn_issued_before_dob { get; set; }
    public Boolean name_ssn_synthetic_address { get; set; }
    public Boolean ssn_bogus { get; set; }
    public Integer ssn_history_longer_months { get; set; }
    public Attributes() {
      ssn_shared_count = 0;
      name_dob_shared_count = 0;
    }
  }

  public class ScoresInfo {
    public String name { get; set; }
    public String version { get; set; }
    public Integer score { get; set; }
    public List<ReasonCodes> reasonCodes { get; set; }

    public ScoresInfo() {
      this.name = this.version = '';
      this.score = 0;
      reasonCodes = new List<ReasonCodes>();
    }
  }
  public class ReasonCodes {
    public String code { get; set; }
    public Integer rank { get; set; }
    public String direction { get; set; }
    public String explanation { get; set; }

    public ReasonCodes() {
      this.code = this.direction = this.explanation = '';
      this.rank = 0;
    }
  }
}
