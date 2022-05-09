@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class AlloyKYCReportDTO {
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

    public KYCJsonDTO(String contentDocumentId, String title, String documentType, DateTime createDate) {
      this.contentDocumentId = contentDocumentId;
      this.title = title;
      this.documentType = documentType;
      this.reportUrl = '/apex/mflow__AlloyKYCReport?id=' + contentDocumentId;
      this.createDate = createDate.format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID());
    }
  }

  // used in report display
  public List<String> tags { get; set; }
  public List<MatchedData> matchedData { get; set; }
  public Map<String, String> formattedData { get; set; }
  public Map<String, String> nameValueMapping { get; set; }
  public Summary summary { get; set; }
  public Diligence diligence { get; set; }
  public OtherData otherData { get; set; }
  public DeviceData deviceData { get; set; }
  public AdditionalInfo additionalInfo { get; set; }
  public Map<String, Map<String, String>> reasonCodes { get; set; }

  public AlloyKYCReportDTO() {
    tags = new List<String>();
    matchedData = new List<MatchedData>();
    deviceData = new DeviceData();
    formattedData = new Map<String, String>();
    nameValueMapping = new Map<String, String>();
    summary = new Summary();
    diligence = new Diligence();
    otherData = new OtherData();
    additionalInfo = new AdditionalInfo();
    reasonCodes = new Map<String, Map<String, String>>();
  }

  public Map<String, String> labelMapping = new Map<String, String>{ 'dob' => 'Date Of Birth', 'ssn' => 'SSN' };

  /**
   * @description
   * @param String fieldName
   * @return String
   **/
  public String getFieldLabelMapping(String fieldName) {
    if (labelMapping.containsKey(fieldName)) {
      return labelMapping.get(fieldName);
    } else if (fieldName != null) {
      return fieldName.capitalize();
    }
    return '';
  }

  /**
   * @description
   * @return Map<String, String>
   **/
  public Map<String, String> setNameValueMapping() {
    return new Map<String, String>{
      'name' => getformattedDetail('name_first') +
      ' ' +
      getformattedDetail('name_last'),
      'address' => getformattedDetail('address_line_1') +
      ' ' +
      getformattedDetail('address_city') +
      ' ' +
      getformattedDetail('address_country_code') +
      ' ' +
      getformattedDetail('address_postal_code'),
      'email' => getformattedDetail('email_address'),
      'phone' => getformattedDetail('phone_number'),
      'dob' => getformattedDateDetail('birth_date'),
      'ssn' => getformattedSSNDetail('document_ssn')
    };
  }

  /**
   * @description
   * @param String name
   * @return String
   **/
  public String getformattedDetail(String name) {
    if (formattedData.containsKey(name)) {
      return formattedData.get(name);
    }
    return '';
  }
  /**
   * @description
   * @param String name
   * @return String
   **/
  public String getformattedDateDetail(String name) {
    if (formattedData.containsKey(name)) {
      Date bDate = Date.valueOf(formattedData.get(name));
      String birthdate = '';
      if (bDate != null) {
        birthdate = bDate.month() + '/' + bDate.day() + '/' + bDate.year();
      }
      return birthdate;
    }
    return '';
  }

  /**
   * @description
   * @param String name
   * @return String
   **/
  public String getformattedSSNDetail(String name) {
    if (formattedData.containsKey(name)) {
      String ssn = formattedData.get(name);
      String birthdate = '';
      if (ssn != null) {
        ssn = ssn.left(3) + '-' + ssn.left(5).right(2) + '-' + ssn.right(4);
      }
      return ssn;
    }
    return '';
  }

  public class MatchedData {
    public String fieldName { get; set; }
    public String fieldValue { get; set; }
    public String fieldScore { get; set; }
    public List<String> matchedService { get; set; }
    public List<String> unmatchedService { get; set; }

    public MatchedData() {
      this.matchedService = new List<String>();
      this.unmatchedService = new List<String>();
    }
    public MatchedData(String fieldName, String fieldValue, String fieldScore) {
      this.fieldName = fieldName;
      this.fieldValue = fieldValue;
      this.fieldScore = fieldScore;
    }
  }

  public class Summary {
    public String outcome { get; set; }
    public String score { get; set; }
    public List<String> tags { get; set; }
    public Map<String, String> services { get; set; }
    public Summary() {
      outcome = score = '';
      tags = new List<String>();
      services = new Map<String, String>();
    }
  }

  public class Diligence {
    //public Map<String, String> watchList { get; set; }
    public List<Object> watchList { get; set; }
    public String fraudScore { get; set; }
    public String fraudAverageScore { get; set; }
    public List<FraudSource> fraudSources { get; set; }
    public List<FinancialSource> financialSources { get; set; }
    public Diligence() {
      this.fraudScore = this.fraudAverageScore = '';
      this.watchList = new List<Object>();
      this.fraudSources = new List<FraudSource>();
      this.financialSources = new List<FinancialSource>();
    }
  }

  public class FraudSource {
    public String sourceName { get; set; }
    public String sourceRawScore { get; set; }
    public String sourceNormalizedScore { get; set; }
    public String sourceType { get; set; }
    public FraudSource() {
      this.sourceName = this.sourceRawScore = this.sourceNormalizedScore = this.sourceType = '';
    }
  }

  public class FinancialSource {
    public String sourceName { get; set; }
    public String subSourceName { get; set; }
    public Decimal subSourceTypeScore { get; set; }
    public String subSourceTypeName { get; set; }
    public FinancialSource() {
      this.sourceName = this.subSourceName = this.subSourceTypeName = '';
      this.subSourceTypeScore = 0.0;
    }
  }

  public class OtherData {
    public Map<String, String> values { get; set; }
    public OtherData() {
      this.values = new Map<String, String>();
    }
  }

  public class DeviceData {
    public String browserType { get; set; }
    public String browserVersion { get; set; }
    public String deviceOS { get; set; }
    public String deviceType { get; set; }
    public String iovationFirstSeen { get; set; }
    public String ipAddress { get; set; }

    public DeviceData() {
      this.browserType = this.browserVersion = this.deviceOS = this.deviceType = this.iovationFirstSeen = this.ipAddress = '';
    }
  }

  public class AdditionalInfo {
    public String rawResponse { get; set; }
    public String qualifileReport { get; set; }
    public String evaluationToken { get; set; }
    public String dateGenerated { get; set; }
    public String alloyRedirectLink { get; set; }

    public AdditionalInfo() {
      this.rawResponse = this.qualifileReport = this.evaluationToken = this.dateGenerated = this.alloyRedirectLink = '';
    }
  }
}
