/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description Repository to fetch application object
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class ApplicationRepository extends DatabaseUtils {
  /**
   * @description Read Application with child record
   * Applicants contains only ids
   * Financial Application__c contains only Ids
   * @author Digital Align Team | 10-26-2021
   * @param Id applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationWithChild(Id applicationId) {
    Query qry = Query.newInstance(Application__c.SObjectType)
      .addFields()
      .queryChild('mflow__Applicants__r')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__FinancialAccounts__r')
      .run()
      .whereEq('Id', applicationId);
    return (Application__c) DatabaseUtils.getRecord(qry.toString());
  }

  /**
   * @description Read Application with child record using application Name
   * Applicants contains only ids
   * Financial Account contains only Ids
   * @author Digital Align | 12-01-2021
   * @param string applicationNumber
   * @return Application__c
   **/
  global static Application__c readApplicationByApplicationNumber(String applicationNumber) {
    return (Application__c) DatabaseUtils.getRecord(
      Query.newInstance(Application__c.SObjectType)
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
   * @return Application__c
   **/
  global static Application__c readApplicationWithChild(Id applicationId, Id applicantId) {
    Query qry = Query.newInstance(Application__c.SObjectType)
      .addFields()
      .removeFields('mflow__SessionToken__c')
      .queryChild('mflow__Applicants__r')
      .whereEq('Id', applicantId)
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__FinancialAccounts__r')
      .run()
      .whereEq('Id', applicationId);
    return (Application__c) DatabaseUtils.getRecord(qry.toString());
  }

  /**
   * @description Read Application for session token verification
   * @author Digital Align Team | 11-17-2021
   * @param Id applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationForToken(Id applicationId) {
    return (Application__c) DatabaseUtils.getRecord(
      Query.newInstance(Application__c.SObjectType)
        .addFields('SessionToken__c,Name')
        .whereEq('Id', applicationId)
        .toString()
    );
  }

  /**
   * @description Read application with Applicants
   * @author Digital Align Team | 11-15-2021
   * @param Id applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationWithApplicants(Id applicationId) {
    return (Application__c) DatabaseUtils.getRecord(
      Query.newInstance(Application__c.SObjectType)
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
   * @description get auth provider is existing or not
   * @author Digital Align Team | 12-08-2021
   * @param String developerName
   * @return AuthProvider
   **/
  global static AuthProvider readAuthProviderByDevName(String developerName) {
    return (AuthProvider) DatabaseUtils.getRecord(
      Query.newInstance(AuthProvider.SObjectType).whereEq('DeveloperName', developerName).toString()
    );
  }

  /**
   * @description Read Application With Primary
   * @author Digital Align Team | 02-04-2022
   * @param Id applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationWithPrimary(Id applicationId) {
    return (Application__c) DatabaseUtils.getRecord(
      Query.newInstance(Application__c.SObjectType)
        .addFields()
        .queryChild('mflow__Applicants__r')
        .addFields()
        .addFields('RecordType.Name')
        .whereEq('RecordType.Name', ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE)
        .run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }
  /**
   * @description Read Application with child record
   * Applicants contains only ids
   * Financial Account contains only Ids
   * @author Digital Align Team | 10-26-2021
   * @param String applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationToClone(String applicationName) {
    Query qry = Query.newInstance(Application__c.SObjectType)
      .addFieldSet('mflow__CloneApplication')
      .whereEq('Name', applicationName);
    return (Application__c) DatabaseUtils.getRecord(qry.toString());
  }

  /**
   * @description read  applicant with child record
   * @author Digital Align Team | 10-26-2021
   * @param Applicant__c applicantId
   **/
  global static List<Applicant__c> readApplicantsToClone(Id applicationId) {
    Query qry = Query.newInstance(Applicant__c.SObjectType)
      .addFieldSet('mflow__CloneApplicant')
      .addFields('RecordType.Name')
      .queryChild('mflow__IdentificationDocuments__r')
      .addFieldSet('mflow__CloneIdentification')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__ContactPointAddresses__r')
      .addFieldSet('mflow__CloneAddress')
      .removeFields('Address')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__Employments__r')
      .addFieldSet('mflow__CloneEmployment')
      .orderBy('mflow__Order__c')
      .run()
      .whereEq('Application__c', applicationId)
      .andCon()
      .whereNeq('RecordType.Name', ApplicationConstant.APPLICANT_FAMILY_MEMBER_RECORDTYPE);
    return (List<Applicant__c>) DatabaseUtils.getRecords(qry.toString());
  }

  global static List<LeadConfiguration__c> fetchLeadConfiguration(Map<String, String> filterValue) {
    Query qry = Query.newInstance(LeadConfiguration__c.SObjectType)
      .addFields()
      .whereEq('Type__c', filterValue.get('Type'));
    if (filterValue.get('Value') != null) {
      qry.andCon().whereEq('Value__c', filterValue.get('Value'));
    }
    if (filterValue.containsKey('Category')) {
      qry.andCon().whereEq('ProductCategory__c', filterValue.get('Category'));
    }
    system.debug('query::' + qry.tostring());
    return (List<LeadConfiguration__c>) DatabaseUtils.getRecords(qry.toString());
  }
}
