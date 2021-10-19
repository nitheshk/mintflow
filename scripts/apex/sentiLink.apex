Map<String, object> params = new Map<String, object>();
lead leadObj = [
  SELECT
    Id,
    LastName,
    FirstName,
    Company,
    City,
    Street,
    PostalCode,
    State,
    Country,
    Address,
    Phone,
    Email,
    LeadSource,
    dau01__SSN__c,
    dau01__Birthdate__c
  FROM Lead
  LIMIT 1
];
params.put('leadObj', leadObj);
params.put('APIName', 'SentiLink');
system.debug(params);
Map<String, Object> response = SentiLinkService.getInstance()
  .customerScores(params);
system.debug('Response =' + response.get('Data'));
