//Create Dealer Employee Using ContactId
system.debug(
  (new UserAccountManagementController())
    .createDealerEmployeeAccount(
      new Map<String, Object>{ 'ContactId' => '0030p00000QWqxuAAD' }
    )
);

//
System.debug(
  UserAccountManagementRepository.readPermissionSetByNames(
    new List<String>{ 'DoTractGuest', 'DoTractSystemAdmin' }
  )
);

//
System.debug(
  DatabaseUtils.getRecords(
    Query.newInstance(PermissionSet.SObjectType)
      .whereIn('Name', new List<String>{ 'DoTractGuest', 'DoTractSystemAdmin' })
      .toString(true)
  )
);

//Inactive User
List<User> users = [
  SELECT Id
  FROM User
  WHERE
    profile.Name = 'DealerCommunity Profile'
    OR profile.Name = 'FinancialInstitueCommunity Profile'
];
for (user u : users)
  u.isActive = false;
update users;

//
System.debug(UserRepository.getUserAccountOwnerId('0050w000002dV4q'));

//

