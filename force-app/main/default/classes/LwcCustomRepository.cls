/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class LwcCustomRepository extends DatabaseUtils {
  private static List<String> removeFields = new List<String>{
    'IsDeleted',
    'RecordTypeId',
    'LastViewedDate',
    'LastReferencedDate',
    'CreatedById',
    'LastActivityDate',
    'SystemModstamp',
    'LastModifiedById',
    'OwnerId'
  };

  /**
   * @description fetch existing flow from entity
   * @author Digital Align Team | 10-19-2021
   * @param String entityId
   * @return List<Flow__c>
   **/
  public static List<Flow__c> fetchFlowByEntityId(String entityId) {
    String q = Query.newInstance(Flow__c.SObjectType)
      .addFields()
      .queryChild('mflow__SubFlows__r')
      .addFields()
      .run()
      .whereEq('mflow__Entity__c', entityId)
      .andCon()
      .whereEq('RecordType.Name', 'Flow')
      .toString();
    return (List<Flow__c>) getRecords(q);
  }

  /**
   * @description fetch application details
   * @author Digital Align Team | 12-01-2021
   * @param Id applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationWithChild(Id applicationId) {
    return (Application__c) DatabaseUtils.getRecord(
      Query.newInstance(Application__c.SObjectType)
        //.addFieldSet('mflow__Application')
        .addFields()
        .addFields('CreatedBy.Name,LastModifiedBy.Name')
        .removeFields('mflow__SessionToken__c')
        .removeFields(removeFields)
        .queryChild('mflow__Applicants__r')
        .orderBy('mflow__Order__c')
        .run()
        .queryChild('mflow__FinancialAccounts__r')
        .run()
        .whereEq('Id', applicationId)
        .toString(true)
    );
  }

  /**
   * @description fetch applicant details
   * @author Digital Align Team | 12-01-2021
   * @param Set<Id> applicantIds
   * @return List<Applicant__c>
   **/
  public static List<Applicant__c> readApplicantsWithChild(Set<Id> applicantIds) {
    return (List<Applicant__c>) DatabaseUtils.getRecords(
      Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        .addFields('CreatedBy.Name,LastModifiedBy.Name')
        .removeFields('mflow__SessionToken__c')
        .removeFields(removeFields)
        .queryChild('mflow__IdentificationDocuments__r')
        .addFields()
        .addFields('CreatedBy.Name,LastModifiedBy.Name')
        .removeFields(removeFields)
        .orderBy('mflow__Order__c')
        .run()
        .queryChild('mflow__Addresses__r')
        .addFields()
        .addFields('CreatedBy.Name,LastModifiedBy.Name')
        .removeFields(removeFields)
        //.removeFields('Address')
        .orderBy('mflow__Order__c')
        .run()
        .queryChild('mflow__Employments__r')
        .addFields()
        .addFields('CreatedBy.Name,LastModifiedBy.Name')
        .removeFields(removeFields)
        .orderBy('mflow__Order__c')
        .run()
        .queryChild('mflow__AssetAndLiabilities__r')
        .addFields()
        .addFields('CreatedBy.Name,LastModifiedBy.Name')
        .removeFields(removeFields)
        .orderBy('mflow__Order__c')
        .run()
        .whereIn('Id', applicantIds)
        .toString()
    );
  }

  /**
   * @description fetch financial account detail
   * @author Digital Align Team | 12-01-2021
   * @param Set<Id> financialAccountIds
   * @return List<FinancialAccount__c>
   **/
  global static List<FinancialAccount__c> readFinancialAccountsWithChild(Set<Id> financialAccountIds) {
    return (List<FinancialAccount__c>) DatabaseUtils.getRecords(
      Query.newInstance(FinancialAccount__c.SObjectType)
        .addFields()
        .addFields('CreatedBy.Name,LastModifiedBy.Name')
        .removeFields(removeFields)
        .whereIn('Id', financialAccountIds)
        .toString()
    );
  }

  /**
   * @description Read applicant record
   * @author Digital Align Team | 11-16-2021
   * @param Id applicantId
   * @return Applicant__c
   **/
  global static Applicant__c readApplicantById(Id applicantId) {
    return (Applicant__c) DatabaseUtils.getRecord(
      Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        .addFields('RecordType.Name')
        .queryLookup('mflow__Application__r')
        .addFields('Name')
        .run()
        .whereEq('Id', applicantId)
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
   * @description  Read application with Applicants
   * @author Digital Align Team | 04-04-2022
   * @param Id recordId
   * @param String filter
   * @return Application__c
   **/
  global static Application__c readApplicationForResume(Id recordId, String filter) {
    Query qry = Query.newInstance(Application__c.SObjectType)
      .addFields()
      .queryChild('mflow__Applicants__r')
      .addFields()
      .addFields('RecordType.Name')
      .whereEq('RecordType.Name', ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE)
      .orCon()
      .whereEq('RecordType.Name', ApplicationConstant.APPLICANT_JOINT_RECORDTYPE)
      .orderBy('mflow__Order__c')
      .run()
      .whereEq('Id', recordId);
    if (String.isNotBlank(filter)) {
      qry.andCon().grpOpen().whereCon(filter).grpClose();
    }
    return (Application__c) getRecord(qry.toString());
  }

  /**
   * @description Read applicant record
   * @author Digital Align Team | 11-16-2021
   * @param Id applicantId
   * @return Applicant__c
   **/
  global static SObject readSObjectById(Id recordId, String sObjectName, String filter) {
    Query qry = Query.newInstance(SObjectUtils.getSobjectType(sObjectName)).addFields().whereEq('Id', recordId);
    if (String.isNotBlank(filter)) {
      qry.andCon().grpOpen().whereCon(filter).grpClose();
    }
    return getRecord(qry.toString());
  }
}
