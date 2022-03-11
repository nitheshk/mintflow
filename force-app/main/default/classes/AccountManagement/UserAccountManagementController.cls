/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description User Controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class UserAccountManagementController {
  /**
   * @description Create financial institue employee Account
   * @author Digital Align Team | 07-27-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse createFinInstEmployeeAccount(Map<String, Object> params) {
    try {
      return ApexResponse.ok(FinInstAccountService.getInstance().createFinInstEmployeeUserAccount(params));
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
      Account finInstAcc = FinInstAccountService.getInstance().fetchFinancialInstituteAccount();
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
      return ApexResponse.ok(FinInstAccountService.getInstance().createFinancialInstituteAccount(params));
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
    }
  }
}
