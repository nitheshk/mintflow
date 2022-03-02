@IsTest
public with sharing class UserAccountManagementControllerTest {
  private static Application__c makeAccountData() {
    Application__c acc = TestData.createAccount();
    acc = (Application__c) DatabaseUtils.insertRecord(acc);
    return acc;
  }
  private static ApplicationConfiguration__c makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    appConfig = (ApplicationConfiguration__c) DatabaseUtils.insertRecord(
      appConfig
    );
    return appConfig;
  }
  private static Contact makeContactData(Application__c acc) {
    Contact con = TestData.createContact(acc);
    con = (Contact) DatabaseUtils.insertRecord(con);
    return con;
  }

  //----------------------TEST METHODS-------------------------------------------
  @IsTest
  private static void createFinancialInstituteAccountTest() {
    makeApplicationConfiguration();
    Application__c acc = makeAccountData();
    Map<String, Object> params = new Map<String, Object>{ 'account' => acc };
    Test.startTest();
    ApexResponse result = UserAccountManagementController.createFinancialInstituteAccount(
      params
    );
    ApexResponse result1 = UserAccountManagementController.createFinancialInstituteAccount(
      new Map<String, Object>{ 'Noaccount' => new Application__c() }
    );
    Test.stopTest();
  }

  @IsTest
  private static void fetchFinancialInstituteAccountNullCheck() {
    ApplicationConfiguration__c appConfig = makeApplicationConfiguration();
    Test.startTest();
    ApexResponse result1 = UserAccountManagementController.fetchFinancialInstituteAccount();
    system.debug(result1);
    Test.stopTest();
    //system.assertEquals(null, result1, 'Success');
  }
  @IsTest
  private static void fetchFinancialInstituteAccountTest() {
    makeApplicationConfiguration();
    Application__c acc = makeAccountData();
    Map<String, Object> params = new Map<String, Object>{ 'account' => acc };
    UserAccountManagementController.createFinancialInstituteAccount(params);
    Test.startTest();
    ApexResponse result1 = UserAccountManagementController.fetchFinancialInstituteAccount();
    system.debug('result1 =' + result1);
    Test.stopTest();
    //system.assertEquals(null, result1);
  }
  @IsTest
  private static void createFinInstEmployeeUserAccountTest() {
    Application__c acc = makeAccountData();
    ApplicationConfiguration__c config = makeApplicationConfiguration();
    config.FinancialInstituteAccountId__c = acc.Id;
    config = (ApplicationConfiguration__c) DatabaseUtils.updateRecord(config);
    Contact con = makeContactData(null);
    Map<String, Object> params = new Map<String, Object>{ 'contact' => con };
    Test.startTest();
    ApexResponse result = UserAccountManagementController.createFinInstEmployeeAccount(
      params
    );
    Test.stopTest();
    //system.assertEquals(null, result1, 'Success');
  }
}
