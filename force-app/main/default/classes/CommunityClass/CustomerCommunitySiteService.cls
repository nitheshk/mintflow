/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class CustomerCommunitySiteService extends AbstractService {
  @TestVisible
  private static CustomerCommunitySiteService serviceInstance;

  public CustomerCommunitySiteService() {
    super(CustomerCommunitySiteService.class);
  }

  /**
   * @description Provides a singleton instance of CustomerCommunitySiteService from which all other class methods can be accessed.
   * @author Digital Align Team | 04/01/2022
   * @return Object  singleton
   **/
  public static CustomerCommunitySiteService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (CustomerCommunitySiteService) getInstance(CustomerCommunitySiteService.class);
    }
    return serviceInstance;
  }

  /**
   * @description create employee user for an FinInst
   * @author Digital Align Team | 07-15-2021
   * @param Contact contactObj
   * @return User
   **/
  global virtual User createCustomerCommunityUser(Contact contactObj) {
    User userObj = new User();
    Long currentTimeStamp = System.currentTimeMillis();
    //special use case
    userObj = UserUtils.assignProfileIdToUser(
      userObj,
      CommunitySiteRepository.readProfileByName(CommunityConstant.CUSTOMER_COMMUNITY_USER_PROFILE)?.Id
    );
    userObj.ContactId = contactObj.Id;
    userObj.FirstName = contactObj.FirstName;
    userObj.LastName = contactObj.LastName;
    userObj.Email = contactObj.Email;
    userObj.Username = contactObj.Email + '.' + currentTimeStamp;
    userObj.CompanyName = userObj.FirstName + userObj.LastName;
    userObj.Title = userObj.FirstName + userObj.LastName;
    userObj.Alias = userObj.FirstName?.left(4) + userObj.LastName.left(4);
    userObj.CommunityNickname = userObj.Alias + currentTimeStamp;
    userObj.MobilePhone = contactObj.MobilePhone;
    userObj.TimeZoneSidKey = 'America/Los_Angeles';
    userObj.EmailEncodingKey = 'ISO-8859-1';
    userObj.LocaleSidKey = 'en_US';
    userObj.LanguageLocaleKey = 'en_US';

    CommunitySiteRepository.insertRecord(userObj);
    CustomerCommunitySiteService.assignCommunityPermissionSetAsync(userObj.Id);
    return userObj;
  }

  /**
   * @description assign permission set for user in future context (to Avoid mixed dml exception)
   * @author Digital Align Team | 07-14-2021
   * @param Id userId
   **/
  @future
  global static void assignCommunityPermissionSetAsync(Id userId) {
    CustomerCommunitySiteService.getInstance().assignCommunityPermissionSet(userId);
  }

  /**
   * @description assign permission set for user
   * @author Digital Align Team | 07-14-2021
   * @param Id userObj
   * @return virtual
   **/
  global virtual List<PermissionSetAssignment> assignCommunityPermissionSet(Id userId) {
    //Permission Set Name need to move to customer setting

    // #Issue commmunity user  Does have access to createfor Lead
    List<PermissionSet> permissionSetList = CommunitySiteRepository.readPermissionSetByNames(
      new List<String>{ CommunityConstant.CUSTOMER_COMMUNITY_PEMRISSION_SET }
    );

    List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : permissionSetList) {
      permissionSetAssignmentList.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = userId));
    }
    CommunitySiteRepository.insertRecords(permissionSetAssignmentList);
    return permissionSetAssignmentList;
  }
}
