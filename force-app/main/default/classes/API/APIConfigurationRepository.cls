/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference Repository for API related metadata settings
 * @description APIConfigurationRepository
 **/

public without sharing class APIConfigurationRepository extends DatabaseUtils {
  /**
   * @description GetAPIconstant value based on developer name
   * @author Digital Align Team | 07-12-2021
   * @return Object  APIConstant__mdt
   **/
  public static APIConstant__mdt getAPIConstants(String developerName) {
    String q = Query.newInstance(APIConstant__mdt.SObjectType)
      .addFields()
      .whereEq('DeveloperName', developerName)
      .andCon()
      .WhereEq('dau01__isActive__c', true)
      .toString();
    return (APIConstant__mdt) getRecord(q);
  }
  /**
   * @description setAPISettings value based on APIMapper
   * @author Digital Align Team | 07-12-2021
   * @return Object  APISetting__mdt
   **/
  public static APISetting__mdt setAPISettings(APINames apiMapper) {
    String apiName = String.valueOf(apiMapper);
    String q = Query.newInstance(APISetting__mdt.SObjectType)
      .addFields()
      .whereEq('DeveloperName', apiName)
      .toString();
    return (APISetting__mdt) getRecord(q);
  }
  /**
   * @description setAllAPISettings if no APIMapper is passed
   * @author Digital Align | 10-08-2021
   * @return List<APISetting__mdt>
   **/
  public static List<APISetting__mdt> setAllAPISettings() {
    String q = Query.newInstance(APISetting__mdt.SObjectType)
      .addFields()
      .toString();
    return (List<APISetting__mdt>) getRecords(q);
  }
}
