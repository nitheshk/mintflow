/**
 * Copyright (c) 2021 Digital Align
 * @group Exception
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class SentiLinkReportController {
  // use in lwc component
  //@AuraEnabled(cacheable=true)
  /**
   * @description Cancel KYC, change kyc status to cancel
   * @param String submissionId
   * @param String status
   * @return Boolean
   */

  // Used in the report display

  private String contentDocumentId { get; set; }
  public SentiLinkReportWrapper wrapper { get; set; }
  public SentiLinkDTO.Response response { get; set; }

  public Boolean showResult { get; set; }

  public SentiLinkReportController() {
    wrapper = new SentiLinkReportWrapper();
    response = new SentiLinkDTO.Response();
    showResult = false;
  }

  /**
   * @description
   * @return SentiLinkReportWrapper
   **/
  public void prefillFraudCheckDetail() {
    try {
      string entityId = '00Q1y000001j4f5EAA';
      list<ContentVersion> cv = FileService.getInstance()
        .fetchContentVersionByEntityId(entityId, false);
      String res = (cv[0].VersionData).toString();
      response = (SentiLinkDTO.Response) JSON.deserialize(
        res,
        SentiLinkDTO.Response.class
      );
      wrapper.GeneralInfo.rawResponse = res;
      wrapper.GeneralInfo.applicationId = response.application_id;
      wrapper.GeneralInfo.timestamp = response.timestamp;
      wrapper.GeneralInfo.transactionId = response.transaction_id;

      showScores(wrapper, response);
      showCustomerHistroy(wrapper, response);
      showResult = true;
    } catch (Exception ex) {
    } finally {
    }
  }

  private SentiLinkReportWrapper showCustomerHistroy(
    SentiLinkReportWrapper wrapper,
    SentiLinkDTO.Response response
  ) {
    wrapper.attributes.ssn_shared_count = response.extra_data.consumer_history.data.attributes.ssn_shared_count;
    wrapper.attributes.name_dob_shared_count = response.extra_data.consumer_history.data.attributes.name_dob_shared_count;
    wrapper.attributes.name_ssn_synthetic_address = response.extra_data.consumer_history.data.attributes.name_ssn_synthetic_address;
    wrapper.attributes.ssn_bogus = response.extra_data.consumer_history.data.attributes.ssn_bogus;
    wrapper.attributes.ssn_history_longer_months = response.extra_data.consumer_history.data.attributes.ssn_history_longer_months;
    wrapper.attributes.ssn_issuance_dob_mismatch = response.extra_data.consumer_history.data.attributes.ssn_issuance_dob_mismatch;
    wrapper.attributes.ssn_issued_before_dob = response.extra_data.consumer_history.data.attributes.ssn_issued_before_dob;
    return wrapper;
  }
  //-----------------------------------------------
  private SentiLinkReportWrapper showScores(
    SentiLinkReportWrapper wrapper,
    SentiLinkDTO.Response response
  ) {
    for (SentiLinkDTO.ResScores scoreInfoItem : response.scores) {
      SentiLinkReportWrapper.ScoresInfo scoreInfo = new SentiLinkReportWrapper.ScoresInfo();
      scoreInfo.name = toTitleCase(scoreInfoItem.name);
      scoreInfo.score = scoreInfoItem.score;
      scoreInfo.version = scoreInfoItem.version;
      for (
        SentiLinkDTO.ReasonCodes reasonCodeItem : scoreInfoItem.reason_codes
      ) {
        SentiLinkReportWrapper.ReasonCodes reasonCode = new SentiLinkReportWrapper.ReasonCodes();
        reasonCode.code = reasonCodeItem.code;
        reasonCode.direction = toTitleCase(reasonCodeItem.direction);
        reasonCode.explanation = reasonCodeItem.explanation;
        reasonCode.rank = reasonCodeItem.rank;
        scoreInfo.reasonCodes.add(reasonCode);
      }
      wrapper.scores.add(scoreInfo);
    }
    system.debug('wrapper.scores =' + wrapper.scores);
    return wrapper;
  }
  public String toTitleCase(String phrase) {
    String titlePhrase = '';
    Set<String> forceLower = new Set<String>{
      'of',
      'the',
      'for',
      'and',
      'a',
      'to',
      'at',
      'an',
      'but',
      'if',
      'or',
      'nor'
    };

    if (phrase != null && phrase.length() > 0) {
      phrase = phrase.replace('_', ' ');
      String[] splitPhrase = phrase.trim().split(' ');

      for (integer i = 0; i < splitPhrase.size(); i++) {
        if (
          !forceLower.contains(splitPhrase[i].toLowerCase()) ||
          i == 0 ||
          i == (splitPhrase.size() - 1)
        ) {
          titlePhrase +=
            (splitPhrase[i].substring(0, 1).toUpperCase()) +
            (splitPhrase[i].substring(1).toLowerCase()) +
            ' ';
        } else {
          titlePhrase += splitPhrase[i].toLowerCase() + ' ';
        }
      }
    }
    return titlePhrase.trim();
  }
}
