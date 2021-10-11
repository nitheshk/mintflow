updateAdminPermissionSet();
updateGuestPermissionSet();
//updateRoleToCurrentUser();

public static void updateGuestPermissionSet() {
  List<PermissionSet> permissionSetList = [
    SELECT Id
    FROM PermissionSet
    WHERE Name = 'DoTractGuest'
  ];

  List<User> siteUser = [
    SELECT id, Name
    FROM User
    WHERE
      Profile.Name = 'Dealer Profile'
      OR Profile.Name = 'Online Profile'
      OR Profile.Name = 'FinancialInstitute Profile'
      OR Profile.Name = 'DoTract Profile'
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

public static void updateAdminPermissionSet() {
  List<PermissionSet> permissionSetList = [
    SELECT Id
    FROM PermissionSet
    WHERE
      Name = 'DoTractSystemAdmin'
      OR Name = 'FinancialServicesCloudExtension'
      OR Name = 'FinancialServicesCloudBasic'
      OR Name = 'FinancialServicesCloudStandard'
  ];

  List<User> siteUser = [
    SELECT id, Name
    FROM User
    WHERE Profile.Name = 'System Administrator'
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

public static void updateRoleToCurrentUser() {
  User u = [SELECT id FROM User WHERE id = :Userinfo.getUserId() LIMIT 1];
  UserRole r = [SELECT id FROM UserRole WHERE DeveloperName = 'CEO' LIMIT 1];
  u.UserRoleId = r.id;
  update u;
}
