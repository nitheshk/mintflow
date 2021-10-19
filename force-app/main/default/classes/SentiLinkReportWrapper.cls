/**
 * Copyright (c) 2021 Digital Align
 * @group Exception
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class SentiLinkReportWrapper {
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
  public List<ScoresInfo> scores { get; set; }

  public SentiLinkReportWrapper() {
    generalInfo = new GeneralInfo();
    scores = new List<ScoresInfo>();
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

  public class ScoresInfo {
    public String name { get; set; }
    public String version { get; set; }
    public Integer score { get; set; }
    public List<ReasonCodes> reasonCodes;

    public ScoresInfo() {
      this.name = this.version = '';
      this.score = 0;
      reasonCodes = new List<ReasonCodes>();
    }
  }
  public class ReasonCodes {
    public String code;
    public Integer rank;
    public String direction;
    public String explanation;

    public ReasonCodes() {
      this.code = this.direction = this.explanation = '';
      this.rank = 0;
    }
  }
}
