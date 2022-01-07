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
    FinServ__FinancialAccount__c financialApplication = new FinServ__FinancialAccount__c();
    // if (application == null) {
    //   throw new customException(System.Label.Application_ApplicationNotFound);
    // }
    // financialApplication = ApplicationService.getInstance()
    //   .readApplicationWithChild(application.Id);

    if (financialApplication != null) {
      FundingResponseMapper.FinancialAccount mapperApplication = new FundingResponseMapper.FinancialAccount();
      mapperApplication.ExternalApplicationNumber = financialApplication.mflow__ExternalApplicationNumber__c;
      mapperApplication.FinancialAccountType = financialApplication.FinServ__FinancialAccountType__c;
      mapperApplication.FinancialProduct = financialApplication.mflow__FinancialProduct__c;
      mapperApplication.Name = financialApplication.Name;
      mapperApplication.Ownership = financialApplication.FinServ__Ownership__c;
      mapperApplication.PrimaryOwner = financialApplication.FinServ__PrimaryOwner__c;
      mapperApplication.Stage = financialApplication.FinServ__Stage__c;
      mapperApplication.Status = financialApplication.FinServ__Status__c;
      // if (
      //   !CollectionUtils.isListEmpty(
      //     financialApplication.FinancialAccountTranslations__r
      //   )
      // ) {
      //   mapperApplication.FinancialAccountTranslations__r.addAll(
      //     mapFinancialAccountTranslation(
      //       mapperApplication.FinancialAccountTranslations__r
      //     )
      //   );
      // } else {
      //   throw new CustomException('No financial transaction account found');
      // }
      mapper.FinancialApplication = mapperApplication;
    } else {
      throw new CustomException(System.Label.Application_ApplicationNotFound);
    }
    log?.info('obtainFundingData -> ReturnMapper -> ' + mapper);
    return mapper;
  }
  global static FundingResponseMapper.FinancialAccountTransaction mapFinancialAccountTranslation(
    FinServ__FinancialAccountTransaction__c accountTransaction
  ) {
    FundingResponseMapper.FinancialAccountTransaction mapperTransaction = new FundingResponseMapper.FinancialAccountTransaction();
    mapperTransaction.AccountHolderName = accountTransaction.mflow__AccountHolderName__c;
    mapperTransaction.AccountNumber = accountTransaction.mflow__AccountNumber__c;
    mapperTransaction.Amount = accountTransaction.FinServ__Amount__c;
    mapperTransaction.FinancialInstitute = accountTransaction.mflow__FinancialInstitute__c;
    mapperTransaction.RoutingNumber = accountTransaction.mflow__RoutingNumber__c;
    mapperTransaction.TransactionStatus = accountTransaction.FinServ__TransactionStatus__c;
    mapperTransaction.TransactionType = accountTransaction.FinServ__TransactionType__c;
    return mapperTransaction;
  }
}
