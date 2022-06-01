/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class LWCFinancialInstituteSiteController {
  private static logger log = logger.getInstance(ApplicantController.class);

  /**
   * @description Create financial institue employee Account
   * @author Digital Align Team | 07-27-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse createFinInstEmployeeAccount(Map<String, Object> params) {
    try {
      return ApexResponse.ok(FinancialInstituteSiteService.getInstance().createEmployeeUserAccount(params));
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
    } finally {
      Logger.persist();
    }
  }

  /**
   * @description fetch financial institute account record
   * @author Digital Align | 07-23-2021
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchFinancialInstituteAccount() {
    try {
      Account finInstAcc = FinancialInstituteSiteService.getInstance().fetchFinancialInstituteAccount();
      if (finInstAcc != null) {
        return ApexResponse.ok(finInstAcc);
      } else {
        return ApexResponse.fail(finInstAcc);
      }
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description
   * @author Digital Align Team | 07-27-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse createFinancialInstituteAccount(Map<String, Object> params) {
    try {
      return ApexResponse.ok(FinancialInstituteSiteService.getInstance().createFinancialInstituteAccount(params));
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description Get employee contact records based on filters
   * @author Digital Align | 09-21-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  public static ApexResponse retrieveEmployees(Map<String, Object> params) {
    try {
      return ApexResponse.ok(SearchService.getInstance().retrieveEmployees(params));
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description To get applicant records based on the filters
   * @author Digital Align | 09-21-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  public static ApexResponse retrieveApplicants(Map<String, Object> params) {
    try {
      log?.debug('retrieve Member ::' + params);
      return ApexResponse.ok(SearchService.getInstance().retrieveApplicants(params));
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } finally {
      Logger.persist();
    }
  }

  /**
   * @description To get application records based on the filters
   * @author Digital Align | 09-21-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  public static ApexResponse retrieveApplications(Map<String, Object> params) {
    try {
      log?.debug('retrieve Applications ::' + params);
      return ApexResponse.ok(SearchService.getInstance().retrieveApplications(params));
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    } finally {
      Logger.persist();
    }
  }
  /**
   * @description
   * @author Digital Align | 09-29-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchPickListValues(Map<String, Object> params) {
    try {
      return ApexResponse.ok(LwcCustomService.getInstance().fetchPickListValues(params));
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
    }
  }
}
