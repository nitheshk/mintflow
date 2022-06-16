/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description The repository class to handle all customer portal related queries.
 **/
global with sharing class CustomerPortalRepository extends DatabaseUtils {
  /**
   * @description
   * @author Digital Align Team | 02-11-2022
   * @param String lastFourDigitofSSN
   * @param string email
   * @param string lastName
   * @return List<Application__c>
   **/
  global static List<Application__c> fetchApplicationByApplicantDetails(
    String lastFourDigitofSSN,
    string email,
    string lastName
  ) {
    return (List<Application__c>) DatabaseUtils.getRecords(
      Query.newInstance(Application__c.SObjectType)
        .addFields()
        .queryChild('mflow__Applicants__r')
        .addFields()
        .addFields('RecordType.Name')
        .whereEq('RecordType.Name', ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE)
        .orCon()
        .whereEq('RecordType.Name', ApplicationConstant.APPLICANT_JOINT_RECORDTYPE)
        .orderBy('mflow__Order__c')
        .run()
        .whereIn(
          'Id',
          Query.newInstance(Applicant__c.SObjectType)
            .addFields('mflow__Application__c')
            .whereEq('mflow__LastFourDigitsofSSN__c', lastFourDigitofSSN)
            .AndCon()
            .whereEq('mflow__Email__c', email)
            .AndCon()
            .whereEq('mflow__LastName__c', lastName)
            .toString()
        )
        .toString(true)
    );
  }

  /**
   * @description
   * @author Digital Align Team | 06-09-2022
   * @param Applicant__c applicant
   * @return List<Application__c>
   **/
  global static List<Application__c> readMyApplication(Applicant__c applicant) {
    return (List<Application__c>) DatabaseUtils.getRecords(
      Query.newInstance(Application__c.SObjectType)
        .addFields(
          'mflow__CreatedChannel__c,mflow__Status__c,mflow__FlowState__c,mflow__ApplicationType__c,Name,CreatedDate,LastModifiedDate'
        )
        .whereIn(
          'Id',
          Query.newInstance(Applicant__c.SObjectType)
            .addFields('mflow__Application__c')
            .whereEq('mflow__SSN__c', applicant.mflow__SSN__c)
            .AndCon()
            .whereEq('mflow__Email__c', applicant.mflow__Email__c)
            .AndCon()
            .whereEq('mflow__LastName__c', applicant.mflow__LastName__c)
            .andCon()
            .whereEq('RecordType.Name', ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE)
            .andCon()
            .whereEq('mflow__IsEmailVerified__c', true)
            .toString()
        )
        .orderBy('CreatedDate', true)
        .addLimit(2000)
        .toString(true)
    );
  }

  /**
   * @description Read Application with child record
   * Applicants contains only ids
   * Financial Application__c contains only Ids
   * @author Digital Align Team | 06-10-2022
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
      .queryChild('mflow__DocumentRequests__r')
      .addFields()
      .run()
      .whereEq('Id', applicationId);
    return (Application__c) DatabaseUtils.getRecord(qry.toString());
  }

  /**
   * @description read allapplicant with child record
   * @author Digital Align Team | 06-10-2022
   * @param Set<Id> applicantIds
   **/
  global static List<Applicant__c> readApplicantsWithChild(Set<Id> applicantIds) {
    Query qry = Query.newInstance(Applicant__c.SObjectType)
      .addFields()
      .addFields('RecordType.Name')
      .removeFields('mflow__SessionToken__c')
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
      .whereIn('Id', applicantIds);
    return (List<Applicant__c>) DatabaseUtils.getRecords(qry.toString());
  }

  /**
   * @description read financial account with child by ids
   * @author Digital Align Team | 06-10-2022
   * @param Set<Id> financialAccountIds
   * @return List<FinancialAccount__c>
   **/
  global static List<FinancialAccount__c> readFinancialAccountsWithChild(Set<Id> financialAccountIds) {
    return (List<FinancialAccount__c>) DatabaseUtils.getRecords(
      Query.newInstance(FinancialAccount__c.SObjectType)
        .addFields()
        .queryLookUp('mflow__FinancialProduct__r')
        .addFields()
        .run()
        .queryChild('mflow__FinancialAccountTransactions__r')
        .addFields()
        .run()
        .queryChild('mflow__FinancialAccountServices__r')
        .addFields()
        .run()
        .whereIn('Id', financialAccountIds)
        .toString()
    );
  }

  /**
   * @description
   * @author Digital Align Team | 06-16-2022
   * @param Id applicationId
   * @return Applicant__c
   **/
  global static Applicant__c readPrimaryApplicant(Id applicationId) {
    return (Applicant__c) DatabaseUtils.getRecord(
      Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        .addFields('RecordType.Name')
        .whereEq('RecordType.Name', ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE)
        .andCon()
        .whereEq('Application__c', applicationId)
        .toString()
    );
  }

  /**
   * @description
   * @author Digital Align Team | 06-16-2022
   * @param Id applicationId
   * @param Id applicantId
   * @return Applicant__c
   **/
  global static Applicant__c readApplicantById(Id applicationId, Id applicantId) {
    return (Applicant__c) DatabaseUtils.getRecord(
      Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        .addFields('RecordType.Name')
        .whereEq('Application__c', applicationId)
        .andCon()
        .whereEq('Id', applicantId)
        .toString()
    );
  }
}
