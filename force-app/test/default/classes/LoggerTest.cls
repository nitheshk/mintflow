@istest
public with sharing class LoggerTest {
  // private static logger log = logger.getInstance(LoggerTest.class);
  private static Account makeAccountData() {
    Account acc = TestData.createAccount();
    acc = (Account) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  private static SystemSetting__c makeSystemSettingData(string debugLevel) {
    SystemSetting__c systemSetting = TestData.createSystemSetting();
    if (debugLevel != null) {
      systemSetting.LoggingLevel__c = debugLevel;
    }
    systemSetting = (SystemSetting__c) DatabaseUtils.insertRecord(
      systemSetting
    );
    return systemSetting;
  }
  @istest
  static void loggerTestOne() {
    account acc = makeAccountData();
    makeSystemSettingData(null);
    logger log = logger.getInstance(LoggerTest.class);
    log?.debug(acc);
    log?.debug('Debug');
    log?.debug(new Map<String, Object>{ 'Account' => acc });
    log?.error(acc);
    log?.fine(acc);
    log?.info(acc);
    log?.info('info');
    log?.info(new Map<String, Object>{ 'Account' => acc });
    log?.error(new customException('Test exception'));
    log?.error('error');
    log?.setMethodName('TestMethod');
    logger.setEntity('Entity');
    logger.setApplicationName('applicationName');
    logger.customlog(LoggingLevel.DEBUG, 'Class', 'message');
    Logger.persist();
    ApexResponse res = logger.deleteLogs();
    system.assertEquals(200, res.status, 'Success');
  }
}
