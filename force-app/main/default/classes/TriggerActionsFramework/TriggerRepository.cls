/**
 * Copyright (c) 2021 Digital Align
 * @group Utils Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/

public with sharing class TriggerRepository extends DatabaseUtils {
  /**
   * @description  Get Trigger setting
   * @author Digital Align | 06-05-2021
   * @param Stirng sObjectName
   * @return list<SObjectTriggerSetting__mdt>
   **/
  public static list<SObjectTriggerSetting__mdt> fetchTriggerSettingBySObject(
    String sObjectName
  ) {
    String q = new Query(SObjectTriggerSetting__mdt.SObjectType)
      .addFields()
      .whereEq('dau01__ObjectAPIName__c', sObjectName)
      .andCon()
      .whereEq('dau01__Disabled__c', false)
      .orderby('dau01__Order__c')
      .toString(true);
    return (List<SObjectTriggerSetting__mdt>) DatabaseUtils.getRecords(q);
  }
}
