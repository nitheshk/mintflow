@istest
public with sharing class ApexUtilsTest {
  @istest
  private static void testOne() {
    ApexUtils.obtainSearchString(new Map<string, string>{ 'CreatedDateFrom' => String.valueOf(Date.today()) });
    ApexUtils.obtainSearchString(new Map<string, string>{ 'CreatedDateTo' => String.valueOf(Date.today()) });
    ApexUtils.obtainSearchString(new Map<string, string>{ 'dateRange' => String.valueOf(Date.today()) });
    String result = ApexUtils.obtainSearchString(new Map<string, string>{ 'test' => String.valueOf(Date.today()) });
    system.assertNotEquals(null, result, 'result matched');
  }

  @istest
  private static void obtainUrlSuffix() {
    RestContext.request = new RestRequest();
    RestContext.response = new RestResponse();
    RestContext.request.requestURI = '/services/apexrest/mflow/test/success';
    RestContext.request.httpMethod = 'GET';
    String result = ApexUtils.obtainUrlSuffix('test');
    system.assertNotEquals(null, result, 'result matched');
  }
}
