@istest
public with sharing class ApexResponseTest {
  private static Account makeAccountData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  @istest
  static void apexResponseTestOne() {
    Account acc = makeAccountData();
    ApexResponse res = new ApexResponse();
    ApexResponse.success(acc);
    ApexResponse.ok(acc);
    ApexResponse.ok();
    ApexResponse.fail(acc);
    ApexResponse.fail();
    ApexResponse.exception(acc);
    ApexResponse.setStatus(acc);
    res = ApexResponse.unauthorized(acc);
    system.assertEquals(503, res.status, 'success');
  }
  @istest
  static void apexResponseTestTwo() {
    Account acc = makeAccountData();
    ApexResponse res = new ApexResponse();
    res.setEntity(acc);
    res.setData(acc);
    res.serialize();
    res = ApexResponse.unauthorized(acc);
    system.assertEquals(503, res.status, 'success');
  }
  @istest
  static void apexResponseTestThree() {
    Account acc = makeAccountData();
    ApexResponse res = new ApexResponse();
    ApexResponse.fail(new customException('Test exception'));
    ApexResponse.exception(new customException('Test exception'));
    res = ApexResponse.unauthorized(acc);
    system.assertEquals(503, res.status, 'success');
  }
}
