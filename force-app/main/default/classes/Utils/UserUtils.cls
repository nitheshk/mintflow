/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description This class implement utils function for some
 * basic function for handling user functionality
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class UserUtils {
  //Constant
  private static final String USER_TYPE_GUEST = 'Guest';
  //Attribute
  private static User currentUser;
  /**
   * @description get the current user record
   * fetchs all field from user without checking permission
   * @author Digital Align | 05-11-2021
   * @return User
   **/
  global static User getCurrentUser() {
    if (currentUser != null) {
      return currentUser;
    }
    currentUser = UtilsRepository.getUserById(UserInfo.getUserId());
    return currentUser;
  }

  /**
   * @description Check te user is guest or standard
   * @author Digital Align | 05-11-2021
   * @return Boolean
   **/
  global static Boolean isGuestUser() {
    return UserInfo.getUserType().equalsIgnoreCase(USER_TYPE_GUEST);
  }

  /**
   * @description fetch community user account details
   * @author Digital Align Team | 07-23-2021
   * @param Id userId
   * @return Account
   **/
  global static Account fetchUserAccountByUserId(Id userId) {
    return UtilsRepository.fetchUserAccountByUserId(userId);
  }

  /**
   * @description  The reason behind this is external users or guest users and so on will not have access to ProfileId field in user object.
   * profileID need to assign inside without sharing context
   * @Reference Solution for a known issue : System.SObjectException: Field is not writeable: User.ProfileId
   * https://salesforce.stackexchange.com/questions/123105/sobjectexception-field-is-not-writeable-user-profileid
   * https://www.infallibletechie.com/2016/06/systemsobjectexception-field-is-not.html
   * @author Digital Align Team | 07-23-2021
   * @param User userObj
   * @param ID profileId
   * @return user
   **/
  global static user assignProfileIdToUser(User userObj, ID profileId) {
    return SObjectWithoutSharing.assignProfileIdToUser(userObj, profileId);
  }
}
