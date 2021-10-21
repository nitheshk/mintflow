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
  WHERE id = '00Q1y000001j6rJEAQ'
];
params.put('leadObj', leadObj);
params.put('APIName', 'SentiLink');
system.debug(params);
Map<String, Object> response = SentiLinkService.getInstance()
  .customerScores(params);
system.debug('Response =' + response.get('Data'));

// REQUIRED FIELDS
//     LastName,
//     FirstName,
//     Company,
//     City,
//     Street,
//     PostalCode, - 5 digit
//     State, - state value should be two letter abrivation ex: CA, AA
//     Country,
//     Address,
//     Phone,
//     Email,
//     LeadSource,
//     dau01__SSN__c, 458968987 or 123-36-3698
//     dau01__Birthdate__c

