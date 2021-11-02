/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description NotificationService for sending messages
 **/
public with sharing class NotificationRepository extends DatabaseUtils {
  /**
   * @description
   * @author Digital Align | 11-01-2021
   * @param string applicantId
   * @return Applicant__c
   **/
  public static Applicant__c fetchApplicantById(string applicantId) {
    return (Applicant__c) getRecord(
      Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        .whereEq('Id', applicantId)
        .toString(true)
    );
  }
}
