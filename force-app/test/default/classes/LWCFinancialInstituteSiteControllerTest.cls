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
  @IsTest
  private static void retrieveEmployeesTest() {
    Account acc = makeAccountData();
    ApplicationConfiguration__c config = makeApplicationConfiguration();
    config.FinancialInstituteAccountId__c = acc.Id;
    config = (ApplicationConfiguration__c) DatabaseUtils.updateRecord(config);
    Contact con = makeContactData(null);
    //searchFilter = null
    Map<String, Object> params = new Map<String, Object>{
      'userContactType' => 'Employee',
      'searchString' => 'Test',
      'searchFilter' => new Map<String, string>()
    };
    ApexResponse result = LWCFinancialInstituteSiteController.retrieveEmployees(params);
    //searchFilter!=null
    params = new Map<String, Object>{
      'userContactType' => 'Employee',
      'searchString' => 'Test',
      'searchFilter' => new Map<String, string>{ 'Name' => 'John' }
    };
    result = LWCFinancialInstituteSiteController.retrieveEmployees(params);

    //searchString=null
    params = new Map<String, Object>{
      'userContactType' => 'Employee',
      'searchString' => null,
      'searchFilter' => new Map<String, string>{
        'FirstName' => 'FirstName',
        'LastName' => 'LastName',
        'Email' => 'Email',
        'MobilePhone' => 'mobilePhone',
        'mflow__EmployeeId__c' => 'Id'
      }
    };
    result = LWCFinancialInstituteSiteController.retrieveEmployees(params);
  }

  @IsTest
  private static void retrieveApplicantsTest() {
    Account acc = makeAccountData();
    ApplicationConfiguration__c config = makeApplicationConfiguration();
    config.FinancialInstituteAccountId__c = acc.Id;
    config = (ApplicationConfiguration__c) DatabaseUtils.updateRecord(config);
    Contact con = makeContactData(null);
    //searchFilter = null
    Map<String, Object> params = new Map<String, Object>{
      'userContactType' => 'Employee',
      'searchString' => 'Test',
      'searchFilter' => new Map<String, string>()
    };
    ApexResponse result = LWCFinancialInstituteSiteController.retrieveApplicants(params);
    //searchFilter!=null
    params = new Map<String, Object>{
      'userContactType' => 'Employee',
      'searchString' => 'Test',
      'searchFilter' => new Map<String, string>{ 'Name' => 'John' }
    };
    result = LWCFinancialInstituteSiteController.retrieveApplicants(params);

    //searchString=null
    params = new Map<String, Object>{
      'userContactType' => 'Employee',
      'searchString' => null,
      'searchFilter' => new Map<String, string>{
        'mflow__FirstName__c' => 'FirstName',
        'mflow__LastName__c' => 'LastName',
        'mflow__Email__c' => 'Email',
        'mflow__Phone__c' => 'mobilePhone',
        'mflow__SSN__c' => 'Id',
        'CreatedDate' => '2012-02-21T11:27:54.14Z'
      }
    };
    result = LWCFinancialInstituteSiteController.retrieveApplicants(params);
  }

  @IsTest
  private static void retrieveApplicationsTest() {
    Account acc = makeAccountData();
    ApplicationConfiguration__c config = makeApplicationConfiguration();
    config.FinancialInstituteAccountId__c = acc.Id;
    config = (ApplicationConfiguration__c) DatabaseUtils.updateRecord(config);
    Contact con = makeContactData(null);
    //searchFilter = null
    Map<String, Object> params = new Map<String, Object>{
      'userContactType' => 'Employee',
      'searchString' => 'Test',
      'searchFilter' => new Map<String, string>()
    };
    ApexResponse result = LWCFinancialInstituteSiteController.retrieveApplications(params);
    //searchFilter!=null
    params = new Map<String, Object>{
      'userContactType' => 'Employee',
      'searchString' => 'Test',
      'searchFilter' => new Map<String, string>{ 'Name' => 'John' }
    };
    result = LWCFinancialInstituteSiteController.retrieveApplications(params);

    //searchString=null
    params = new Map<String, Object>{
      'userContactType' => 'Employee',
      'searchString' => null,
      'searchFilter' => new Map<String, string>{
        'Name' => 'Name',
        'CreatedDateFrom' => '2012-02-21T11:27:54.14Z',
        'CreatedDateTo' => '2012-02-21T11:27:54.14Z',
        'dateRange' => '2012-02-21T11:27:54.14Z'
      }
    };
    result = LWCFinancialInstituteSiteController.retrieveApplications(params);
  }
  @IsTest
  private static void fetchPickListValuesTest() {
    Account acc = makeAccountData();
    ApplicationConfiguration__c config = makeApplicationConfiguration();
    config.FinancialInstituteAccountId__c = acc.Id;
    config = (ApplicationConfiguration__c) DatabaseUtils.updateRecord(config);
    Contact con = makeContactData(null);
    Map<String, Object> params = new Map<String, Object>{ 'Account' => new List<String>{ 'Ownership' } };

    //200
    ApexResponse result = LWCFinancialInstituteSiteController.fetchPickListValues(params);
    system.assertEquals(200, result.status, 'Success');

    //400
    params = new Map<String, Object>{ 'Account' => new List<String>{ 'test' } };
    result = LWCFinancialInstituteSiteController.fetchPickListValues(params);
    system.assertEquals(500, result.status, 'Success');
  }
}
