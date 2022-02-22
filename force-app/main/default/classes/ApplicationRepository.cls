/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description Repository to fetch application object
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual inherited sharing class ApplicationRepository extends DatabaseUtils {
  /**
   * @description Read Application with child record
   * Applicants contains only ids
   * Financial Account contains only Ids
   * @author Digital Align Team | 10-26-2021
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationWithChild(Id applicationId) {
    Query qry = Query.newInstance(Account.SObjectType)
      .addFields()
      .queryChild('mflow__Applicants__r')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__FinancialAccounts__r')
      .run()
      .whereEq('Id', applicationId);
    return (Account) DatabaseUtils.getRecord(qry.toString());
  }

  /**
   * @description Read Application with child record using application Name
   * Applicants contains only ids
   * Financial Account contains only Ids
   * @author Digital Align | 12-01-2021
   * @param string applicationNumber
   * @return Account
   **/
  global static Account readApplicationByApplicationNumber(
    String applicationNumber
  ) {
    return (Account) DatabaseUtils.getRecord(
      Query.newInstance(Account.SObjectType)
        .addFields()
        .removeFields('mflow__SessionToken__c')
        .whereEq('Name', applicationNumber)
        .toString()
    );
  }

  /**
   * @description Read Application child with specified application Id And applicant Id
   * @author Digital Align Team | 11-19-2021
   * @param Id applicationId
   * @param Id applicantId
   * @return Account
   **/
  global static Account readApplicationWithChild(
    Id applicationId,
    Id applicantId
  ) {
    Query qry = Query.newInstance(Account.SObjectType)
      .addFields()
      .removeFields('mflow__SessionToken__c')
      .queryChild('mflow__Applicants__r')
      .whereEq('Id', applicantId)
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__FinancialAccounts__r')
      .run()
      .whereEq('Id', applicationId);
    return (Account) DatabaseUtils.getRecord(qry.toString());
  }

  /**
   * @description Read Application for session token verification
   * @author Digital Align Team | 11-17-2021
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationForToken(Id applicationId) {
    return (Account) DatabaseUtils.getRecord(
      Query.newInstance(Account.SObjectType)
        .addFields('SessionToken__c,Name')
        .whereEq('Id', applicationId)
        .toString()
    );
  }

  /**
   * @description Read application with Applicants
   * @author Digital Align Team | 11-15-2021
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationWithApplicants(Id applicationId) {
    return (Account) DatabaseUtils.getRecord(
      Query.newInstance(Account.SObjectType)
        .addFields()
        .queryChild('mflow__Applicants__r')
        .addFields()
        .addFields('RecordType.Name')
        .orderBy('mflow__Order__c')
        .run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }

  /**
   * @description Read Site setting
   * @author Digital Align Team | 11-22-2021
   * @return SiteSetting__c
   **/
  global static SiteSetting__c readSiteSetting() {
    return (SiteSetting__c) DatabaseUtils.getRecord(
      Query.newInstance(SiteSetting__c.SObjectType)
        .addFields()
        .removeFields(
          'mflow__OnlineSiteUserName__c,mflow__OnlineSitePassword__c'
        )
        .toString()
    );
  }

  /**
   * @description get auth provider is existing or not
   * @author Digital Align Team | 12-08-2021
   * @param String developerName
   * @return AuthProvider
   **/
  global static AuthProvider readAuthProviderByDevName(String developerName) {
    return (AuthProvider) DatabaseUtils.getRecord(
      Query.newInstance(AuthProvider.SObjectType)
        .whereEq('DeveloperName', developerName)
        .toString()
    );
  }

  /**
   * @description Read Application with FinancialAccount and Applicants
   * @author Digital Align Team | 12-02-2021
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationForKYC(Id applicationId) {
    return (Account) DatabaseUtils.getRecord(
      Query.newInstance(Account.SObjectType)
        .addFields()
        .queryChild('mflow__Applicants__r')
        .addFields()
        .addFields('RecordType.Name')
        .whereEq(
          'RecordType.Name',
          ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
        )
        .orCon()
        .whereEq(
          'RecordType.Name',
          ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
        )
        .orderBy('mflow__Order__c')
        .run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }

  /**
   * @description Read Application With Primary
   * @author Digital Align Team | 02-04-2022
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationWithPrimary(Id applicationId) {
    return (Account) DatabaseUtils.getRecord(
      Query.newInstance(Account.SObjectType)
        .addFields()
        .queryChild('mflow__Applicants__r')
        .addFields()
        .addFields('RecordType.Name')
        .whereEq(
          'RecordType.Name',
          ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
        )
        .run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }
}
