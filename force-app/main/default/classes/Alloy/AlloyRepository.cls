/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AlloyRepository extends DatabaseUtils {
  /**
   * @description read  applicant with child record
   * @author Digital Align Team | 10-26-2021
   * @param Applicant__c applicantId
   **/
  public static Applicant__c readApplicantWithChild(Id applicantId) {
    Query qry = Query.newInstance(Applicant__c.SObjectType)
      .addFields()
      .queryChild('mflow__IdentificationDocuments__r')
      .addFields()
      .addLimit(1)
      .run()
      .queryChild('mflow__Addresses__r')
      .addFields()
      .removeFields('Address')
      .whereEq('IsPrimary__c', true)
      .addLimit(1)
      .run()
      .whereEq('Id', applicantId);
    return (Applicant__c) DatabaseUtils.getRecord(qry.toString());
  }
  /*
   * @description
   * @param String developerName
   * @return Document
   **/
  public static Document findDocumentByDeveloperName(String developerName) {
    String q = Query.newInstance(Document.SObjectType)
      .addFields()
      .whereEq('DeveloperName', developerName)
      .addLimit(1)
      .run()
      .toString();
    List<Document> l = (List<Document>) DatabaseUtils.getRecords(q);
    return l.isEmpty() ? null : l[0];
  }
}
