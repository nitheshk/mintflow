/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description  This class implement utils function for some
 * basic function for handling apex class related
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class ApexUtils {
  /** Apex Rest Related */
  private final static string NAMESPACE = 'mflow';

  /**
   * @description
   * @author Digital Align Team | 11-25-2021
   * @param String classUrlMapping
   * @return String
   **/
  global static String obtainUrlSuffix(String classUrlMapping) {
    String cBaseUrl = (NAMESPACE + classUrlMapping);
    String fullUrl = System.RestContext.request.requestURI.removeEnd('/');
    return fullUrl.toLowerCase().substringAfterLast(cBaseUrl.toLowerCase());
  }
  /**
   * @description
   * @author Digital Align Team | 11-25-2021
   * @param String searchFilter
   * @return String
   **/
  global static String obtainSearchString(map<string, string> searchFilter) {
    String keyValue;
    String dynamicString;
    String dateCondition;
    Datetime dt;
    DateTime dtAndTime;
    String dateValue;

    for (String mapValue : searchFilter.keySet()) {
      keyValue = searchFilter.get(mapValue);
      dateCondition = '';
      if (mapValue.equalsIgnoreCase('CreatedDateFrom')) {
        dt = DateUtils.convertJsonStringToDateTime(keyValue);
        dateValue = Dateutils.formatDateTimeGMT(dt);
        dateCondition = 'CreatedDate >=' + dateValue;
      } else if (mapValue.equalsIgnoreCase('CreatedDateTo')) {
        dt = DateUtils.convertJsonStringToDateTime(keyValue);
        dateValue = Dateutils.formatDateTimeGMT(dt);
        dateCondition = 'CreatedDate <=' + dateValue;
      } else if (mapvalue.equalsignorecase('dateRange')) {
        if (string.isNotBlank(dynamicString)) {
          dynamicString = dynamicString + ' AND CreatedDate=' + keyValue;
        } else {
          dynamicString = ' CreatedDate=' + keyValue;
        }
      } else {
        if (String.isNotBlank(dynamicString)) {
          dynamicString = dynamicString + ' AND ' + mapValue + ' like \'' + '%' + keyValue + '%' + '\'';
        } else {
          dynamicString = mapValue + ' like \'' + '%' + String.escapeSingleQuotes(keyValue) + '%' + '\'';
        }
      }
      if (String.isnotBlank(dynamicString) && String.isNotBlank(dateCondition)) {
        dynamicString = dynamicString + ' AND ' + dateCondition;
      } else {
        if (String.isNotBlank(dateCondition)) {
          dynamicString = dateCondition;
        }
      }
    }
    return dynamicString;
  }
}
