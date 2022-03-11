/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class FinInstAccountService extends AbstractService {
  @TestVisible
  private static FinInstAccountService serviceInstance;

  public FinInstAccountService() {
    super(FinInstAccountService.class);
  }

  /**
   * @description Provides a singleton instance of FinInstAccountService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static FinInstAccountService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (FinInstAccountService) getInstance(FinInstAccountService.class);
    }
    return serviceInstance;
  }

  //************ FinInstSite Business Account Creation ****************/

  /**
   * @description fetch Financial Institute Account
   * @author Digital Align Team | 07-27-2021
   * @return Account
   **/
  global virtual Account fetchFinancialInstituteAccount() {
    ApplicationConfiguration__c appConfig = ApplicationConfiguration__c.getOrgDefaults();
    String accountId = appConfig?.FinancialInstituteAccountId__c;

    return (accountId == null) ? null : FinancialInstituteSiteRepository.fetchAccountById(accountId);
  }

  /**
   * @description create Financial Institute Account
   * @author Digital Align Team | 07-27-2021
   * @param Map<String Object> params
   * @return virtual
   **/
  global virtual Account createFinancialInstituteAccount(Map<String, Object> params) {
    Account accountRecord = (Account) JSON.deserialize(JSON.serialize(params.get('account')), Account.class);

    if (accountRecord == null) {
      throw new CustomException(System.Label.FinInst_AccountRecordRecordNotFound);
    }

    accountRecord.UserAccountType__c = FinancialInstituteConstants.FIN_INST_ACOUNT_TYPE;
    FinancialInstituteSiteRepository.upsertRecord(accountRecord);
    ApplicationConfiguration__c ap = ApplicationConfiguration__c.getOrgDefaults();
    if (ap.FinancialInstituteAccountId__c == null) {
      ap.FinancialInstituteAccountId__c = accountRecord.id;
      FinancialInstituteSiteRepository.upsertRecord(ap);
    }
    return accountRecord;
  }

  //************ FinInstSite Employee Account Creation  ****************/

  global virtual object createFinInstEmployeeUserAccount(Map<String, Object> params) {
    Contact employeeContactObj = (Contact) JSON.deserialize(JSON.serialize(params.get('contact')), Contact.class);
    system.debug('employeeContactObj : ' + JSON.serialize(employeeContactObj));

    if (employeeContactObj == null) {
      throw new CustomException(System.Label.FinInst_ContactRecordNotFound);
    }

    Savepoint sp = Database.setSavepoint();
    try {
      Account businessAccountObj = this.fetchFinancialInstituteAccount();

      if (businessAccountObj == null) {
        throw new CustomException(System.Label.FinInst_BusinessAccountHasNotSetup);
      }
      //Process Contact
      employeeContactObj = this.createFinInstEmployeeContact(employeeContactObj, businessAccountObj);

      system.debug('Contact Id : ' + employeeContactObj.id);
      //Create an user for Contact on approval
      User userObj = this.createFinInstEmployeeUser(employeeContactObj, businessAccountObj);
      //yet to done assigning permission set
      return userObj;
    } catch (Exception ex) {
      Database.rollback(sp);
      throw new CustomException(ex, ex.getMessage());
    }
  }

  /**
   * @description create contact for FinInst employee
   * @author Digital Align Team | 07-15-2021
   * @param Contact employeeContactObj
   * @return Contact
   **/
  global virtual Contact createFinInstEmployeeContact(Contact employeeContactObj, Account businessAccountObj) {
    employeeContactObj.AccountId = businessAccountObj?.id;
    employeeContactObj.LeadSource = 'Partner Referral';
    employeeContactObj.UserContactType__c = FinancialInstituteConstants.FIN_INST_EMPLOYEE_CONTACT_TYPE;
    UserAccountManagementRepository.upsertRecord(employeeContactObj);
    return employeeContactObj;
  }

  /**
   * @description create employee user for an FinInst
   * @author Digital Align Team | 07-15-2021
   * @param Contact employeeContactObj
   * @return User
   **/
  global virtual User createFinInstEmployeeUser(Contact employeeContactObj, Account businessAccountObj) {
    User userObj = new User();
    Long currentTimeStamp = System.currentTimeMillis();
    //special use case
    userObj = UserUtils.assignProfileIdToUser(
      userObj,
      UserAccountManagementRepository.readProfileByName(FinancialInstituteConstants.FIN_INST_EMPLOYEE_USER_PROFILE)?.Id
    );
    userObj.ContactId = employeeContactObj.Id;
    userObj.FirstName = employeeContactObj.FirstName;
    userObj.LastName = employeeContactObj.LastName;
    userObj.Email = employeeContactObj.Email;
    userObj.Username = employeeContactObj.Email + '.' + currentTimeStamp;
    userObj.CompanyName = businessAccountObj.Name;
    userObj.Title = userObj.FirstName + userObj.LastName;
    userObj.Alias = userObj.FirstName?.left(4) + userObj.LastName.left(4);
    userObj.CommunityNickname = userObj.Alias + currentTimeStamp;
    userObj.MobilePhone = employeeContactObj.MobilePhone;
    userObj.TimeZoneSidKey = 'America/Los_Angeles';
    userObj.EmailEncodingKey = 'ISO-8859-1';
    userObj.LocaleSidKey = 'en_US';
    userObj.LanguageLocaleKey = 'en_US';

    UserAccountManagementRepository.insertRecord(userObj);
    FinInstAccountService.assignCommunityPermissionSetAsync(userObj.Id);
    return userObj;
  }

  /**
   * @description assign permission set for user in future context (to Avoid mixed dml exception)
   * @author Digital Align Team | 07-14-2021
   * @param Id userId
   **/
  @future
  global static void assignCommunityPermissionSetAsync(Id userId) {
    FinInstAccountService.getInstance().assignCommunityPermissionSet(userId);
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
    List<PermissionSet> permissionSetList = UserAccountManagementRepository.readPermissionSetByNames(
      new List<String>{ FinancialInstituteConstants.FIN_INST_COMMUNITY_PEMRISSION_SET }
    );

    List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment>();
    for (PermissionSet ps : permissionSetList) {
      permissionSetAssignmentList.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = userId));
    }
    UserAccountManagementRepository.insertRecords(permissionSetAssignmentList);
    return permissionSetAssignmentList;
  }
}
