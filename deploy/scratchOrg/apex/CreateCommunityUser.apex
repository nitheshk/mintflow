createUser();

public static void createUser() {
  List<Contact> contactObjs = [
    SELECT Id
    FROM Contact
    WHERE
      Account.Name = 'Online Community Account'
      AND FirstName = 'Community'
      AND LastName = 'Plus User'
    LIMIT 1
  ];

  User userObj = new User();
  userObj.FirstName = 'Online';
  userObj.LastName = 'User';
  userObj.Alias = 'any';
  userObj.ContactId = contactObjs[0].Id;
  //userObj.Email = 'Online@User.Mflow.' + System.currentTimeMillis() + '.com';
  userObj.Email = '{{Email}}';
  userObj.Username = 'OnlineUser@Mflow.' + System.currentTimeMillis() + '.com';
  userObj.CommunityNickname = 'Mflow.' + System.currentTimeMillis();
  userObj.LocaleSidKey = 'en_US';
  userObj.LanguageLocaleKey = 'en_US';
  userObj.EmailEncodingKey = 'UTF-8';
  userObj.TimeZoneSidKey = 'America/Los_Angeles';
  UserUtils.assignProfileIdToUser(
    userObj,
    UtilsRepository.fetchProfileByName('MFlowCustomerCommunityPlusLogin')?.id
  );
  UtilsRepository.insertRecord(userObj);

  system.setPassword(userObj.Id, 'Test@1234');
  system.resetPassword(userObj.Id, true);

  List<PermissionSet> permissionSetList = [
    SELECT Id
    FROM PermissionSet
    WHERE
      Name = 'FinancialServicesCloudExtension'
      OR Name = 'FinancialServicesCloudBasic'
      OR Name = 'FinancialServicesCloudStandard'
  ];

  List<User> siteUser = [
    SELECT id, Name
    FROM User
    WHERE Profile.Name = 'MFlowCustomerCommunityPlusLogin' AND isActive = TRUE
  ];

  delete [
    SELECT Id
    FROM PermissionSetAssignment
    WHERE AssigneeId = :siteUser AND PermissionSetId = :permissionSetList
  ];

  List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
  for (User u : siteUser) {
    for (PermissionSet ps : permissionSetList) {
      permissionSetAssignmentList.add(
        new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = u.Id)
      );
    }
  }

  insert permissionSetAssignmentList;
  Map<String, String> result = new Map<String, String>();
  result.put('Id', userObj.Id);
  result.put('Username', userObj.Username);
  system.debug('{QueryStart} ' + Json.serialize(result) + ' {QueryEnd}');
}
