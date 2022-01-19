/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FundingDataAPI {
  private static logger log = logger.getInstance(ApplicationDataAPI.class);
  global static FundingResponseMapper obtainFundingData(
    string applicationNumber
  ) {
    log
      ?.fine(
        'Inside obtainFundingData -> applicationNumber -> ' + applicationNumber
      );
    FundingResponseMapper mapper = new FundingResponseMapper();

    if (String.isBlank(applicationNumber)) {
      throw new CustomException(
        System.Label.Application_ApplicationNameCannotBeBlank
      );
    }
    Account application = DataAPIRepository.readApplicationByApplicationNumber(
      applicationNumber
    );

    if (application == null) {
      throw new customException(System.Label.Application_ApplicationNotFound);
    }
    List<FinServ__FinancialAccount__c> financialApplications = DataAPIRepository.readFinancialAccountWithChildByApplicationId(
      application.Id
    );
    if (CollectionUtils.isListEmpty(financialApplications)) {
      throw new customException(System.Label.Application_ApplicationNotFound);
    }
    mapper.Application = application.Id;
    mapper.ExternalApplicationNumber = application.ExternalApplicationNumber__c;
    mapper.Stage = application.mflow__Stage__c;
    mapper.Status = application.FinServ__Status__c;
    mapper.FinancialApplication.addAll(
      mapFinancialApplication(financialApplications)
    );

    log?.info('obtainFundingData -> ReturnMapper -> ' + mapper);
    return mapper;
  }

  global static list<FundingResponseMapper.FinancialAccount> mapFinancialApplication(
    List<FinServ__FinancialAccount__c> financialApplicationsList
  ) {
    list<FundingResponseMapper.FinancialAccount> mapperFinancialAccountList = new List<FundingResponseMapper.FinancialAccount>();
    for (
      FinServ__FinancialAccount__c finApplication : financialApplicationsList
    ) {
      FundingResponseMapper.FinancialAccount mapperFinancialAccount = new FundingResponseMapper.FinancialAccount();

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
      }
      mapperFinancialAccountList.add(mapperFinancialAccount);
    }
    return mapperFinancialAccountList;
  }
  /**
   * @description
   * @author Digital Align | 01-10-2022
   * @param FinServ__FinancialAccountTransaction__c accountTransaction
   * @return FundingResponseMapper.FinancialAccountTransaction
   **/
  global static List<FundingResponseMapper.FinancialAccountTransaction> mapFinancialAccountTranslation(
    List<FinServ__FinancialAccountTransaction__c> accountTransactions
  ) {
    list<FundingResponseMapper.FinancialAccountTransaction> mapperAccountTransactions = new List<FundingResponseMapper.FinancialAccountTransaction>();
    for (
      FinServ__FinancialAccountTransaction__c accountTransaction : accountTransactions
    ) {
      FundingResponseMapper.FinancialAccountTransaction mapperTransaction = new FundingResponseMapper.FinancialAccountTransaction();
      mapperTransaction.AccountHolderName = accountTransaction.mflow__AccountHolderName__c;
      mapperTransaction.AccountNumber = accountTransaction.mflow__AccountNumber__c;
      mapperTransaction.Amount = accountTransaction.FinServ__Amount__c;
      mapperTransaction.FinancialInstitute = accountTransaction.mflow__FinancialInstitute__c;
      mapperTransaction.RoutingNumber = accountTransaction.mflow__RoutingNumber__c;
      mapperTransaction.TransactionStatus = accountTransaction.FinServ__TransactionStatus__c;
      mapperTransaction.TransactionType = accountTransaction.FinServ__TransactionType__c;
      mapperAccountTransactions.add(mapperTransaction);
    }
    return mapperAccountTransactions;
  }
}
