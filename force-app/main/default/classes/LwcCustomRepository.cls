/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class LwcCustomRepository extends DatabaseUtils {
  /**
   * @description fetch existing flow from entity
   * @author Digital Align Team | 10-19-2021
   * @param String entityId
   * @return List<Flow__c>
   **/
  public static List<Flow__c> fetchFlowByEntityId(String entityId) {
    String q = Query.newInstance(Flow__c.SObjectType)
      .addFields()
      .queryChild('mflow__SubFlows__r')
      .addFields()
      .run()
      .whereEq('mflow__Entity__c', entityId)
      .toString();
    return (List<Flow__c>) getRecords(q);
  }
}
