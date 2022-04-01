@IsTest
public with sharing class LWCFinancialInstituteSiteControllerTest {
  private static Account makeAccountData() {
    Account acc = TestData.createAccountRecord();
    acc = (Account) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  private static ApplicationConfiguration__c makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    appConfig = (ApplicationConfiguration__c) DatabaseUtils.insertRecord(appConfig);
    return appConfig;
  }
  private static Contact makeContactData(Account acc) {
    Contact con = TestData.createContact(acc);
    con = (Contact) DatabaseUtils.insertRecord(con);
    return con;
  }

  //----------------------TEST METHODS-------------------------------------------
  @IsTest
  private static void createFinancialInstituteAccountTest() {
    makeApplicationConfiguration();
    Account acc = makeAccountData();
    Map<String, Object> params = new Map<String, Object>{ 'account' => acc };
    Test.startTest();
    ApexResponse result = LWCFinancialInstituteSiteController.createFinancialInstituteAccount(params);
    ApexResponse result1 = LWCFinancialInstituteSiteController.createFinancialInstituteAccount(
      new Map<String, Object>{ 'Noaccount' => new Account() }
    );
    Test.stopTest();
  }

  @IsTest
  private static void fetchFinancialInstituteAccountNullCheck() {
    ApplicationConfiguration__c appConfig = makeApplicationConfiguration();
    Test.startTest();
    ApexResponse result1 = LWCFinancialInstituteSiteController.fetchFinancialInstituteAccount();
    system.debug(result1);
    Test.stopTest();
    //system.assertEquals(null, result1, 'Success');
  }
  @IsTest
  private static void fetchFinancialInstituteAccountTest() {
    makeApplicationConfiguration();
    Account acc = makeAccountData();
    Map<String, Object> params = new Map<String, Object>{ 'account' => acc };
    LWCFinancialInstituteSiteController.createFinancialInstituteAccount(params);
    Test.startTest();
    ApexResponse result1 = LWCFinancialInstituteSiteController.fetchFinancialInstituteAccount();
    system.debug('result1 =' + result1);
    Test.stopTest();
    //system.assertEquals(null, result1);
  }
  @IsTest
  private static void createFinInstEmployeeUserAccountTest() {
    Account acc = makeAccountData();
    ApplicationConfiguration__c config = makeApplicationConfiguration();
    config.FinancialInstituteAccountId__c = acc.Id;
    config = (ApplicationConfiguration__c) DatabaseUtils.updateRecord(config);
    Contact con = makeContactData(null);
    Map<String, Object> params = new Map<String, Object>{ 'contact' => con };
    Test.startTest();
    ApexResponse result = LWCFinancialInstituteSiteController.createFinInstEmployeeAccount(params);
    Test.stopTest();
    //system.assertEquals(null, result1, 'Success');
  }
}
