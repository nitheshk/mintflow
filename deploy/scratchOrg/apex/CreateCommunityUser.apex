createUser();

public static void createUser() {
  List<Contact> contactObjs = [
    SELECT Id
    FROM Contact
    WHERE Account.Name = 'Online Community Account' AND FirstName = 'Community' AND LastName = 'Plus User'
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
  mflow.UserUtils.assignProfileIdToUser(
    userObj,
    mflow.UtilsRepository.fetchProfileByName('MFlowCustomerCommunityPlusLogin')?.id
  );
  mflow.UtilsRepository.insertRecord(userObj);

  system.setPassword(userObj.Id, 'Test@1234');
  system.resetPassword(userObj.Id, true);

  Map<String, String> result = new Map<String, String>();
  result.put('Id', userObj.Id);
  result.put('Username', userObj.Username);
  system.debug('{QueryStart} ' + Json.serialize(result) + ' {QueryEnd}');
}
