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
   * @description Create financial membership account record
   * @author Digital Align Team | 12-13-2021
   * @param Account application
   * @return Account
   */
  global Account createMembershipFinancialAccount(Account application) {
    Applicant__c primaryApplicant;

    for (Applicant__c applicant : application.Applicants__r) {
      if (
        applicant.RecordType.Name ==
        ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
      ) {
        primaryApplicant = applicant;
      }
    }

    //check already Application has Account Contact relation with primary
    AccountContactRelation accountContactRel = FinancialAccountRepository.fetchAccountContactRelation(
      application.Id,
      primaryApplicant.Contact__c
    );

    if (accountContactRel == null) {
      //check has primary group account contact relation is already created ? if not mark as primary group
      AccountContactRelation hasPrimaryGroupRelation = FinancialAccountRepository.fetchPrimaryAccountContactRelation(
        primaryApplicant.Contact__c
      );

      // purpose to link application and primary contact to view in household view
      accountContactRel = new AccountContactRelation(
        AccountId = application.Id,
        ContactId = primaryApplicant.Contact__c,
        IsActive = true,
        FinServ__Primary__c = true,
        FinServ__PrimaryGroup__c = hasPrimaryGroupRelation == null
          ? true
          : false,
        StartDate = Date.today(),
        EndDate = Date.today().addYears(100),
        Roles = 'Business User',
        FinServ__Rollups__c = 'All'
      );
      FinancialAccountRepository.upsertRecord(accountContactRel);
    }
    //fetching membership product
    FinancialProduct__c membershipProduct = FinancialAccountRepository.readFinancialProductByInternalCode(
      HttpBuilder.getApiConstant('MembershipAccountInternalCode')
    );

    // create membership financial account
    FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
    financialAccount.FinancialProduct__c = membershipProduct.Id;
    financialAccount.Name = membershipProduct.Name;
    financialAccount.ExternalApplicationNumber__c = application.ExternalApplicationNumber__c;
    financialAccount.FinServ__FinancialAccountType__c = membershipProduct.Category__c;
    financialAccount.FinServ__PrimaryOwner__c = primaryApplicant.Contact__r.AccountId;
    financialAccount.FinServ__Ownership__c = 'Individual';
    financialAccount.FinServ__Status__c = 'Open';
    financialAccount.FinServ__Stage__c = 'Active';
    financialAccount.FinServ__Household__c = application.Id;
    financialAccount.Application__c = application.Id;
    financialAccount.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
      FinServ__FinancialAccount__c.SObjectType,
      'SavingsAccount'
    );
    FinancialAccountRepository.upsertRecord(financialAccount);
    log?.fine('financialAccount Created');
    return application;
  }
}
