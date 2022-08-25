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
      Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        .queryChild('mflow__Addresses__r')
        .addFields()
        .removeFields('Address')
        .whereEq('IsPrimary', true)
        .orderBy('mflow__Order__c')
        .run()
        .whereEq('Id', applicantId)
        .toString()
    );
  }
  /**
   * @description
   * @author Digital Align Team | 07-02-2021
   * @param string zipcode
   * @return EligibleCounty__c
   **/
  public static EligibleCounty__c fetchCountyByZipcode(string zipcode) {
    return (EligibleCounty__c) DatabaseUtils.getRecord(
      Query.newInstance(EligibleCounty__c.SObjectType).addFields().whereEq('Postalcode__c', zipcode).toString()
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
   * @description read applicant with identity information
   * @author Digital Align Team | 11-18-2021
   * @param Id applicantId
   * @return Applicant__c
   **/
  public static Applicant__c readApplicantWithIdentity(Id applicantId) {
    return (Applicant__c) DatabaseUtils.getRecord(
      Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        .addFields('RecordType.Name')
        .queryLookup('mflow__Application__r')
        .addFields()
        .run()
        .queryChild('mflow__IdentificationDocuments__r')
        .addFields()
        .run()
        .queryChild('mflow__Addresses__r')
        .addFields()
        .removeFields('Address')
        .orderBy('mflow__Order__c')
        .run()
        .whereEq('Id', applicantId)
        .toString()
    );
  }
}
