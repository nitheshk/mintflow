/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Financial Account Service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FinancialAccountService extends AbstractService {
  @TestVisible
  private static FinancialAccountService serviceInstance;
  private FinancialAccountServiceHelper helper = FinancialAccountServiceHelper.getInstance();

  public FinancialAccountService() {
    super(FinancialAccountService.class);
  }

  /**
   * @description Provides a singleton instance of FinancialAccountService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static FinancialAccountService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (FinancialAccountService) getInstance(
        FinancialAccountService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description Read Financial Account with child record
   * @author Digital Align Team | 10-26-2021
   * @param List<FinServ__FinancialAccount__c> financialAccounts
   * @return List<FinServ__FinancialAccount__c>
   **/
  global virtual List<FinServ__FinancialAccount__c> readFinancialAccountsWithChild(
    List<FinServ__FinancialAccount__c> financialAccounts
  ) {
    return readFinancialAccountsWithChild(
      (new Map<Id, SObject>(financialAccounts)).keySet()
    );
  }

  /**
   * @description  Read Financial Account with child record by ids
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> applicationIds
   * @return List<FinServ__FinancialAccount__c>
   **/
  global virtual List<FinServ__FinancialAccount__c> readFinancialAccountsWithChild(
    Set<Id> applicationIds
  ) {
    return FinancialAccountRepository.readFinancialAccountsWithChild(
      applicationIds
    );
  }

  /**
   * @description Create Financial MemberShip account and Primary Account
   * @author Digital Align Team | 12-02-2021
   * @param Map<String Object> params
   * @return Object
   **/
  global virtual Account createMemberAccount(String resultJson) {
    ApplicationResponseMapper.KYCResult kycResult = (ApplicationResponseMapper.KYCResult) JSON.deserialize(
      resultJson,
      ApplicationResponseMapper.KYCResult.class
    );

    // When result is null
    if (kycResult == null) {
      throw new CustomException('Unable to process the empty request');
    }

    Account application = FinancialAccountRepository.readApplicationWithChild(
      kycResult.ApplicationId
    );

    Savepoint sp = Database.setSavepoint();
    try {
      // Primary is Existing Customer
      if (kycResult.IsExistingCustomer == true) {
        return helper.processExistingMember(application, kycResult);
      }

      // Primary Kyc is Approved/Failed and Joint KYC is Approved/Failed
      // update Applicant detail accordingly
      application = helper.updateApplicationKycDetails(application, kycResult);

      // if Application kyc status is approved, then proceed with creating Account & Contact for primary
      // And Open Membership Financial Account and relation with applicant
      if (application.FinServ__Status__c == ApplicationConstant.APPROVED) {
        helper.createMembershipAccount(application);
      } else {
        return application;
      }

      application = helper.createMembershipFinancialAccount(application);
      return application;
    } catch (Exception ex) {
      //#pending
      //#major Chatter We need post the resultKYC in case of exception
      //#minor Add into Revision Queue for process
      //Stage value = Exception
      log?.error(ex);

      Database.rollback(sp);
      throw ex;
    }
  }
}
