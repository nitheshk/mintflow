public with sharing class DynamicLWCDataTableResponse {
  @AuraEnabled
  public String tableColumns { get; set; }
  @AuraEnabled
  public String tableData { get; set; }
}
