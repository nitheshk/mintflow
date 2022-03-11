/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Financial Institute Site Service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class FinancialInstituteSiteService extends AbstractService {
  @TestVisible
  private static FinancialInstituteSiteService serviceInstance;

  public FinancialInstituteSiteService() {
    super(FinancialInstituteSiteService.class);
  }

  /**
   * @description Provides a singleton instance of FinancialInstituteSiteService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static FinancialInstituteSiteService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (FinancialInstituteSiteService) getInstance(FinancialInstituteSiteService.class);
    }
    return serviceInstance;
  }

  global virtual Map<String, Map<String, Object>> fetchPickListValues(Map<String, Object> params) {
    Map<String, Map<String, Object>> result = new Map<String, Map<String, Object>>();

    for (String sType : params.keySet()) {
      List<String> fieldNames = (List<String>) JSON.deserialize(JSON.serialize(params.get(sType)), List<String>.class);
      Schema.DescribeSObjectResult sObjectResult = Schema.getGlobalDescribe().get(sType).getDescribe();
      result.put(sType, new Map<String, Object>());
      for (String fieldName : fieldNames) {
        List<Object> picklistValues = new List<Object>();
        for (
          Schema.PicklistEntry picklistEntry : sObjectResult.fields.getMap()
            .get(fieldName)
            .getDescribe()
            .getPicklistValues()
        ) {
          picklistValues.add(
            new Map<String, String>{ 'label' => picklistEntry.getLabel(), 'value' => picklistEntry.getValue() }
          );
        }
        result.get(sType).put(fieldName, picklistValues);
      }
    }
    return result;
  }
}
