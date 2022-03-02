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
   * @return List<Account>
   **/
  global static List<Account> fetchApplicationByApplicantDetails(
    String lastFourDigitofSSN,
    string email,
    string lastName
  ) {
    return (List<Account>) DatabaseUtils.getRecords(
      Query.newInstance(Account.SObjectType)
        .addFields()
        .queryChild('mflow__ApplicantsTemp__r')
        .addFields()
        .addFields('RecordType.Name')
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
}
