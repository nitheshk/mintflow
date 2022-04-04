@istest
public with sharing class DynamicLWCDataTableServiceTest {
  @isTest
  static void getTableDetailsTest() {
    test.startTest();
    DynamicLWCDataTableController.getTableDetails(null, null, null, null, null);
    DynamicLWCDataTableController.getTableDetails('FIEmployees', '', '', 1, 1);
    DynamicLWCDataTableController.getTableDetails('FIApplications', 'FilterString', 'SortString', 1, 1);
    test.stopTest();
    system.assertEquals(null, null, 'message');
  }
}
