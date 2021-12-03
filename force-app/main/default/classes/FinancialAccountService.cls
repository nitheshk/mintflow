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
  global virtual Object createMemberAccount(Map<String, Object> params) {
    String applicantId = (string) params.get('applicationId');

    Account application = FinancialAccountRepository.readApplicationWithChild(
      applicantId
    );

    // Primary Kyc is Approved and Joint KYC is Approved
    // Primary is Not Existing Customer
    // update Applicant detail accordingly
    application = updateApplicationKycDetails(application, params);

    // if Application kyc status is approved, then procced with creating Account & Contact for primary
    // And Open Membership Financial Account and relation with applicant
    createMembershipAccount();

    return null;
  }

  /**
   * @description
   * Primary Kyc is Approved and Joint KYC is Approved
   * Primary is Not Existing Customer
   * update Applicant detail accordingly
   * @author Digital Align Team | 12-02-2021
   * @param Account application
   * @param Map<String String> params
   * @return virtual
   **/
  global virtual Account updateApplicationKycDetails(
    Account application,
    Map<String, Object> params
  ) {
    for (Applicant__c applicant : application.Applicants__r) {
    }

    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 12-02-2021
   * @return virtual
   **/
  global virtual object createMembershipAccount() {
    return null;
  }
}
