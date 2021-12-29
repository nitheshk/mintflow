// #1
ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  '001N0000024pk46IAA',
  '',
  'Primary',
  'ApplicationFlow'
);
system.debug(request.token);

ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFONvS2ENRY3tJ2dmX4xaGrToRT0n0EfRfSvmJKoi/KGMvBUjgpjiohzXLJ3N6eo91ktcvmNbuH1wGGijtdilrLj/2TsYhahrqdOQ9tC/VlwVVNs1JQ5ubesQ8qj+tu5d4Cp5QkJ9+cbQ5QcUbIKsAB4=';

ApexResponse res = FinancingController.generateLinkToken(request);
system.debug('Full Json : ' + res.data);

ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFONvS2ENRY3tJ2dmX4xaGrToRT0n0EfRfSvmJKoi/KGMvBUjgpjiohzXLJ3N6eo91ktcvmNbuH1wGGijtdilrLj/2TsYhahrqdOQ9tC/VlwVVNs1JQ5ubesQ8qj+tu5d4Cp5QkJ9+cbQ5QcUbIKsAB4=';
request.header = '{"publicToken":"public-sandbox-bb9f2863-e5d3-45c0-9fb5-e3f6cedc900c"}';
ApexResponse res = FinancingController.fetchAccountsForTransaction(request);
system.debug('Full Json : ' + res.data);
