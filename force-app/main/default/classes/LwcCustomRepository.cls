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
    'mflow__DeleteRecord__c',
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
      .toString();
    return (List<Flow__c>) getRecords(q);
  }

  /**
   * @description fetch application details
   * @author Digital Align Team | 12-01-2021
   * @param Id applicationId
   * @return Account
   **/
  global static Account readApplicationWithChild(Id applicationId) {
    return (Account) DatabaseUtils.getRecord(
      new Query(Account.SObjectType)
        //.addFieldSet('mflow__Application')
        .addFields()
        .addFields('CreatedBy.Name,LastModifiedBy.Name')
        .removeFields('mflow__SessionToken__c')
        .removeFields(removeFields)
        .queryChild('mflow__Applicants__r')
        .orderBy('mflow__Order__c')
        .run()
        .queryChild('FinServ__HouseholdFinancialAccounts__r')
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
  public static List<Applicant__c> readApplicantsWithChild(
    Set<Id> applicantIds
  ) {
    return (List<Applicant__c>) DatabaseUtils.getRecords(
      new Query(Applicant__c.SObjectType)
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
        .queryChild('mflow__ContactPointAddresses__r')
        .addFields()
        .addFields('CreatedBy.Name,LastModifiedBy.Name')
        .removeFields(removeFields)
        .removeFields('Address')
        .orderBy('mflow__Order__c')
        .run()
        .queryChild('mflow__Employments__r')
        .addFields()
        .addFields('CreatedBy.Name,LastModifiedBy.Name')
        .removeFields(removeFields)
        .orderBy('mflow__Order__c')
        .run()
        .queryChild('mflow__AssetsAndLiabilities__r')
        .addFields()
        .addFields('CreatedBy.Name,LastModifiedBy.Name')
        .removeFields(removeFields)
        .orderBy('mflow__Order__c')
        .run()
        .queryChild('mflow__Revenues__r')
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
   * @return List<FinServ__FinancialAccount__c>
   **/
  global static List<FinServ__FinancialAccount__c> readFinancialAccountsWithChild(
    Set<Id> financialAccountIds
  ) {
    return (List<FinServ__FinancialAccount__c>) DatabaseUtils.getRecords(
      new Query(FinServ__FinancialAccount__c.SObjectType)
        .addFields()
        .addFields('CreatedBy.Name,LastModifiedBy.Name')
        .removeFields(removeFields)
        .whereIn('Id', financialAccountIds)
        .toString()
    );
  }
}
