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
      new Query(Applicant__c.SObjectType)
        .addFields()
        .queryChild('dau01__IdentificationDocuments__r')
        .addFields()
        .orderBy('dau01__Order__c')
        .run()
        .queryChild('dau01__ContactPointAddresses__r')
        .addFields()
        .removeFields('Address')
        .orderBy('dau01__Order__c')
        .run()
        .queryChild('dau01__Employments__r')
        .addFields()
        .orderBy('dau01__Order__c')
        .run()
        .queryChild('dau01__AssetsAndLiabilities__r')
        .addFields()
        .orderBy('dau01__Order__c')
        .run()
        .queryChild('dau01__Revenues__r')
        .addFields()
        .orderBy('dau01__Order__c')
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
      new Query(Applicant__c.SObjectType)
        .addFields()
        .queryChild('dau01__IdentificationDocuments__r')
        .addFields()
        .orderBy('dau01__Order__c')
        .run()
        .queryChild('dau01__ContactPointAddresses__r')
        .addFields()
        .removeFields('Address')
        .orderBy('dau01__Order__c')
        .run()
        .queryChild('dau01__Employments__r')
        .addFields()
        .orderBy('dau01__Order__c')
        .run()
        .queryChild('dau01__AssetsAndLiabilities__r')
        .addFields()
        .orderBy('dau01__Order__c')
        .run()
        .queryChild('dau01__Revenues__r')
        .addFields()
        .orderBy('dau01__Order__c')
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
      new Query(Applicant__c.SObjectType)
        .addFields()
        .addFields('RecordType.Name')
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
      new Query(Applicant__c.SObjectType)
        .addFields(
          'SessionToken__c,Application__r.ApplicationNumber__c,Application__c'
        )
        .whereEq('Id', applicantId)
        .toString()
    );
  }
}
