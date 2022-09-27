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

//#4

ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  'a021y000000fMvNAAU',
  'a001y000000q4lDAAQ',
  'Primary',
  'ApplicationFlow'
);
System.debug('Token :' + request.token);

ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFK47w+KxidbycgQrn9aXie+lhnDD6mYYq/uwqdyD/zcJHk3HD29SZW9alfzmHtq9FMB3jPJUm/88CZ+0WbZdTlX7i3Ak2+u6O090GNE5+2TEB+EHgheUDq3uzhwjgLSzvA==';
ApexResponse res = FinancingController.generateUrlForFunding(request);
system.debug('Full Json : ' + res.data);

List<FinancialProduct__c> products = FinancialAccountRepository.readFinancialProductsByMultipleCodes('IC002,IC0012');
system.debug('products : ' + products);

// #5  vehicle search

system.debug(
  FinancialAccountService.getInstance()
    .fetchVehicleDetails(new Map<String, Object>{ 'searchType' => 'Vin', 'vin' => '565516' })
);

system.debug(
  FinancialAccountService.getInstance()
    .fetchVehicleDetails(new Map<String, Object>{ 'searchType' => 'Make', 'year' => '2013' })
);

system.debug(
  FinancialAccountService.getInstance()
    .fetchVehicleDetails(new Map<String, Object>{ 'searchType' => 'Model', 'year' => '2013', 'make' => '77' })
);

system.debug(
  FinancialAccountService.getInstance()
    .fetchVehicleDetails(
      new Map<String, Object>{ 'searchType' => 'SubModel', 'year' => '2013', 'make' => '77', 'model' => '254' }
    )
);
