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
      throw new customException(
        'Financial Account not found/ Requested application is under reivew'
      );
    }
    for (Applicant__c applicant : application.Applicants__r) {
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
    mapper.Status = application.Status__c;
    mapper.Password = primaryApplicant.Password__c;
    mapper.FinancialAccount.addAll(
      mapFinancialApplication(financialApplications)
    );

    log?.info('obtainFundingData -> ReturnMapper -> ' + json.serialize(mapper));
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
      //#removeFSC
      //mapperFinancialAccount.FinancialAccountType = finApplication.FinServ__FinancialAccountType__c;
      mapperFinancialAccount.FinancialProduct = finApplication.mflow__FinancialProduct__c;
      mapperFinancialAccount.Name = finApplication.Name;
      mapperFinancialAccount.Ownership = finApplication.Ownership__c;
      //#removeFSC
      //mapperFinancialAccount.PrimaryOwner = finApplication.FinServ__PrimaryOwner__c;
      //#removeFSC
      // if (
      //   !CollectionUtils.isListEmpty(
      //     finApplication.FinancialAccountTransactions__r
      //   )
      // ) {
      //   mapperFinancialAccount.FinancialApplicationTransaction = mapFinancialAccountTranslation(
      //     finApplication.FinancialAccountTransactions__r[0]
      //   );
      // } else {
      //   throw new CustomException('No financial transaction account found');
      // }
      mapperFinancialAccountList.add(mapperFinancialAccount);
    }
    return mapperFinancialAccountList;
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
