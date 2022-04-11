// #1

List<FinancialAccount__c> fs = FinancialAccountRepository.readFinancialAccountsWithChild(
  new Set<Id>{ 'a0F0p000003GWMHEA4' }
);

fs[0].mflow__ExternalApplicationNumber__c = '45645';
FinancialAccountTransaction__c fst = new FinancialAccountTransaction__c(
  FinancialAccount__c = fs[0].Id,
  mflow__Amount__c = 565,
  TransactionDate__c = Datetime.now()
);

FinancialAccount__c finacc = (FinancialAccount__c) SObjectConstructor.getInstance(fs[0])
  .addChildObject('mflow__FinancialAccountTransactions__r', fst)
  .build();

fs = FinancialAccountService.getInstance()
  .saveFinancialAccounts(new List<FinancialAccount__c>{ finacc }, '0010p000013GlKCAA0');
system.debug('acc : ' + JSON.Serialize(fs));
logger.persist();

//Manually Approved Funding
FinancialAccountService.testApproveFundingSubmission('App-00166');

//fetchProductWithFeatures
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  'a026D000004YbyGQAS',
  'a006D000008AcN5QAK',
  'Primary',
  'ApplicationFlow'
);

ApexResponse rs = FinancialAccountController.fetchProductFeatures(request);
System.debug(rs.data);

///FinancialAccountController
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  'a026D000004YflcQAC',
  'a006D000008AeOTQA0',
  'Primary',
  'ApplicationFlow'
);

ApexResponse rs = FinancialAccountController.readFinancialAccounts(request);
System.debug(rs.data);
