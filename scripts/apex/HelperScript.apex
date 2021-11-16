//Inactive User
List<User> users = [
  SELECT Id
  FROM User
  WHERE profile.Name = 'MFlowOnlineSalesforcePlatform'
];
for (user u : users)
  u.isActive = false;
update users;
