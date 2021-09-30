createUser();

public static void createUser() {
  User userObj = new User();
  userObj.FirstName = 'Online';
  userObj.LastName = 'User';
  userObj.Alias = 'any';
  //userObj.Email = 'Online@User.Mflow.' + System.currentTimeMillis() + '.com';
  userObj.Email = 'nithesh.k@digitalalign.com';
  userObj.Username = 'Online@User.Mflow.' + System.currentTimeMillis() + '.com';
  userObj.CommunityNickname = 'Mflow.' + System.currentTimeMillis();
  userObj.LocaleSidKey = 'en_US';
  userObj.LanguageLocaleKey = 'en_US';
  userObj.EmailEncodingKey = 'UTF-8';
  userObj.TimeZoneSidKey = 'America/Los_Angeles';
  UserUtils.assignProfileIdToUser(
    userObj,
    UserRepository.fetchProfileByName('MFlowOnlineSalesforcePlatform')?.id
  );
  UserRepository.insertRecord(userObj);

  system.setPassword(userObj.Id, 'Test@123');

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
    WHERE Profile.Name = 'MFlowOnlineSalesforcePlatform'
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
}
