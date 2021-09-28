/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Financial Institute Site Service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class FinancialInstituteSiteService extends AbstractService {
  @TestVisible
  private static FinancialInstituteSiteService serviceInstance;

  public FinancialInstituteSiteService() {
    super(FinancialInstituteSiteService.class);
  }

  /**
   * @description Provides a singleton instance of FinancialInstituteSiteService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static FinancialInstituteSiteService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (FinancialInstituteSiteService) getInstance(
        FinancialInstituteSiteService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description fetch survey template for FinInst
   * @author Digital Align Team | 07-22-2021
   * @return List<Survey__c>
   **/
  global virtual List<Survey__c> fetchSurveyTemplates(
    Map<String, Object> params
  ) {
    String templateName = (String) params.get('templateName');
    return SurveyResolver.getInstance().fetchSurveyByTemplateName(templateName);
  }

  /**
   * @description approve the lead and create a business account
   * @author Digital Align Team | 08-26-2021
   * @param Map<String Object> params
   * @return Lead
   **/
  global virtual Lead approveLead(Map<String, Object> params) {
    Lead leadRecord = (Lead) JSON.deserialize(
      JSON.serialize(params.get('leadRecord')),
      Lead.class
    );

    FinancialInstituteSiteRepository.upsertRecord(leadRecord);

    if (!CollectionUtils.isListEmpty(leadRecord.Surveys__r)) {
      for (Survey__c surveyObj : leadRecord.Surveys__r) {
        surveyObj.Lead__c = leadRecord.Id;
      }
      FinancialInstituteSiteRepository.upsertRecords(leadRecord.Surveys__r);
    }

    ApexResponse response = UserAccountManagementController.createDealerBusinessAccount(
      new Map<String, Object>{ 'leadId' => leadRecord.Id }
    );

    if (response.status == 200) {
      return DealerSiteRepository.fetchLeadAndSurveyByLeadId(leadRecord.Id);
    } else {
      throw new customException(
        'Unable to open account, Please contact system admin'
      );
    }
  }

  /**
   * @description Lead is rejected by financial institute employee
   * @author Digital Align | 08-09-2021
   * @param Map<String Object> params
   * @return Lead
   **/
  global virtual Lead rejectLead(Map<String, Object> params) {
    Lead leadRecord = (Lead) JSON.deserialize(
      JSON.serialize(params.get('leadRecord')),
      Lead.class
    );

    leadRecord.Status = FinancialInstituteConstants.LEAD_REJECTED_STATUS;
    FinancialInstituteSiteRepository.upsertRecord(leadRecord);

    if (!CollectionUtils.isListEmpty(leadRecord.Surveys__r)) {
      for (Survey__c surveyObj : leadRecord.Surveys__r) {
        surveyObj.Lead__c = leadRecord.Id;
      }
      FinancialInstituteSiteRepository.upsertRecords(leadRecord.Surveys__r);
    }
    DealerEmailService.getInstance().sendLeadRejectionEmail(leadRecord);
    return DealerSiteRepository.fetchLeadAndSurveyByLeadId(leadRecord.Id);
  }

  /**
   * @description
   * @author Digital Align Team | 08-26-2021
   * @param Map<String Object> params
   * @return Lead
   **/
  global virtual Lead resetDealerInviteLink(Map<String, Object> params) {
    Id leadId = (Id) params.get('leadId');
    Lead leadRecord = UserAccountManagementRepository.fetchLeadById(leadId);
    leadRecord.LinkExpireTime__c = Datetime.now().addHours(24);
    FinancialInstituteSiteRepository.upsertRecord(leadRecord);
    DealerEmailService.getInstance().sendDealerRegisterInvitation(leadRecord);
    return DealerSiteRepository.fetchLeadAndSurveyByLeadId(leadRecord.Id);
  }
}
