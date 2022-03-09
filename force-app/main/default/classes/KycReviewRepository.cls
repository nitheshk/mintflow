/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/

@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class KycReviewRepository extends DatabaseUtils {
  /**
   * @description Read Application with FinancialAccount and Applicants
   * @author Digital Align Team | 12-02-2021
   * @param Id applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationForKYC(Id applicationId) {
    return (Application__c) DatabaseUtils.getRecord(
      Query.newInstance(Application__c.SObjectType)
        .addFields()
        .queryChild('mflow__FinancialAccounts__r')
        .addFields()
        .run()
        .queryChild('mflow__Applicants__r')
        .addFields()
        .addFields('RecordType.Name')
        .whereEq('RecordType.Name', ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE)
        .orCon()
        .whereEq('RecordType.Name', ApplicationConstant.APPLICANT_JOINT_RECORDTYPE)
        .orderBy('mflow__Order__c')
        .run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }

  /**
   * @description fetch existing contact based on the ssn and last name
   * @author Digital Align Team | 12-10-2021
   * @param String filter
   * @return List<Contact>
   **/
  global static List<Contact> fetchExistingContacts(String filter) {
    if (String.isBlank(filter)) {
      return new List<Contact>();
    }
    return (List<Contact>) DatabaseUtils.getRecords(
      Query.newInstance(Contact.SObjectType).addFields().whereCon(filter).addLimit(50).toString()
    );
  }
}
