/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class LWCFinancialInstituteSiteController {
  /**
   * @description
   * @author Digital Align Team | 07-27-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse createFinInstEmployeeAccount(
    Map<String, Object> params
  ) {
    return UserAccountManagementController.createFinInstEmployeeAccount(params);
  }

  /**
   * @description
   * @author Digital Align Team | 07-27-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse createFinancialInstituteAccount(
    Map<String, Object> params
  ) {
    return UserAccountManagementController.createFinancialInstituteAccount(
      params
    );
  }

  /**
   * @description
   * @author Digital Align | 07-23-2021
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchFinancialInstituteAccount() {
    return UserAccountManagementController.fetchFinancialInstituteAccount();
  }

  /**
   * @description
   * @author Digital Align Team | 08-26-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse fetchSurveyTemplates(Map<String, Object> params) {
    try {
      return ApexResponse.ok(
        FinancialInstituteSiteService.getInstance().fetchSurveyTemplates(params)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description Lead is approved by financial institute employee and
   * lead is converted into account,contact and user
   * @author Digital Align Team | 08-27-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse approveLead(Map<String, Object> params) {
    system.debug('params : ' + JSON.serialize(params));
    try {
      return ApexResponse.ok(
        FinancialInstituteSiteService.getInstance().approveLead(params)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description Lead is rejected by financial institute employee
   * @author Digital Align | 08-09-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse rejectLead(Map<String, Object> params) {
    try {
      return ApexResponse.ok(
        FinancialInstituteSiteService.getInstance().rejectLead(params)
      );
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description reset invite link
   * @author Digital Align Team | 08-26-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse resetDealerInviteLink(Map<String, Object> params) {
    try {
      return ApexResponse.ok(
        FinancialInstituteSiteService.getInstance()
          .resetDealerInviteLink(params)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description Get Contacts records based on filters
   * @author Digital Align | 09-16-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled(Cacheable=true)
  public static ApexResponse retriveContacts(Map<String, Object> params) {
    try {
      return ApexResponse.ok(
        SearchService.getInstance().retriveContacts(params)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description Get employee contact records based on filters
   * @author Digital Align | 09-21-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled(Cacheable=true)
  public static ApexResponse retriveEmployees(Map<String, Object> params) {
    try {
      return ApexResponse.ok(
        SearchService.getInstance().retriveEmployees(params)
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }
}
