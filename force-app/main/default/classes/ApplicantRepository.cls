/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class ApplicantRepository extends DatabaseUtils {
  /**
   * @description read allapplicant with child record
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> applicantIds
   **/
  public static List<Applicant__c> readApplicantsWithChild(
    Set<Id> applicantIds
  ) {
    return (List<Applicant__c>) DatabaseUtils.getRecords(
      Query.newInstance(Applicant__c.SObjectType)
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
        /*.queryChild('mflow__AssetsAndLiabilities__r')
        .addFields()
        .orderBy('mflow__Order__c')
        .run()*/
        .queryChild('mflow__Revenues__r')
        .addFields()
        .orderBy('mflow__Order__c')
        .run()
        .whereIn('Id', applicantIds)
        .toString()
    );
  }

  /**
   * @description read  applicant with child record
   * @author Digital Align Team | 10-26-2021
   * @param Applicant__c applicantId
   **/
  public static Applicant__c readApplicantWithChild(Id applicantId) {
    return (Applicant__c) DatabaseUtils.getRecord(
      Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        // Session Token Required As joint is using it
        //.removeFields('mflow__SessionToken__c')
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
        /*.queryChild('mflow__AssetsAndLiabilities__r')
        .addFields()
        .orderBy('mflow__Order__c')
        .run()*/
        .queryChild('mflow__Revenues__r')
        .addFields()
        .orderBy('mflow__Order__c')
        .run()
        .whereEq('Id', applicantId)
        .toString()
    );
  }

  /**
   * @description Read applicant record
   * @author Digital Align Team | 11-16-2021
   * @param Id applicantId
   * @return Applicant__c
   **/
  public static Applicant__c readApplicantById(Id applicantId) {
    return (Applicant__c) DatabaseUtils.getRecord(
      Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        .addFields('RecordType.Name')
        .whereEq('Id', applicantId)
        .toString()
    );
  }
  /**
   * @description Read list of applicant record
   * @author Digital Align | 12-10-2021
   * @param List<Id> applicantIds
   * @return List<Applicant__c>
   **/
  public static List<Applicant__c> readApplicantsById(List<Id> applicantIds) {
    return (List<Applicant__c>) DatabaseUtils.getRecords(
      Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        .whereIn('Id', applicantIds)
        .toString()
    );
  }

  /**
   * @description read applicant with application details
   * @author Digital Align Team | 11-18-2021
   * @param Id applicantId
   * @return Applicant__c
   **/
  public static Applicant__c readApplicantWithApplication(Id applicantId) {
    return (Applicant__c) DatabaseUtils.getRecord(
      Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        .addFields('RecordType.Name')
        .queryLookup('mflow__Application__r')
        .addFields()
        .run()
        .whereEq('Id', applicantId)
        .toString()
    );
  }

  /**
   * @description Read Applicant For session Token
   * @author Digital Align Team | 11-17-2021
   * @param Id applicantId
   * @return Applicant__c
   **/
  public static Applicant__c readApplicantForToken(Id applicantId) {
    return (Applicant__c) DatabaseUtils.getRecord(
      Query.newInstance(Applicant__c.SObjectType)
        .addFields(
          'SessionToken__c,Application__r.ApplicationNumber__c,Application__c'
        )
        .whereEq('Id', applicantId)
        .toString()
    );
  }
}
