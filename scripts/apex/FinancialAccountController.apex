// #1

List<FinServ__FinancialAccount__c> fs = FinancialAccountRepository.readFinancialAccountsWithChild(
  new Set<Id>{ 'a0F0p000003GWMHEA4' }
);

fs[0].mflow__ExternalApplicationNumber__c = '45645';
FinancialAccountTransaction__c fst = new FinancialAccountTransaction__c(
  FinServ__FinancialAccount__c = fs[0].Id,
  mflow__Amount__c = 565,
  TransactionDate__c = Datetime.now()
);

FinServ__FinancialAccount__c finacc = (FinServ__FinancialAccount__c) SObjectConstructor.getInstance(
    fs[0]
  )
  .addChildObject('mflow__FinancialAccountTransactionsTemp__r', fst)
  .build();

fs = FinancialAccountService.getInstance()
  .saveFinancialAccounts(
    new List<FinServ__FinancialAccount__c>{ finacc },
    '0010p000013GlKCAA0'
  );
system.debug('acc : ' + JSON.Serialize(fs));
logger.persist();
