public with sharing class ChartRepository extends DatabaseUtils {
  public static List<object> fetchDataFromQuery(String soqlQuery) {
    return getRecords(soqlQuery);
  }
  public static List<List<SObject>> fetchCustomDataSourceClassList(
    String searchQuery
  ) {
    return [FIND :searchQuery IN ALL FIELDS RETURNING ApexClass(Name)];
  }
}
