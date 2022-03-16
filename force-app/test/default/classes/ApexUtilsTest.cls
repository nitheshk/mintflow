@istest
public with sharing class ApexUtilsTest {
  @istest
  private static void testOne() {
    ApexUtils.obtainSearchString(new Map<string, string>{ 'CreatedDateFrom' => String.valueOf(Date.today()) });
    ApexUtils.obtainSearchString(new Map<string, string>{ 'CreatedDateTo' => String.valueOf(Date.today()) });
    ApexUtils.obtainSearchString(new Map<string, string>{ 'dateRange' => String.valueOf(Date.today()) });
    ApexUtils.obtainSearchString(new Map<string, string>{ 'test' => String.valueOf(Date.today()) });
  }
}
