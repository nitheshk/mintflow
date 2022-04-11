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
      serviceInstance = (FinancialAccountService) getInstance(FinancialAccountService.class);
    }
    return serviceInstance;
  }

  /**
   * @description Read Financial Account with child record
   * @author Digital Align Team | 10-26-2021
   * @param List<FinancialAccount__c> financialAccounts
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> readFinancialAccountsWithChild(List<FinancialAccount__c> financialAccounts) {
    return readFinancialAccountsWithChild((new Map<Id, SObject>(financialAccounts)).keySet());
  }

  /**
   * @description  Read Financial Account with child record by ids
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> applicationIds
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> readFinancialAccountsWithChild(Set<Id> applicationIds) {
    return FinancialAccountRepository.readFinancialAccountsWithChild(applicationIds);
  }

  /**
   * @description  before save finanical account
   * @author Digital Align Team | 01-10-2022
   * @param List<FinancialAccount__c> financialAccounts
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> beforeSaveFinancialAccounts(List<FinancialAccount__c> financialAccounts) {
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
  global virtual List<FinancialAccount__c> afterSaveFinancialAccounts(List<FinancialAccount__c> financialAccounts) {
    return financialAccounts;
  }

  /**
   * @description
   * @author Digital Align Team | 03-09-2022
   * @param Application__c application
   * @return FinancialAccount__c
   **/
  global virtual FinancialAccount__c createInitialFinancialAccount(Application__c application) {
    FinancialProduct__c baseProduct, selectedProduct = FinancialAccountRepository.readBaseProduct();
    String pid = PageUtils.getCurrentPageParameters('pid');

    if (String.isNotBlank(pid)) {
      selectedProduct = FinancialAccountRepository.readFinancialProductByInternalCode(pid);
    }

    application.ApplicationType__c = selectedProduct.Type__c;
    // create financial account
    FinancialAccount__c financialAccount = new FinancialAccount__c();
    financialAccount.FinancialProduct__c = selectedProduct.Id;
    financialAccount.Ownership__c = 'Individual';
    financialAccount.IsPrimary__c = true;
    financialAccount.Status__c = ApplicationConstant.IN_PROGRESS;
    financialAccount.Stage__c = 'Active';
    financialAccount.Application__c = application.Id;
    financialAccount.RecordTypeId = SObjectUtils.recordTypeIdByName(
      FinancialAccount__c.SObjectType,
      selectedProduct.Category__c
    );
    FinancialAccountRepository.upsertRecord(financialAccount);
    FinancialAccountRepository.upsertRecord(application);
    log?.fine('financialAccount Created');
    return financialAccount;
  }

  /**
   *  Only For Testing Purpose
   *  Manual Approve Funding Data
   **/
  public static void testApproveFundingSubmission(String applicationNumber) {
    Application__c application = (new BuildSubmissionWrapper()).readApplicationWithChild(applicationNumber);
    String applicationJson =
      '{"FinancialAccounts":[{"FinancialAccountId":"' +
      application.FinancialAccounts__r[0].Id +
      '","AccountNumber":"34543","FinancialApplicationTransaction":{"TransactionStatus":"Paid","FinancialAccountTransactionId":"' +
      application.FinancialAccounts__r[0].FinancialAccountTransactions__r[0].Id +
      '"}}],"Applicants":[{"ApplicantId":"' +
      application.Applicants__r[0].Id +
      '","CustomerNumber":"456456"}],"ExternalApplicationNumber":"3434","ExternalApplicationStatus":"Approved","MemberNumber":" 229217 ","ApplicationId":"' +
      application.Id +
      '","IsExistingCustomer":false}';
    application = (Application__c) SubmitApplicationService.getInstance().updateSubmissionInfo(applicationJson);
  }
}
