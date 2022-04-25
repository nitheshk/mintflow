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

  /**
   * @description  return custom notification type
   * @author Digital Align Team | 01-18-2022
   * @param string notificationName
   * @return CustomNotificationType
   **/
  public static CustomNotificationType readNotificationType(string notificationDeveloperName) {
    return (CustomNotificationType) getRecord(
      Query.newInstance(CustomNotificationType.SObjectType)
        .whereEq('DeveloperName', notificationDeveloperName)
        .toString()
    );
  }

  /**
   * @description Read Regular Groups
   * @author Digital Align Team | 01-18-2022
   * @return List<Group>
   **/
  public static List<Group> readRegularGroup() {
    return (List<Group>) getRecords(
      Query.newInstance(Group.SObjectType).addFields('DeveloperName').whereEq('Type', 'Regular').toString()
    );
  }

  /**
   * @description
   * @author Digital Align Team | 04-19-2022
   * @param List<String> skipApexClasses
   * @return List<ApexClass>
   **/
  public static List<ApexClass> fetchApexClasses(List<String> skipApexClasses) {
    String q = Query.newInstance(ApexClass.SObjectType)
      .addFields('NamespacePrefix,Name')
      .whereNotIn('Name', skipApexClasses)
      .orderBy('Name')
      .toString();
    return (List<ApexClass>) getRecords(q);
  }

  /**
   * @description
   * @author Digital Align Team | 04-25-2022
   * @param Id entryId
   * @return SchedulerEntry__c
   **/
  public static SchedulerEntry__c readScheduledEntry(Id entryId) {
    String q = Query.newInstance(SchedulerEntry__c.SObjectType)
      .addFields()
      .addFields('Owner.IsActive')
      .whereEq('Id', entryId)
      .toString();
    return (SchedulerEntry__c) getRecord(q);
  }
}
