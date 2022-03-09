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
    ApexResponse.ok(acc);
    ApexResponse.ok(acc);
    ApexResponse.ok();
    ApexResponse.fail(acc);
    ApexResponse.fail();
    res = ApexResponse.exception(acc);
    system.assertEquals(500, res.status, 'success');
  }
  @istest
  static void apexResponseTestTwo() {
    Application__c acc = makeAccountData();
    ApexResponse res = new ApexResponse();
    res.setEntity(acc);
    res.setData(acc);
    system.assertEquals(null, res.status, 'success');
  }
  @istest
  static void apexResponseTestThree() {
    Application__c acc = makeAccountData();
    ApexResponse res = new ApexResponse();
    ApexResponse.fail(new customException('Test exception'));
    res = ApexResponse.exception(new customException('Test exception'));
    system.assertEquals(500, res.status, 'success');
  }
}
