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
}
