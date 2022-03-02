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
   * @param List<FinancialAccount__c> financialAccounts
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> readFinancialAccountsWithChild(
    List<FinancialAccount__c> financialAccounts
  ) {
    return readFinancialAccountsWithChild(
      (new Map<Id, SObject>(financialAccounts)).keySet()
    );
  }

  /**
   * @description  Read Financial Account with child record by ids
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> applicationIds
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> readFinancialAccountsWithChild(
    Set<Id> applicationIds
  ) {
    return FinancialAccountRepository.readFinancialAccountsWithChild(
      applicationIds
    );
  }

  /**
   * @description  before save finanical account
   * @author Digital Align Team | 01-10-2022
   * @param List<FinancialAccount__c> financialAccounts
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> beforeSaveFinancialAccounts(
    List<FinancialAccount__c> financialAccounts
  ) {
    return financialAccounts;
  }

  /**
   * @description save financial account
   * rollback on failure
   * @author Digital Align Team | 01-10-2022
   * @param List<FinancialAccount__c> financialAccounts
   * @param String applicationId
   * @return  List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> saveFinancialAccounts(
    List<FinancialAccount__c> financialAccounts,
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
   * @param List<FinancialAccount__c> financialAccounts
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> afterSaveFinancialAccounts(
    List<FinancialAccount__c> financialAccounts
  ) {
    return financialAccounts;
  }

  /**
   * @description Create financial membership account record
   * @author Digital Align Team | 12-13-2021
   * @param Application__c application
   * @return Application__c
   */
  global Application__c createMembershipFinancialAccount(
    Application__c application
  ) {
    Applicant__c primaryApplicant;

    for (Applicant__c applicant : application.Applicants__r) {
      if (
        applicant.RecordType.Name ==
        ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
      ) {
        primaryApplicant = applicant;
      }
    }

    //fetching membership product
    FinancialProduct__c membershipProduct = FinancialAccountRepository.readFinancialProductByInternalCode(
      HttpBuilder.getApiConstant('MembershipAccountInternalCode')
    );

    // create membership financial account
    FinancialAccount__c financialAccount = new FinancialAccount__c();
    financialAccount.FinancialProduct__c = membershipProduct.Id;
    //removeFSC
    //financialAccount.Name = membershipProduct.Name;
    financialAccount.ExternalApplicationNumber__c = application.ExternalApplicationNumber__c;
    //#removeFSC
    //financialAccount.FinServ__FinancialAccountType__c = membershipProduct.Category__c;
    financialAccount.Ownership__c = 'Individual';
    financialAccount.Status__c = 'Open';
    financialAccount.Stage__c = 'Active';
    financialAccount.Application__c = application.Id;
    financialAccount.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
      FinancialAccount__c.SObjectType,
      'SavingsAccount'
    );
    FinancialAccountRepository.upsertRecord(financialAccount);
    log?.fine('financialAccount Created');
    return application;
  }
}
