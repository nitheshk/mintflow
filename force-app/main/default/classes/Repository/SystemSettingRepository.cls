/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description Repository to fetch system related setting
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual inherited sharing class SystemSettingRepository extends DatabaseUtils {
  /**
   * @description fetchSystemClassSetting
   * @author Digital Align Team | 07-13-2021
   * @param String developerName
   * @return ServiceClassSetting__mdt
   **/
  global static ServiceClassSetting__mdt fetchSystemClassSetting(
    String developerName
  ) {
    String q = Query.newInstance(ServiceClassSetting__mdt.SObjectType)
      .addFields()
      .whereEq('DeveloperName', developerName)
      .andCon()
      .WhereEq('dau01__Disabled__c', false)
      .toString();

    return (ServiceClassSetting__mdt) getRecord(q);
  }
}
