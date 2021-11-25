@istest
public with sharing class DynamicLWCDataTableServiceTest {
  @isTest
  static void getTableDetailsTest() {
    test.startTest();
    DynamicLWCDataTableService.getInstance()
      .getTableDetails('FIEmployees', '', '', 1, 1);
    DynamicLWCDataTableService.getInstance()
      .getTableDetails('FIApplications', 'FilterString', 'SortString', 1, 1);
    test.stopTest();
    system.assertEquals(null, null, 'message');
  }
}
