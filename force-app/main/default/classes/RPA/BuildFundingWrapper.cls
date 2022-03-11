/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class BuildFundingWrapper extends AbstractService {
  @TestVisible
  private static BuildFundingWrapper serviceInstance;

  public BuildFundingWrapper() {
    super(BuildFundingWrapper.class);
  }
  /**
   * @description Provides a singleton instance of BuildFundingWrapper from which all other class methods can be accessed.
   * @author Digital Align Team | 01/17/2022
   * @return Object  singleton
   **/
  public static BuildFundingWrapper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (BuildFundingWrapper) getInstance(BuildFundingWrapper.class);
    }
    return serviceInstance;
  }

  /**
   * @description Read application by application number
   * @author Digital Align Team | 10-21-2021
   * @param Map<String Object> params
   * @return Application__c
   **/
  global virtual Application__c readApplicationWithChild(String applicationNumber) {
    Application__c application;
    if (String.isBlank(applicationNumber)) {
      throw new CustomException(System.Label.Application_ApplicationNameCannotBeBlank);
    }
    application = SubmissionRepository.readApplicationByApplicationNumber(applicationNumber);
    if (application == null) {
      throw new customException(System.Label.Application_ApplicationNotFound);
    }

    List<Applicant__c> applicants = SubmissionRepository.readApplicantsWithChild(
      new Map<Id, SObject>(application.Applicants__r).keySet()
    );
    List<FinancialAccount__c> financialAccounts = SubmissionRepository.readFinancialAccountsWithChild(
      new Map<Id, SObject>(application.mflow__FinancialAccounts__r).keySet()
    );
    //Combine result into single application object
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObjects('mflow__Applicants__r', applicants);
    builder.setChildObjects('mflow__FinancialAccounts__r', financialAccounts);
    return (Application__c) builder.build();
  }

  /**
   * @description
   * @author Digital Align | 01-20-2022
   * @param string applicationNumber
   * @return FundingSubmissionResponse
   **/
  global virtual FundingSubmissionResponse obtainFundingData(string applicationNumber) {
    log?.fine('Inside obtainFundingData -> applicationNumber -> ' + applicationNumber);

    Application__c application = readApplicationWithChild(applicationNumber);
    FundingSubmissionResponse mapper = new FundingSubmissionResponse();
    mapper.Application = application.Id;
    mapper.Stage = application.mflow__Stage__c;
    mapper.Status = application.Status__c;

    for (Applicant__c applicant : application.Applicants__r) {
      if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        mapper.Password = applicant.Password__c;
      }
    }
    mapper = mapFinancialAccounts(application, mapper);

    log?.info('obtainFundingData -> ReturnMapper -> ' + json.serialize(mapper));
    return mapper;
  }

  /**
   * @description
   * @author Digital Align Team | 03-11-2022
   * @param Application__c application
   * @param FundingSubmissionResponse mapper
   * @return FundingSubmissionResponse
   **/
  global virtual FundingSubmissionResponse mapFinancialAccounts(
    Application__c application,
    FundingSubmissionResponse mapper
  ) {
    if (CollectionUtils.isListEmpty(application.FinancialAccounts__r)) {
      throw new customException('Financial Account not found/ Requested application is under reivew');
    }

    list<FundingSubmissionResponse.FinancialAccount> mapperFinancialAccountList = mapper.FinancialAccount;
    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      FundingSubmissionResponse.FinancialAccount mapperFinancialAccount = new FundingSubmissionResponse.FinancialAccount();
      mapperFinancialAccount.FinancialAccountId = financialAccount.Id;
      mapperFinancialAccount.FinancialProductType = financialAccount.ProductCategory__c;
      mapperFinancialAccount.FinancialProduct = financialAccount.ProductName__c;
      mapperFinancialAccount.Ownership = financialAccount.Ownership__c;
      mapperFinancialAccount.ExternalApplicationNumber = financialAccount.ExternalApplicationNumber__c;

      if (!CollectionUtils.isListEmpty(financialAccount.FinancialAccountTransactions__r)) {
        mapperFinancialAccount.FinancialApplicationTransaction = mapFinancialAccountTranslation(
          financialAccount.FinancialAccountTransactions__r[0]
        );
      }
      mapperFinancialAccountList.add(mapperFinancialAccount);
    }

    mapper.ExternalApplicationNumber = mapperFinancialAccountList[0].ExternalApplicationNumber;
    return mapper;
  }
  /**
   * @description
   * @author Digital Align | 01-10-2022
   * @param FinancialAccountTransaction__c accountTransaction
   * @return FundingSubmissionResponse.FinancialAccountTransaction
   **/
  global virtual FundingSubmissionResponse.FinancialAccountTransaction mapFinancialAccountTranslation(
    FinancialAccountTransaction__c accountTransaction
  ) {
    FundingSubmissionResponse.FinancialAccountTransaction mapperTransaction = new FundingSubmissionResponse.FinancialAccountTransaction();
    mapperTransaction.FinancialAccountTransactionId = accountTransaction.Id;
    mapperTransaction.AccountHolderName = accountTransaction.mflow__AccountHolderName__c;
    mapperTransaction.AccountNumber = accountTransaction.mflow__AccountNumber__c;
    mapperTransaction.Amount = accountTransaction.mflow__Amount__c;
    mapperTransaction.FinancialInstitute = accountTransaction.mflow__FinancialInstitute__c;
    mapperTransaction.RoutingNumber = accountTransaction.mflow__RoutingNumber__c;
    mapperTransaction.TransactionStatus = accountTransaction.TransactionStatus__c;
    mapperTransaction.InstitutionState = accountTransaction.mflow__TransactionStateCode__c;
    mapperTransaction.TransactionType = accountTransaction.TransactionSubType__c;
    mapperTransaction.TransactionDate = date.newinstance(
      accountTransaction.TransactionDate__c.year(),
      accountTransaction.TransactionDate__c.month(),
      accountTransaction.TransactionDate__c.day()
    );
    return mapperTransaction;
  }
}
