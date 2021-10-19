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
      showResult = true;
    } catch (Exception ex) {
    } finally {
    }
  }
  //-----------------------------------------------
  private SentiLinkReportWrapper showScores(
    SentiLinkReportWrapper wrapper,
    SentiLinkDTO.Response response
  ) {
    system.debug('Scores ===' + response.scores);
    system.debug('Scores ===' + response.scores[0].name);
    for (SentiLinkDTO.ResScores scoreInfoItem : response.scores) {
      SentiLinkReportWrapper.ScoresInfo scoreInfo = new SentiLinkReportWrapper.ScoresInfo();
      scoreInfo.name = scoreInfoItem.name;
      scoreInfo.score = scoreInfoItem.score;
      scoreInfo.version = scoreInfoItem.version;
      for (
        SentiLinkDTO.ReasonCodes reasonCodeItem : scoreInfoItem.reason_codes
      ) {
        SentiLinkReportWrapper.ReasonCodes reasonCode = new SentiLinkReportWrapper.ReasonCodes();
        reasonCode.code = reasonCodeItem.code;
        reasonCode.direction = reasonCodeItem.direction;
        reasonCode.explanation = reasonCodeItem.explanation;
        reasonCode.rank = reasonCodeItem.rank;
        scoreInfo.reasonCodes.add(reasonCode);
      }
      wrapper.scores.add(scoreInfo);
    }
    system.debug('wrapper.scores =' + wrapper.scores);
    return wrapper;
  }
}
