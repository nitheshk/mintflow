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
    String eventIdentifier = String.valueOf(
      ApexRequest.getParams('eventIdentifier')
    );

    Query qry = Query.newInstance(Account.SObjectType)
      //.addFieldSet('mflow__Application')
      .addFields()
      //.removeFields('mflow__SessionToken__c')
      .queryChild('mflow__Applicants__r')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__FinancialAccounts__r')
      .run();

    if (String.isNotBlank(eventIdentifier)) {
      qry
        .queryChild('mflow__ApplicationConsents__r')
        .addFields()
        .queryLookup('mflow__ConsentTemplate__r')
        .addFields()
        .run()
        .whereEq('mflow__EventIdentifier__c', eventIdentifier)
        .andCon()
        .whereNull('mflow__Applicant__c')
        .orderBy('mflow__Order__c')
        .run();
    } else {
      qry
        .queryChild('mflow__ApplicationConsents__r')
        .addFields()
        .queryLookup('mflow__ConsentTemplate__r')
        .addFields()
        .run()
        .whereNull('mflow__Applicant__c')
        .orderBy('mflow__Order__c')
        .run();
    }

    qry.queryChild('mflow__Surveys__r')
      .addFields()
      .whereNull('Applicant__c')
      .orderBy('Order__c')
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
        //.addFieldSet('mflow__Application')
        .addFields()
        .removeFields('mflow__SessionToken__c')
        .whereEq('mflow__ApplicationNumber__c', applicationNumber)
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
    String eventIdentifier = String.valueOf(
      ApexRequest.getParams('eventIdentifier')
    );

    Query qry = Query.newInstance(Account.SObjectType)
      //.addFieldSet('mflow__Application')
      .addFields()
      .removeFields('mflow__SessionToken__c')
      //#minor Check Applicants is required
      .queryChild('mflow__Applicants__r')
      .whereEq('Id', applicantId)
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__FinancialAccounts__r')
      .run();
    if (String.isNotBlank(eventIdentifier)) {
      qry
        .queryChild('mflow__ApplicationConsents__r')
        .addFields()
        .queryLookup('mflow__ConsentTemplate__r')
        .addFields()
        .run()
        .whereEq('mflow__EventIdentifier__c', eventIdentifier)
        .andCon()
        .whereNull('mflow__Applicant__c')
        .orderBy('mflow__Order__c')
        .run();
    } else {
      qry
        .queryChild('mflow__ApplicationConsents__r')
        .addFields()
        .queryLookup('mflow__ConsentTemplate__r')
        .addFields()
        .run()
        .whereNull('mflow__Applicant__c')
        .orderBy('mflow__Order__c')
        .run();
    }
    qry.queryChild('mflow__Surveys__r')
      .addFields()
      .whereNull('Applicant__c')
      .orderBy('Order__c')
      .run()
      .whereEq('Id', applicationId);

    return (Account) DatabaseUtils.getRecord(qry.toString());
  }

  /**
   * @description Read Application
   * @author Digital Align Team | 11-10-2021
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationById(Id applicationId) {
    return (Account) DatabaseUtils.getRecord(
      Query.newInstance(Account.SObjectType)
        .addFields()
        .whereEq('Id', applicationId)
        .toString()
    );
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
        .addFields('SessionToken__c,ApplicationNumber__c')
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
        //.addFieldSet('mflow__Application')
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
        //.queryChild('mflow__FinancialAccounts__r')
        //.addFields()
        //.addFields('RecordType.Name')
        //.run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }
}
