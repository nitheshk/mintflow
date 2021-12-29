/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description Repository used for generic class deisgn
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class CommonRepository extends DatabaseUtils {
  /**
   * @description fetch existing flow from entity
   * @author Digital Align Team | 10-19-2021
   * @param String entityId
   * @return List<Flow__c>
   **/
  public static List<Flow__c> fetchFlowByEntityId(String entityId) {
    String q = Query.newInstance(Flow__c.SObjectType)
      .addFields()
      .removeFields('mflow__Note__c,mflow__Request__c,mflow__Response__c')
      .queryChild('mflow__SubFlows__r')
      .addFields()
      .run()
      .whereEq('mflow__Entity__c', entityId)
      .toString();
    return (List<Flow__c>) getRecords(q);
  }
}
