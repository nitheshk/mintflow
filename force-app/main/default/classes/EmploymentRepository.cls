/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description The repository class to save all Employment related information of an applicant
 **/
global with sharing class EmploymentRepository extends DatabaseUtils {
  global static Employment__c readEmployerbyId(String employerId) {
    return (Employment__c) DatabaseUtils.getRecord(
      Query.newInstance(Employment__c.SObjectType)
        .addFields()
        .queryLookup('mflow__Applicant__r')
        .addFields()
        .queryLookup('mflow__Application__r')
        .addFields()
        .run()
        .run()
        .whereEq('Id', employerId)
        .toString()
    );
  }
}
