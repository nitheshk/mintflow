@istest
public with sharing class ApexResponseTest {
  private static Application__c makeAccountData() {
    Application__c acc = TestData.createApplication();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  @istest
  static void apexResponseTestOne() {
    Application__c acc = makeAccountData();
    ApexResponse res = new ApexResponse();

    res = ApexResponse.ok(acc);
    system.assertEquals(200, res.status, 'success');

    res = ApexResponse.ok();
    system.assertEquals(200, res.status, 'success');

    res = ApexResponse.fail(acc);
    system.assertEquals(400, res.status, 'success');

    res = ApexResponse.fail();
    system.assertEquals(400, res.status, 'success');

    ApexResponse.fail(new customException('Test exception'));
    system.assertEquals(400, res.status, 'success');

    res = ApexResponse.exception('string');
    system.assertEquals(500, res.status, 'success');

    res = ApexResponse.exception(new customException('Test exception'));
    system.assertEquals(500, res.status, 'success');
  }

  @istest
  static void apexResponseRestContext() {
    Application__c acc = makeAccountData();
    RestContext.request = new RestRequest();
    RestContext.response = new RestResponse();
    ApexResponse res = ApexResponse.exception(new customException('Test exception'));
    res.setStatus(200);
    res.setEntity('test');
    res.addHeader('key', 'value');
    res.setData('test');
    res.setData(new Account());
    res.setDataAsStringfy('test');
    res.setDataAsStringfy(new Account());
    system.assertEquals(200, RestContext.response.statusCode, 'success');
  }
}
