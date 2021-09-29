/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Dealer Account Creation
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class DealerAccountCreationService extends AbstractService {
  @TestVisible
  private static DealerAccountCreationService serviceInstance;

  public DealerAccountCreationService() {
    super(DealerAccountCreationService.class);
  }

  /**
   * @description Provides a singleton instance of DealerAccountCreationService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-12-2021
   * @return Object  singleton
   **/
  public static DealerAccountCreationService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (DealerAccountCreationService) getInstance(
        DealerAccountCreationService.class
      );
    }
    return serviceInstance;
  }

  //************ Dealer Business Account Creation  ****************/

  /**
   * @description convert lead into contact and account
   * @author Digital Align Team | 07-15-2021
   * @param Lead leadObj
   * @return Database.LeadConvertResult
   **/
  global virtual Database.LeadConvertResult convertDealerLead(Lead leadObj) {
    Database.LeadConvert leadToConvert = new database.LeadConvert();
    leadToConvert.setLeadId(leadObj.id);
    leadToConvert.setConvertedStatus(
      UserAccountManagementRepository.fetchLeadStatus().MasterLabel
    );
    leadToConvert.setDoNotCreateOpportunity(true);

    Id accountOwnerId = UserRepository.getUserAccountOwnerId(
      UserInfo.getUserId()
    );

    if (accountOwnerId != null) {
      leadToConvert.setOwnerId(accountOwnerId);
    } else {
      leadToConvert.setOwnerId(UserInfo.getUserId());
    }

    Database.LeadConvertResult leadConversionResults = SObjectWithoutSharing.convertLead(
      leadToConvert
    );
    return leadConversionResults;
  }

  /**
   * @description update dealer contact detail which are not updated during lead conversion
   * @author Digital Align Team | 07-15-2021
   * @param Lead leadObj
   * @param Contact businessContactObj
   * @return Contact
   **/
  global virtual Contact updateDealerContact(
    Lead leadObj,
    Contact businessContactObj
  ) {
    businessContactObj.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
      Contact.SobjectType,
      DealerConstants.DEALER_ADMIN_CONTACT_RECORDTYPE
    );
    businessContactObj.UserContactType__c = DealerConstants.DEALER_ADMIN_CONTACT_TYPE;
    businessContactObj.LeadSource = 'Partner Referral';
    UserAccountManagementRepository.upsertRecord(businessContactObj);
    return businessContactObj;
  }

  /**
   * @description assign permission set for user
   * @author Digital Align Team | 07-14-2021
   * @param Id userObj
   * @return virtual
   **/
  global virtual List<PermissionSetAssignment> assignCommunityPermissionSet(
    Id userId
  ) {
    // #Issue Lead Does have access to createfor commmunity user
    List<PermissionSet> permissionSetList = UserAccountManagementRepository.readPermissionSetByNames(
      new List<String>{ DealerConstants.DEALER_COMMUNITY_PERMISSION_SET }
    );

    List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : permissionSetList) {
      permissionSetAssignmentList.add(
        new PermissionSetAssignment(
          PermissionSetId = ps.Id,
          AssigneeId = userId
        )
      );
    }
    UserAccountManagementRepository.insertRecords(permissionSetAssignmentList);
    return permissionSetAssignmentList;
  }

  //************ Dealer Employee Account Creation  ****************/

  /**
   * @description
   * @author Digital Align | 08-24-2021
   * @param string recordId
   * @return virtual
   **/
  global virtual Object fetchDealerEmployeeActiveStatus(string recordId) {
    system.debug('recordId= ' + recordId);
    if (String.isBlank(recordId)) {
      throw new CustomException('Invalid contact Id');
    }
    user userObj = UserAccountManagementRepository.getUserByContactId(recordId);
    if (userObj == null) {
      throw new CustomException('Employee Record Not Found');
    }
    return userObj;
  }
  /**
   * @description
   * @author Digital Align | 08-24-2021
   * @param Map<String Object> params
   * @return virtual
   **/
  global virtual Object updateDealerEmployeeActiveStatus(
    Map<String, Object> params
  ) {
    system.debug('params= ' + params);
    user userObj = (user) JSON.deserialize(
      (string) params?.get('jsonString'),
      user.class
    );
    if (userobj == null) {
      throw new CustomException('Empty employee data');
    }
    userObj = (user) UserAccountManagementRepository.upsertRecord(userobj);
    if (userObj == null) {
      throw new CustomException('Employee Record Not Found');
    }
    return userObj;
  }
  /**
   * @description
   * @author Digital Align | 09-01-2021
   * @return virtual
   **/
  global virtual Contact fetchLoggedinUserContactDetails() {
    user userObj = UserRepository.getUserById(UserInfo.getUserId());
    if (string.isNotBlank(userObj.ContactId)) {
      system.debug('userObj linked ContactId = ' + userObj.ContactId);
      return UserAccountManagementRepository.fetchContactById(
        userObj.ContactId
      );
    } else {
      throw new customException('Employee is not linked to any contact');
    }
  }
}
