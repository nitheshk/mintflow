@istest
public with sharing class OnlinePortalControllerTest {
  //makeApplicationConfiguration
  private static void makeApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = TestData.createApplicationConfiguration();
    insert appConfig;
    TestData.createSiteSetting();
    List<FinancialProduct__c> products = TestData.createProduct();
    insert products;
  }
  @isTest
  static void productSelectorTest() {
    makeApplicationConfiguration();
    //200
    ApexRequest request = new ApexRequest();
    request.token = ApexRequest.getToken();
    ApexResponse res = OnlinePortalController.productSelector(request);
    system.assertEquals(200, res.status, 'success');

    request = new ApexRequest();
    request.token = 'InvalidToken';
    res = OnlinePortalController.productSelector(null);
    // system.assertEquals(500, res.status, 'success');
  }
}
