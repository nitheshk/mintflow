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
