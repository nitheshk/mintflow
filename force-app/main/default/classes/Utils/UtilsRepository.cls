/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description Repository to pickup some basic utils
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class UtilsRepository extends DatabaseUtils {
  /**
   * @description  Get user record based on user id passed
   * @author Digital Align | 05-11-2021
   * @param Object id
   * @return User
   **/
  global static User getUserById(Id userId) {
    return (User) getRecord(
      Query.newInstance(User.SObjectType).addFields().addFields('Profile.Name').queryById(userId)
    );
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
      Query.newInstance(Profile.SObjectType).addFields().whereEq('Name', profileName).addLimit(1).toString()
    );
  }

  /**
   * @description
   * @author Digital Align Team | 04-02-2022
   * @param Id userId
   * @param String siteType -> ChatterNetworkPicasso, Siteforce
   * @return Site
   **/
  global static Site fetchSite(Id userId, String siteType) {
    return (Site) getRecord(
      Query.newInstance(Site.SObjectType)
        .addFields()
        .whereEq('GuestUserId', userId)
        .andCon()
        .whereEq('SiteType', siteType)
        .addLimit(1)
        .toString()
    );
  }
}
