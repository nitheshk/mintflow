public with sharing class DynamicLWCDataTableRepository {
  public static List<DynamicDataTable__mdt> getTableDetails(
    String metaDataName,
    String FilterString,
    String SortString
  ) {
    List<DynamicDataTable__mdt> returnObjectList = new List<DynamicDataTable__mdt>();
    try {
      String queryString = Query.newInstance(DynamicDataTable__mdt.SObjectType)
        .addFields()
        .queryChild('mflow__DynamicDataTableItems__r')
        .addFields()
        .orderBy('mflow__DisplayOrder__c')
        .run()
        .run()
        .whereEq('mflow__DynamicDataTable__mdt.DeveloperName', metaDataName)
        .toString(true);

      return returnObjectList = (List<DynamicDataTable__mdt>) DatabaseUtils.getRecords(
        queryString,
        new List<Object>{ metaDataName }
      );
    } catch (exception ex) {
      throw ex;
    }
  }
}
