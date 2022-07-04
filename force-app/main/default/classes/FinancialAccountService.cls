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
  global virtual List<FinancialAccount__c> createInitialFinancialAccount(Application__c application) {
    FinancialProduct__c baseProduct = FinancialAccountRepository.readBaseProduct();
    String pid = PageUtils.getCurrentPageParameters('pid');
    List<FinancialProduct__c> selectedProduct;
    List<FinancialAccount__c> finAccountsList = new List<FinancialAccount__c>();

    List<String> productCodes = pid.split(',');
    if (String.isNotBlank(pid)) {
      selectedProduct = FinancialAccountRepository.readFinancialProductsByMultipleCodes(productCodes);
    }
    Integer prdIndex = 0;
    if (selectedProduct != null && selectedProduct.size() > 0) {
      application.ApplicationType__c = selectedProduct[0].Type__c; // to set first item type to the application
      for (FinancialProduct__c productItem : selectedProduct) {
        FinancialAccount__c financialAccount = new FinancialAccount__c();
        financialAccount.FinancialProduct__c = productItem.Id;
        financialAccount.Ownership__c = 'Individual';
        if (prdIndex == 0) {
          financialAccount.IsPrimary__c = true;
        }
        financialAccount.Status__c = ApplicationConstant.IN_PROGRESS;
        financialAccount.Stage__c = 'Active';
        financialAccount.Application__c = application.Id;
        financialAccount.RecordTypeId = SObjectUtils.recordTypeIdByName(
          FinancialAccount__c.SObjectType,
          productItem.Category__c
        );
        finAccountsList.add(financialAccount);
        prdIndex++;
      }
    }

    FinancialAccountRepository.upsertRecords(finAccountsList);
    FinancialAccountRepository.upsertRecord(application);
    log?.fine('financialAccount Created');
    return finAccountsList;
  }

  /**
   *  Only For Testing Purpose
   *  Manual Approve Funding Data
   **/
  public void testApproveFundingSubmission(String applicationNumber) {
    Application__c application = (new BuildSubmissionWrapper()).readApplicationWithChild(applicationNumber);

    Map<String, Object> resultMap = new Map<String, Object>();
    resultMap.put('ExternalApplicationNumber', String.valueOf(Integer.valueof((Math.random() * 100000))));
    resultMap.put('ExternalApplicationStatus', 'Approved');
    resultMap.put('MemberNumber', String.valueOf(Integer.valueof((Math.random() * 10000000))));
    resultMap.put('ApplicationId', application.Id);
    resultMap.put('IsExistingCustomer', false);

    List<Object> applicants = new List<Object>();
    for (Applicant__c applicant : application.Applicants__r) {
      if (
        applicant.RecordType.Name != ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE &&
        applicant.RecordType.Name != ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
      ) {
        continue;
      }
      applicants.add(
        new Map<String, Object>{
          'ApplicantId' => applicant.Id,
          'CustomerNumber' => String.valueOf(Integer.valueof((Math.random() * 10000000)))
        }
      );
    }
    resultMap.put('Applicants', applicants);

    List<Object> financialAccounts = new List<Object>();
    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      if (financialAccount.FinancialAccountTransactions__r.isEmpty()) {
        financialAccounts.add(
          new Map<String, Object>{
            'FinancialAccountId' => financialAccount.Id,
            'AccountNumber' => String.valueOf(Integer.valueof((Math.random() * 1000000000)))
          }
        );
      } else {
        financialAccounts.add(
          new Map<String, Object>{
            'FinancialAccountId' => financialAccount.Id,
            'AccountNumber' => String.valueOf(Integer.valueof((Math.random() * 1000000000))),
            'FinancialApplicationTransaction' => new Map<String, Object>{
              'FinancialAccountTransactionId' => financialAccount.FinancialAccountTransactions__r[0].Id,
              'TransactionStatus' => 'Paid'
            }
          }
        );
      }
    }
    resultMap.put('FinancialAccounts', financialAccounts);

    log?.debug('resultMap : ' + Json.serialize(resultMap));

    application = (Application__c) SubmitApplicationService.getInstance()
      .updateSubmissionInfo(Json.serialize(resultMap));
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
