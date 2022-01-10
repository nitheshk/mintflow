// #1

List<FinServ__FinancialAccount__c> fs = FinancialAccountRepository.readFinancialAccountsWithChild(
  new Set<Id>{ 'a0F0p000003GWMHEA4' }
);

fs[0].mflow__ExternalApplicationNumber__c = '45645';
FinServ__FinancialAccountTransaction__c fst = new FinServ__FinancialAccountTransaction__c(
  FinServ__FinancialAccount__c = fs[0].Id,
  FinServ__Amount__c = 565,
  FinServ__TransactionDate__c = Datetime.now()
);

FinServ__FinancialAccount__c finacc = (FinServ__FinancialAccount__c) SObjectConstructor.getInstance(
    fs[0]
  )
  .addChildObject('FinServ__FinancialAccountTranslations__r', fst)
  .build();

fs = FinancialAccountService.getInstance()
  .saveFinancialAccounts(
    new List<FinServ__FinancialAccount__c>{ finacc },
    '0010p000013GlKCAA0'
  );
system.debug('acc : ' + JSON.Serialize(fs));
logger.persist();
