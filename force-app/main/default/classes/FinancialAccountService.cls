/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Financial Account Service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class FinancialAccountService extends AbstractService {
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
   * @description  before save finanical account
   * @author Digital Align Team | 01-10-2022
   * @param List<FinServ__FinancialAccount__c> financialAccounts
   * @return List<FinServ__FinancialAccount__c>
   **/
  global virtual List<FinServ__FinancialAccount__c> beforeSaveFinancialAccounts(
    List<FinServ__FinancialAccount__c> financialAccounts
  ) {
    return financialAccounts;
  }

  /**
   * @description save financial account
   * rollback on failure
   * @author Digital Align Team | 01-10-2022
   * @param List<FinServ__FinancialAccount__c> financialAccounts
   * @param String applicationId
   * @return  List<FinServ__FinancialAccount__c>
   **/
  global virtual List<FinServ__FinancialAccount__c> saveFinancialAccounts(
    List<FinServ__FinancialAccount__c> financialAccounts,
    String applicationId
  ) {
    //before saving financialAccounts
    financialAccounts = this.beforeSaveFinancialAccounts(financialAccounts);
    //save point count against DML operation
    Savepoint sp = Database.setSavepoint();
    try {
      financialAccounts = ApplicationPersistService.getInstance()
        .saveFinancialAccounts(financialAccounts, applicationId);
    } catch (Exception ex) {
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
    //after saving financialAccounts and child records
    return this.afterSaveFinancialAccounts(financialAccounts);
  }

  /**
   * @description after save finanical accounts
   * @author Digital Align Team | 01-10-2022
   * @param List<FinServ__FinancialAccount__c> financialAccounts
   * @return List<FinServ__FinancialAccount__c>
   **/
  global virtual List<FinServ__FinancialAccount__c> afterSaveFinancialAccounts(
    List<FinServ__FinancialAccount__c> financialAccounts
  ) {
    return financialAccounts;
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
    //#removeFSC
    //financialAccount.FinServ__FinancialAccountType__c = membershipProduct.Category__c;
    //#removeFSC
    //financialAccount.FinServ__PrimaryOwner__c = primaryApplicant.Contact__r.AccountId;
    financialAccount.Ownership__c = 'Individual';
    financialAccount.Status__c = 'Open';
    financialAccount.Stage__c = 'Active';
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
