/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class BuildFundingWrapper extends AbstractService {
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
      serviceInstance = (BuildFundingWrapper) getInstance(
        BuildFundingWrapper.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align | 01-20-2022
   * @param string applicationNumber
   * @return FundingSubmissionResponse
   **/
  global virtual FundingSubmissionResponse obtainFundingData(
    string applicationNumber
  ) {
    log
      ?.fine(
        'Inside obtainFundingData -> applicationNumber -> ' + applicationNumber
      );
    FundingSubmissionResponse mapper = new FundingSubmissionResponse();
    Applicant__c primaryApplicant;
    if (String.isBlank(applicationNumber)) {
      throw new CustomException(
        System.Label.Application_ApplicationNameCannotBeBlank
      );
    }
    Account application = SubmissionRepository.readApplicationByApplicationNumber(
      applicationNumber
    );

    if (application == null) {
      throw new customException(System.Label.Application_ApplicationNotFound);
    }
    List<FinServ__FinancialAccount__c> financialApplications = SubmissionRepository.readFinancialAccountWithChildByApplicationId(
      application.Id
    );
    if (CollectionUtils.isListEmpty(financialApplications)) {
      throw new customException(System.Label.Application_ApplicationNotFound);
    }
    for (Applicant__c applicant : application.applicants__r) {
      Set<String> applicantTypes = new Set<String>(
        applicant.ApplicantType__c.split(';')
      );
      if (applicantTypes.contains('Primary')) {
        primaryApplicant = applicant;
        break;
      }
    }
    mapper.Application = application.Id;
    mapper.ExternalApplicationNumber = application.ExternalApplicationNumber__c;
    mapper.Stage = application.mflow__Stage__c;
    mapper.Status = application.FinServ__Status__c;
    mapper.Password = primaryApplicant.Password__c;
    mapper.FinancialAccount.addAll(
      mapFinancialApplication(financialApplications)
    );

    log?.info('obtainFundingData -> ReturnMapper -> ' + mapper);
    return mapper;
  }

  /**
   * @description
   * @author Digital Align | 01-20-2022
   * @param List<FinServ__FinancialAccount__c> financialApplicationsList
   * @return virtual
   **/
  global virtual list<FundingSubmissionResponse.FinancialAccount> mapFinancialApplication(
    List<FinServ__FinancialAccount__c> financialApplicationsList
  ) {
    list<FundingSubmissionResponse.FinancialAccount> mapperFinancialAccountList = new List<FundingSubmissionResponse.FinancialAccount>();
    for (
      FinServ__FinancialAccount__c finApplication : financialApplicationsList
    ) {
      FundingSubmissionResponse.FinancialAccount mapperFinancialAccount = new FundingSubmissionResponse.FinancialAccount();
      mapperFinancialAccount.FinancialAccountId = finApplication.Id;
      mapperFinancialAccount.FinancialAccountType = finApplication.FinServ__FinancialAccountType__c;
      mapperFinancialAccount.FinancialProduct = finApplication.mflow__FinancialProduct__c;
      mapperFinancialAccount.Name = finApplication.Name;
      mapperFinancialAccount.Ownership = finApplication.FinServ__Ownership__c;
      mapperFinancialAccount.PrimaryOwner = finApplication.FinServ__PrimaryOwner__c;
      if (
        !CollectionUtils.isListEmpty(
          finApplication.FinServ__FinancialAccountTranslations__r
        )
      ) {
        mapperFinancialAccount.FinancialApplicationTransaction = mapFinancialAccountTranslation(
          finApplication.FinServ__FinancialAccountTranslations__r
        );
      } else {
        throw new CustomException('No financial transaction account found');
      }
      mapperFinancialAccountList.add(mapperFinancialAccount);
    }
    return mapperFinancialAccountList;
  }
  /**
   * @description
   * @author Digital Align | 01-10-2022
   * @param FinServ__FinancialAccountTransaction__c accountTransaction
   * @return FundingSubmissionResponse.FinancialAccountTransaction
   **/
  global virtual FundingSubmissionResponse.FinancialAccountTransaction mapFinancialAccountTranslation(
    FinServ__FinancialAccountTransaction__c accountTransaction
  ) {
    FundingSubmissionResponse.FinancialAccountTransaction mapperTransaction = new FundingSubmissionResponse.FinancialAccountTransaction();
    mapperTransaction.FinancialAccountTransactionId = accountTransaction.Id;
    mapperTransaction.AccountHolderName = accountTransaction.mflow__AccountHolderName__c;
    mapperTransaction.AccountNumber = accountTransaction.mflow__AccountNumber__c;
    mapperTransaction.Amount = accountTransaction.FinServ__Amount__c;
    mapperTransaction.FinancialInstitute = accountTransaction.mflow__FinancialInstitute__c;
    mapperTransaction.RoutingNumber = accountTransaction.mflow__RoutingNumber__c;
    mapperTransaction.TransactionStatus = accountTransaction.FinServ__TransactionStatus__c;
    mapperTransaction.InstitutionState = accountTransaction.mflow__TransactionStateCode__c;
    mapperTransaction.TransactionType = getStatusMapping(
      'FinServ__TransactionSubtype__c',
      accountTransaction.FinServ__TransactionSubtype__c
    );
    mapperTransaction.TransactionDate = date.newinstance(
      accountTransaction.FinServ__TransactionDate__c.year(),
      accountTransaction.FinServ__TransactionDate__c.month(),
      accountTransaction.FinServ__TransactionDate__c.day()
    );
    return mapperTransaction;
  }

  /**
   * @description
   * @author Digital Align | 01-20-2022
   * @param String fieldName
   * @param String value
   * @return virtual
   **/
  global virtual String getStatusMapping(String fieldName, String value) {
    return (new Map<String, String>{
        'ACH' => 'ACH',
        'Check' => 'Check',
        'Cash Deposit' => 'Cash'
      })
      .get(value);
  }
}
