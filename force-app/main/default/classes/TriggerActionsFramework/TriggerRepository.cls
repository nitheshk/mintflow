/**
 * Copyright (c) 2021 Digital Align
 * @group Utils Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/

public with sharing class TriggerRepository extends DatabaseUtils {
  /**
   * @description
   * @author Digital Align | 06-05-2021
   * @param Stirng sObjectName
   * @param String namespace
   * @return list<SObjectTriggerSetting__mdt>
   **/
  public static list<SObjectTriggerSetting__mdt> fetchTriggerSettingBySObject(
    String sObjectName,
    String namespace
  ) {
    List<Object> parameters = new List<Object>{ sObjectName, namespace };
    String q = new Query(SObjectTriggerSetting__mdt.SObjectType)
      .addFields()
      .whereCon('dau01__ObjectAPIName__c', '={0}')
      .andCon()
      .whereCon('dau01__ObjectNamespace__c', '={1}')
      .andCon()
      .whereCon('dau01__Disabled__c', '=false')
      .orderby('dau01__Order__c')
      .toString(true);
    return (List<SObjectTriggerSetting__mdt>) DatabaseUtils.getRecords(
      q,
      parameters
    );
  }
}
