/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Controller for dynamic data table to be used across to show related list
 **/

global with sharing class DynamicLWCDataTableController {
  @AuraEnabled(cacheable=false)
  /**
   * @author Digital Align Team
   * @return ApexResponse
   * @description  To fetch table details including column and data
   **/

  global static ApexResponse getTableDetails(
    String metaDataName,
    String filterString,
    String sortString,
    Integer offset,
    Integer limitSize
  ) {
    try {
      return ApexResponse.ok(
        DynamicLWCDataTableService.getInstance()
          .getTableDetails(MetaDataName, FilterString, SortString, offset, limitSize)
      );
    } catch (Exception ex) {
      return ApexResponse.exception(ex);
    }
  }
}
