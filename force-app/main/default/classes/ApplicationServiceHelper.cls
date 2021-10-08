/**
 * Copyright (c) 2021 Digital Align
 * @group Helper
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicationServiceHelper extends AbstractService {
  @TestVisible
  private static ApplicationServiceHelper serviceInstance;

  public ApplicationServiceHelper() {
    super(ApplicationServiceHelper.class);
  }

  /**
   * @description Provides a singleton instance of ApplicationServiceHelper from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static ApplicationServiceHelper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicationServiceHelper) getInstance(
        ApplicationServiceHelper.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align Team | 10-05-2021
   * @param Map<String Object> params
   * @return virtual
   **/
  global virtual Account createHouseholdApplication(
    Map<String, Object> params
  ) {
    // Create init Account Application
    Account applicationObj = new Account();
    applicationObj.Name = 'Init';
    applicationObj.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
      Account.SObjectType,
      ApplicationConstant.ACCOUNT_APPLICATION_RECORDTYPE
    );
    ApplicationRepository.upsertRecord(applicationObj);
    return applicationObj;
  }

  /**
   * @description
   * @author Digital Align Team | 10-05-2021
   * @param Map<String Object> params
   * @return virtual
   **/
  global virtual Account createPrimaryPersonAccount(
    Map<String, Object> params
  ) {
    // create person Account
    Account personAccountObj = new Account();
    //personAccountObj.FirstName = 'Test1';
    //personAccountObj.LastName = 'Test1';
    personAccountObj.RecordTypeId = SObjectUtils.recordTypeIdByDevName(
      Account.SObjectType,
      'PersonAccount'
    );
    ApplicationRepository.upsertRecord(personAccountObj);
    return personAccountObj;
  }

  /**
   * @description
   * @author Digital Align Team | 10-05-2021
   * @param Map<String Object> params
   * @param Account applicationObj
   * @param Account personAccountObj
   * @return virtual
   **/
  global virtual AccountContactRelation createAccountContactRelation(
    Map<String, Object> params,
    Account applicationObj,
    Account personAccountObj
  ) {
    //AccountContactRelation
    AccountContactRelation relationObj = new AccountContactRelation();
    relationObj.AccountId = applicationObj.Id;
    //relationObj.ContactId = personAccountObj.PersonContactId;
    relationObj.FinServ__Primary__c = true;
    relationObj.FinServ__PrimaryGroup__c = true;
    relationObj.FinServ__Rollups__c = 'All';
    relationObj.Roles = '	Business User';
    ApplicationRepository.upsertRecord(relationObj);
    return relationObj;
  }
}
