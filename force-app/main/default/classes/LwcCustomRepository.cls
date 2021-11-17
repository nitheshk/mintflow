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
      .queryChild('dau01__SubFlows__r')
      .addFields()
      .run()
      .whereEq('dau01__Entity__c', entityId)
      .toString();
    return (List<Flow__c>) getRecords(q);
  }
  /**
   * @description
   * @author Digital Align | 11-17-2021
   * @return List<ApplicationConfiguration__c>
   **/
  public static List<ApplicationConfiguration__c> fetchApplicationConfigValues() {
    String q = Query.newInstance(ApplicationConfiguration__c.SObjectType)
      .addFields()
      .run()
      .addLimit(1)
      .toString();
    return (List<ApplicationConfiguration__c>) getRecords(q);
  }
}
