createAccount();

public static void createAccount() {
  List<Contact> contactObjs = [
    SELECT Id
    FROM Contact
    WHERE
      Account.Name = 'Online Community Account'
      AND FirstName = 'Community'
      AND LastName = 'Plus User'
    LIMIT 1
  ];
  if (!contactObjs.isEmpty()) {
    return;
  }

  Account accountObj = new Account();
  accountObj.Name = 'Online Community Account';
  accountObj.RecordTypeId = mflow.SObjectUtils.recordTypeIdByDevName(
    Account.SobjectType,
    'IndustriesInstitution'
  );
  insert accountObj;

  Contact contactObj = new Contact();
  contactObj.FirstName = 'Community';
  contactObj.LastName = 'Plus User';
  contactObj.AccountId = accountObj.Id;
  contactObj.RecordTypeId = mflow.SObjectUtils.recordTypeIdByDevName(
    Contact.SobjectType,
    'IndustriesIndividual'
  );
  insert contactObj;
}
