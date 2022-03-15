/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description Repository to collect application/ funding data which is then used by RPA
 **/ @SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual inherited sharing class SubmissionRepository extends DatabaseUtils {
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
        .queryChild('mflow__Applicants__r')
        .orderBy('mflow__Order__c')
        .run()
        .queryChild('mflow__FinancialAccounts__r')
        .run()
        .queryChild('mflow__Surveys__r')
        .addFields()
        .whereNull('Applicant__c')
        .orderBy('Order__c')
        .run()
        .whereEq('Name', applicationNumber)
        .toString()
    );
  }

  /**
   * @description Read Application with child record
   * Applicants contains only ids
   * Financial Application__c contains only Ids
   * @author Digital Align Team | 10-26-2021
   * @param Id applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationWithChild(Id applicationId) {
    String eventIdentifier = String.valueOf(ApexRequest.getParams('eventIdentifier'));

    Query qry = Query.newInstance(Application__c.SObjectType)
      .addFields()
      .queryChild('mflow__Applicants__r')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__FinancialAccounts__r')
      .run()
      .queryChild('mflow__Surveys__r')
      .addFields()
      .whereNull('Applicant__c')
      .orderBy('Order__c')
      .run()
      .whereEq('Id', applicationId);

    return (Application__c) DatabaseUtils.getRecord(qry.toString());
  }

  /**
   * @description read financial account with child by ids
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> financialAccountIds
   * @return List<FinancialAccount__c>
   **/
  global static List<FinancialAccount__c> readFinancialAccountsWithChild(Set<Id> financialAccountIds) {
    return (List<FinancialAccount__c>) DatabaseUtils.getRecords(
      Query.newInstance(FinancialAccount__c.SObjectType)
        .addFields()
        .queryLookup('mflow__FinancialProduct__r')
        .addFields()
        .run()
        .queryChild('mflow__FinancialAccountTransactions__r')
        .addFields()
        .run()
        // .queryChild('mflow__FinancialAccountServices__r')
        // .addFields()
        // .run()
        .whereIn('Id', financialAccountIds)
        .toString()
    );
  }

  /**
   * @description read allapplicant with child record
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> applicantIds
   **/
  global static List<Applicant__c> readApplicantsWithChild(Set<Id> applicantIds) {
    Query qry = Query.newInstance(Applicant__c.SObjectType)
      .addFields()
      .addFields('RecordType.Name')
      .queryChild('mflow__IdentificationDocuments__r')
      .addFields()
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__ContactPointAddresses__r')
      .addFields()
      .removeFields('Address')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__Employments__r')
      .addFields()
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__Surveys__r')
      .addFields()
      .orderBy('Order__c')
      .run()
      .whereIn('Id', applicantIds);
    return (List<Applicant__c>) DatabaseUtils.getRecords(qry.toString());
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
   * @description Read Application For Funding Process
   * @author Digital Align Team | 03-15-2022
   * @param Id applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationForFundingProcess(Id applicationId) {
    return (Application__c) DatabaseUtils.getRecord(
      Query.newInstance(Application__c.SObjectType)
        .addFields()
        .queryChild('mflow__FinancialAccounts__r')
        .addFields()
        .run()
        .queryChild('mflow__Applicants__r')
        .addFields()
        .addFields('RecordType.Name')
        .orderBy('mflow__Order__c')
        .run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }
}
