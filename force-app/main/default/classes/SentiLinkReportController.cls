/**
 * Copyright (c) 2020 Terafina Inc
 * @group   Controller
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
  public SentiLinkReportDTO wrapper { get; set; }
  public Boolean showResult { get; set; }

  public SentiLinkReportController() {
    wrapper = new SentiLinkReportDTO();
    showResult = false;
  }

  /**
   * @description
   * @return SentiLinkReportDTO
   **/
  public void prefillFraudCheckDetail() {
    try {
      list<ContentVersion> cv = FileService.getInstance()
        .fetchContentVersionByEntityId('00Q1y000001j4f5EAA', false);
      String res = (cv[0].VersionData).toString();
      Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(
        res
      );
      system.debug('response =' + response);
      wrapper.GeneralInfo.rawResponse = res;
      wrapper.GeneralInfo.applicationId = (string) response.get(
        'application_id'
      );
      wrapper.GeneralInfo.timestamp = (string) response.get('timestamp') !=
        null && String.isNotBlank(String.valueOf(response.get('timestamp')))
        ? (Datetime.newInstance((Long) response.get('timestamp')))
            .format('MM/dd/yyyy hh:mm:ss a', UserInfo.getTimeZone().getID())
        : '';
      wrapper.GeneralInfo.transactionId = (string) response.get(
        'transaction_id'
      );

      wrapper = prefillScores(wrapper, response);
      showResult = true;
    } catch (Exception ex) {
    } finally {
    }
  }
  //-----------------------------------------------
  private SentiLinkReportDTO prefillScores(
    SentiLinkReportDTO wrapper,
    Map<String, Object> response
  ) {
    system.debug('response.get(scores) ===' + response.get('scores'));
    if (response.get('scores') != null) {
      Map<String, Object> scoresObj = (Map<String, Object>) response.get(
        'scores'
      );
      system.debug('scoresObj ===' + scoresObj);
    }
    return wrapper;
  }
}
