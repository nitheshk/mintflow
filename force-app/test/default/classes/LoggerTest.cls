@istest
public with sharing class LoggerTest {
  private static logger log = logger.getInstance(LoggerTest.class);
  private static Account makeAccountData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  private static SystemSetting__c makeSystemSettingData() {
    SystemSetting__c systemSetting = TestData.createSystemSetting();
    systemSetting = (SystemSetting__c) DatabaseUtils.insertRecord(
      systemSetting
    );
    return systemSetting;
  }
  @istest
  static void loggerTestOne() {
    account acc = makeAccountData();
    makeSystemSettingData();
    log?.debug(acc);
    log?.error(acc);
    log?.fine(acc);
    log?.info(acc);
    log?.setMethodName('TestMethod');
    Logger.persist();
    logger.deleteLogs();
  }
}
