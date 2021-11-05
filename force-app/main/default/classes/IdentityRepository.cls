/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class IdentityRepository extends DatabaseUtils {
  /**
   * @description
   * @author Digital Align Team | 11-01-2021
   * @param Id applicantId
   * @return Applicant__c
   **/
  public static Applicant__c readApplicantForIdentity(Id applicantId) {
    return (Applicant__c) DatabaseUtils.getRecord(
      new Query(Applicant__c.SObjectType)
        .addFields()
        .queryChild('dau01__ContactPointAddresses__r')
        .addFields()
        .removeFields('Address')
        .whereEq('IsPrimary', true)
        .orderBy('dau01__Order__c')
        .run()
        .whereEq('Id', applicantId)
        .toString()
    );
  }

  /**
   * @description read all applicant fields by ID without child objects
   * @author Digital Align | 11-01-2021
   * @param Id applicantId
   * @return Applicant__c
   **/
  public static Applicant__c fetchApplicantById(Id applicantId) {
    return (Applicant__c) getRecord(
      Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        .whereEq('Id', applicantId)
        .toString(true)
    );
  }
}
