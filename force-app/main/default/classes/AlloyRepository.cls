/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
global with sharing class AlloyRepository extends DatabaseUtils {
  /**
   * @description read  applicant with child record
   * @author Digital Align Team | 10-26-2021
   * @param Applicant__c applicantId
   **/
  global static Applicant__c readApplicantWithChild(Id applicantId) {
    Query qry = Query.newInstance(Applicant__c.SObjectType)
      .addFields()
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
      .whereEq('Id', applicantId);
    return (Applicant__c) DatabaseUtils.getRecord(qry.toString());
  }
}
