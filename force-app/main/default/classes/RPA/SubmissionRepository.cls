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
   * @return Account
   **/
  global static Account readApplicationByApplicationNumber(
    String applicationNumber
  ) {
    return (Account) DatabaseUtils.getRecord(
      Query.newInstance(Account.SObjectType)
        //.addFieldSet('mflow__Application')
        .addFields()
        .queryChild('mflow__Applicants__r')
        .addFields()
        .orderBy('mflow__Order__c')
        .run()
        .removeFields('mflow__SessionToken__c')
        .whereEq('mflow__ApplicationNumber__c', applicationNumber)
        .toString()
    );
  }

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
   * @description read allapplicant with child record
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> applicantIds
   **/
  global static List<Applicant__c> readApplicantsWithChild(
    Set<Id> applicantIds
  ) {
    String eventIdentifier = String.valueOf(
      ApexRequest.getParams('eventIdentifier')
    );

    Query qry = Query.newInstance(Applicant__c.SObjectType)
      .addFields()
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
      .queryChild('mflow__Surveys__r')
      .addFields()
      .orderBy('Order__c')
      .run();
    if (String.isNotBlank(eventIdentifier)) {
      qry
        .queryChild('mflow__ApplicantConsents__r')
        .addFields()
        .queryLookup('mflow__ConsentTemplate__r')
        .addFields()
        .run()
        .whereEq('mflow__EventIdentifier__c', eventIdentifier)
        .orderBy('mflow__Order__c')
        .run();
    } else {
      qry
        .queryChild('mflow__ApplicantConsents__r')
        .addFields()
        .queryLookup('mflow__ConsentTemplate__r')
        .addFields()
        .run()
        .orderBy('mflow__Order__c')
        .run();
    }
    qry.whereIn('Id', applicantIds);

    return (List<Applicant__c>) DatabaseUtils.getRecords(qry.toString());
  }
  /**
   * @description read financial account with child by Applicatiom Id
   * @author Digital Align | 01-10-2022
   * @param Id financialAccountId
   * @return List<FinServ__FinancialAccount__c>
   **/
  global static List<FinServ__FinancialAccount__c> readFinancialAccountWithChildByApplicationId(
    string applicationId
  ) {
    return (List<FinServ__FinancialAccount__c>) DatabaseUtils.getRecords(
      Query.newInstance(FinServ__FinancialAccount__c.SObjectType)
        .addFields()
        .queryChild('FinServ__FinancialAccountTranslations__r')
        .addFields()
        .run()
        .whereEq('mflow__Application__c', applicationId)
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
}
