/**
 * Copyright (c) 2021 Digital Align
 * @group Utils Repository
 * @author Digital Align Team
 * @reference
 * @description Repository to pickup some basic user related data
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class UserRepository extends DatabaseUtils {
  /**
   * @description  Get user record based on user id passed
   * @author Digital Align | 05-11-2021
   * @param Object id
   * @return User
   **/
  global static User getUserById(Id userId) {
    return (User) getRecord(
      Query.newInstance(User.SObjectType).addFields().queryById(userId)
    );
  }

  /**
   * @description For Community user, get ownerid of current user
   * @author Digital Align Team | 07-15-2021
   * @param Id id
   * @return Id
   **/
  global static Id getUserAccountOwnerId(Id id) {
    User userObj = (User) getRecord(
      Query.newInstance(User.SObjectType)
        .addFields()
        .queryLookup('Contact')
        .queryLookup('Account')
        .addFields('OwnerId')
        .run()
        .run()
        .queryById(id)
    );
    return userObj?.Contact?.Account?.OwnerId;
  }

  /**
   * @description get Community user account detail by user id
   * @author Digital Align Team | 07-23-2021
   * @param Id userId
   * @return Account
   **/
  global static Account fetchUserAccountByUserId(Id userId) {
    User userObj = (User) getRecord(
      Query.newInstance(User.SObjectType)
        .queryLookup('Contact')
        .queryLookup('Account')
        .addFields()
        .run()
        .run()
        .queryById(userId)
    );
    return userObj?.Contact?.Account;
  }

  /**
   * @description fetch Profile by profile name
   * @author Digital Align Team | 07-23-2021
   * @param String profileName
   * @return Profile
   **/
  global static Profile fetchProfileByName(String profileName) {
    return (Profile) getRecord(
      Query.newInstance(Profile.SObjectType)
        .addFields()
        .whereEq('Name', profileName)
        .addLimit(1)
        .toString()
    );
  }
}
