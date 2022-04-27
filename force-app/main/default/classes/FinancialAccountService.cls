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
   * @description read financial Accounts with child and product with child
   * @author Digital Align Team | 04-11-2022
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> readFinancialAccounts() {
    Id applicationId = ApexRequest.getApplicationId();

    List<FinancialAccount__c> financialAccounts = FinancialAccountRepository.readFinancialAccountsByAppID(
      applicationId
    );
    Map<Id, financialProduct__c> productsMap = new Map<Id, financialProduct__c>(
      FinancialAccountRepository.fetchProductWithChildConfig(applicationId)
    );

    for (FinancialAccount__c financialAccount : financialAccounts) {
      financialAccount.FinancialProduct__r = productsMap.get(financialAccount.FinancialProduct__c);
    }
    return financialAccounts;
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
   * @param Set<Id> financialAccountIds
   * @return List<FinancialAccount__c>
   **/
  global virtual List<FinancialAccount__c> readFinancialAccountsWithChild(Set<Id> financialAccountIds) {
    return FinancialAccountRepository.readFinancialAccountsWithChild(financialAccountIds);
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

  /**
   * @description Generate Url to upload identity Document Via mobile device
   * @author Digital Align Team | 02-08-2022
   * @param Id applicantId
   * @return Object
   **/
  global virtual Object generateUrlForFunding(Id applicantId) {
    Applicant__c currentApplicant = IdentityRepository.readApplicantWithApplication(applicantId);

    // Send SMS
    String link = CustomerEmailService.getInstance()
      .generateUrl(
        new Map<String, String>{
          'aplType' => ApexRequest.getApplicantType(),
          'flw' => ApplicationConstant.FLOW_TYPE_PAYMENT,
          'urlSuffix' => '/savings/main-app/funding',
          'aplId' => currentApplicant.Id,
          'ch' => 'Virtual',
          'pageName' => '/CustomerAction',
          'suffixType' => 'path'
        }
      );
    Map<String, Object> params = new Map<String, Object>();
    String messageBody = System.Label.Funding_SmsBodyForFundingLink.replace('{url}', link)
      .replace('{applicationNumber}', currentApplicant.Application__r.Name);
    params.put('messageText', messageBody);
    String toPhone = String.isBlank(HttpBuilder.getApiConstant('TwillioToPhoneNumber'))
      ? currentApplicant.Phone__c
      : HttpBuilder.getApiConstant('TwillioToPhoneNumber');
    params.put('toPhone', HttpBuilder.getApiConstant('Twillio_Country') + toPhone);
    params.put('applicantId', currentApplicant.Id);
    NotificationService.getInstance().sendOTPMessage(params);

    // Send Email
    CustomerEmailService.getInstance().notifyToUpdateFunding(currentApplicant, link);
    return true;
  }
}
