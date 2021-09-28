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
   * @description Create Dealer Business Account, which internal calls convertDealerLead,
   * updateDealerContact,updateDealerAccount and createDealerUser functionality
   * @author Digital Align Team | 07-13-2021
   * @param Map<String Object> params
   * @return Object
   **/
  global virtual Object createDealerBusinessUserAccount(
    Map<String, Object> params
  ) {
    Id leadId = (Id) params?.get('leadId');
    if (String.isBlank(leadId)) {
      throw new CustomException('Invalid LeadId');
    }

    //get the lead
    Lead leadObj = UserAccountManagementRepository.fetchLeadById(leadId);
    if (leadObj == null) {
      throw new CustomException('Lead Not Found');
    }

    UserAccountManagementRepository.upsertRecord(leadObj);

    Savepoint sp = Database.setSavepoint();
    try {
      //Convert lead into contact and account
      Database.LeadConvertResult convertDealerLead = convertDealerLead(leadObj);

      //Process Contact of the Lead
      Contact businessContactObj = this.updateDealerContact(
        leadObj,
        UserAccountManagementRepository.fetchContactAccountById(
          convertDealerLead.getContactId()
        )
      );

      //Process Account of the Lead
      Account accountObj = this.updateDealerAccount(
        leadObj,
        businessContactObj.Account
      );

      //Create an user for Lead on approval
      User userObj = this.createDealerUser(leadObj, businessContactObj);

      // link lead files to account
      return userObj;
    } catch (Exception ex) {
      Database.rollback(sp);
      system.debug(ex.getStackTraceString());
      throw new CustomException(ex, ex.getMessage());
    }
  }

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
   * @description update dealer Account detail which are not updated during lead conversion
   * @author Digital Align Team | 07-15-2021
   * @param Lead leadObj
   * @param Account businessAccountObj
   * @return Account
   **/
  global virtual Account updateDealerAccount(
    Lead leadObj,
    Account businessAccountObj
  ) {
    businessAccountObj.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
      Account.SObjectType,
      DealerConstants.DEALER_ADMIN_ACCOUNT_RECORDTYPE
    );
    businessAccountObj.AccountNumber = leadObj.AccountNumber__c;
    businessAccountObj.Dealership__c = leadObj.Dealership__c;
    businessAccountObj.FinancialInstitution__c = leadObj.FinancialInstitution__c;
    businessAccountObj.RoutingNumber__c = leadObj.RoutingNumber__c;
    businessAccountObj.RegistrationNumber__c = leadObj.RegistrationNumber__c;
    businessAccountObj.UserAccountType__c = DealerConstants.DEALER_ADMIN_ACOUNT_TYPE;
    businessAccountObj.Description = leadObj.Description;
    UserAccountManagementRepository.upsertRecord(businessAccountObj);
    return businessAccountObj;
  }

  /**
   * @description Create dealer user account and profile asssigned "DealerCommunity Profile"
   * @author Digital Align Team | 07-15-2021
   * @param Lead leadObj
   * @param Contact businessContactObj
   * @return virtual
   **/
  global virtual User createDealerUser(
    Lead leadObj,
    Contact businessContactObj
  ) {
    User userObj = new User();
    Long currentTimeStamp = System.currentTimeMillis();
    userObj = UserUtils.assignProfileIdToUser(
      userObj,
      UserAccountManagementRepository.readProfileByName(
          DealerConstants.DEALER_ADMIN_USER_PROFILE
        )
        ?.Id
    );
    userObj.ContactId = businessContactObj.Id;
    userObj.FirstName = businessContactObj.FirstName;
    userObj.LastName = businessContactObj.LastName;
    userObj.Email = businessContactObj.Email;
    userObj.Username = businessContactObj.Email + '.' + currentTimeStamp;
    userObj.CompanyName = businessContactObj.Title;
    userObj.Title = userObj.FirstName + userObj.LastName;
    userObj.Alias = userObj.FirstName?.left(4) + userObj.LastName.left(4);
    userObj.CommunityNickname =
      userObj.FirstName.left(4) +
      userObj.LastName.left(4) +
      currentTimeStamp;
    userObj.TimeZoneSidKey = 'America/Los_Angeles';
    userObj.EmailEncodingKey = 'ISO-8859-1';
    userObj.LocaleSidKey = 'en_US';
    userObj.LanguageLocaleKey = 'en_US';

    UserAccountManagementRepository.insertRecord(userObj);
    DealerAccountCreationService.assignCommunityPermissionSetAsync(userObj.Id);
    return userObj;
  }

  /**
   * @description assign permission set for user in future context (to Avoid mixed dml exception)
   * @author Digital Align Team | 07-14-2021
   * @param Id userId
   **/
  @future
  global static void assignCommunityPermissionSetAsync(Id userId) {
    DealerAccountCreationService.getInstance()
      .assignCommunityPermissionSet(userId);
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
   * @description Create Dealer Employee Business Account, which internal calls updateDealerEmployeeContact,
   * createDealerEmployeeUser functionality
   * @author Digital Align Team | 07-13-2021
   * @param Map<String Object> params
   * @return Object
   **/
  global virtual Object createDealerEmployeeUserAccount(
    Map<String, Object> params
  ) {
    Contact businessContactObj = (Contact) JSON.deserialize(
      JSON.serialize(params.get('contact')),
      Contact.class
    );

    system.debug('businessContactObj : ' + JSON.serialize(businessContactObj));

    if (businessContactObj == null) {
      throw new CustomException('Contact Record Not Found');
    }

    Savepoint sp = Database.setSavepoint();
    try {
      Account currentUserAccountObj = UserUtils.fetchUserAccountByUserId(
        UserInfo.getUserId()
      );
      //Process Contact
      businessContactObj = this.createDealerEmployeeContact(
        businessContactObj,
        currentUserAccountObj
      );

      system.debug('Contact Id : ' + businessContactObj.id);
      //Create an user for Contact on approval
      User userObj = this.createDealerEmployeeUser(
        businessContactObj,
        currentUserAccountObj
      );
      return userObj;
    } catch (Exception ex) {
      Database.rollback(sp);
      throw new CustomException(ex, ex.getMessage());
    }
  }

  /**
   * @description create contact for dealer employee
   * @author Digital Align Team | 07-15-2021
   * @param Contact businessContactObj
   * @return Contact
   **/
  global virtual Contact createDealerEmployeeContact(
    Contact businessContactObj,
    Account businessAccountObj
  ) {
    businessContactObj.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
      Contact.SobjectType,
      DealerConstants.DEALER_EMPLOYEE_CONTACT_RECORDTYPE
    );
    businessContactObj.AccountId = businessAccountObj?.id;
    businessContactObj.LeadSource = 'Partner Referral';
    businessContactObj.UserContactType__c = DealerConstants.DEALER_EMPLOYEE_CONTACT_TYPE;
    UserAccountManagementRepository.upsertRecord(businessContactObj);
    return businessContactObj;
  }

  /**
   * @description create employee user for an dealer
   * @author Digital Align Team | 07-15-2021
   * @param Contact businessContactObj
   * @return User
   **/
  global virtual User createDealerEmployeeUser(
    Contact businessContactObj,
    Account businessAccountObj
  ) {
    User userObj = new User();
    Long currentTimeStamp = System.currentTimeMillis();
    //special use case
    userObj = UserUtils.assignProfileIdToUser(
      userObj,
      UserAccountManagementRepository.readProfileByName(
          DealerConstants.DEALER_EMPLOYEE_USER_PROFILE
        )
        ?.Id
    );
    userObj.ContactId = businessContactObj.Id;
    userObj.FirstName = businessContactObj.FirstName;
    userObj.LastName = businessContactObj.LastName;
    userObj.Email = businessContactObj.Email;
    userObj.Username = businessContactObj.Email + '.' + currentTimeStamp;
    userObj.CompanyName = businessAccountObj.Name;
    userObj.Title = userObj.FirstName + userObj.LastName;
    userObj.Alias = userObj.FirstName?.left(4) + userObj.LastName.left(4);
    userObj.CommunityNickname = userObj.Alias + currentTimeStamp;
    userObj.MobilePhone = businessContactObj.MobilePhone;
    userObj.TimeZoneSidKey = 'America/Los_Angeles';
    userObj.EmailEncodingKey = 'ISO-8859-1';
    userObj.LocaleSidKey = 'en_US';
    userObj.LanguageLocaleKey = 'en_US';

    UserAccountManagementRepository.insertRecord(userObj);
    DealerAccountCreationService.assignCommunityPermissionSetAsync(userObj.Id);
    return userObj;
  }

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
