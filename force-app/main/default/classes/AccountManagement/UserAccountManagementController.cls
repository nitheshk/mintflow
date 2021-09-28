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
   * @description Create Dealer Business Account
   * @author Digital Align Team | 07-15-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse createDealerBusinessAccount(
    Map<String, Object> params
  ) {
    try {
      return ApexResponse.ok(
        DealerAccountCreationService.getInstance()
          .createDealerBusinessUserAccount(params)
      );
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description Create Dealer Employee Business Account
   * @author Digital Align Team | 07-15-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse createDealerEmployeeAccount(
    Map<String, Object> params
  ) {
    try {
      return ApexResponse.ok(
        DealerAccountCreationService.getInstance()
          .createDealerEmployeeUserAccount(params)
      );
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description Create financial institue employee Account
   * @author Digital Align Team | 07-27-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse createFinInstEmployeeAccount(
    Map<String, Object> params
  ) {
    try {
      return ApexResponse.ok(
        FinInstAccountService.getInstance()
          .createFinInstEmployeeUserAccount(params)
      );
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
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
      Account finInstAcc = FinInstAccountService.getInstance()
        .fetchFinancialInstituteAccount();
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
  global static ApexResponse createFinancialInstituteAccount(
    Map<String, Object> params
  ) {
    try {
      return ApexResponse.ok(
        FinInstAccountService.getInstance()
          .createFinancialInstituteAccount(params)
      );
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
    }
  }

  /**
   * @description
   * @author Digital Align | 08-24-2021
   * @param string recordId
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse fetchDealerEmployeeActiveStatus(string recordId) {
    try {
      return ApexResponse.ok(
        DealerAccountCreationService.getInstance()
          .fetchDealerEmployeeActiveStatus(recordId)
      );
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
    }
  }
  /**
   * @description Update Isactive flag of user object
   * @author Digital Align | 08-24-2021
   * @param Map<String Object> params
   * @return ApexResponse
   **/
  @AuraEnabled
  global static ApexResponse updateDealerEmployeeActiveStatus(
    Map<String, Object> params
  ) {
    try {
      return ApexResponse.ok(
        DealerAccountCreationService.getInstance()
          .updateDealerEmployeeActiveStatus(params)
      );
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
    }
  }
  /**
   * @description
   * @author Digital Align | 09-01-2021
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  global static ApexResponse fetchLoggedinUserContactDetails() {
    try {
      return ApexResponse.ok(
        DealerAccountCreationService.getInstance()
          .fetchLoggedinUserContactDetails()
      );
    } catch (Exception ex) {
      System.debug(ex.getMessage());
      return ApexResponse.exception(ex);
    }
  }
}
