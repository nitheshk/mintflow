/**
 * Copyright (c) 2021 Digital Align
 * @group Resolver
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ProductServiceResolver extends AbstractService {
  @TestVisible
  private static ProductServiceResolver serviceInstance;

  public ProductServiceResolver() {
    super(ProductServiceResolver.class);
  }

  /**
   * @description Provides a singleton instance of ProductServiceResolver from which all other class methods can be accessed.
   * @author Digital Align Team | 07-22-2021
   * @return Object  singleton
   **/
  public static ProductServiceResolver getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ProductServiceResolver) getInstance(
        ProductServiceResolver.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align Team | 01-05-2022
   * @param String data
   * @return List<FinancialAccountService__c>
   **/
  global virtual List<FinancialAccountService__c> fetchServices(String data) {
    Account application = ProductServiceRepository.readApplicationWithFA(
      ApexRequest.getApplicationId()
    );
    log?.debug('application=' + application);

    List<FinancialAccountService__c> financialAccountService = new List<FinancialAccountService__c>();

    for (
      FinServ__FinancialAccount__c financialAccount : application.FinancialAccounts__r
    ) {
      financialAccountService.addAll(
        ProductServiceRepository.readExistingService(financialAccount.Id)
      );
    }

    if (!financialAccountService.isEmpty()) {
      return financialAccountService;
    }

    for (
      FinServ__FinancialAccount__c financialAccount : application.FinancialAccounts__r
    ) {
      List<ProductService__c> services = ProductServiceRepository.fetchServicesByProduct(
        financialAccount.FinancialProduct__r.Id
      );
      log?.debug(services);

      financialAccountService.addAll(
        this.buildService(services, financialAccount.Id)
      );
    }
    ProductServiceRepository.upsertRecords(financialAccountService);
    return financialAccountService;
  }
  /**
   * @description  build survey object based on the template list
   * @author Digital Align Team | 01-05-2022
   * @param List<ProductService__c> productServices
   * @param Id financialAccountId
   * @return  List<FinancialAccountService__c>
   **/
  global virtual List<FinancialAccountService__c> buildService(
    List<ProductService__c> productServices,
    Id financialAccountId
  ) {
    List<FinancialAccountService__c> serviceList = new List<FinancialAccountService__c>();
    for (ProductService__c productService : productServices) {
      FinancialAccountService__c finProductServiceObj = new FinancialAccountService__c();

      if (String.isNotBlank(financialAccountId)) {
        finProductServiceObj.FinancialAccount__c = financialAccountId;
      }
      finProductServiceObj.Order__c = productService.Order__c;
      finProductServiceObj.Required__c = productService.Required__c;
      finProductServiceObj.Description__c = productService.Description__c;
      finProductServiceObj.Design__c = productService.Design__c;
      finProductServiceObj.Required__c = productService.Required__c;
      finProductServiceObj.ServiceName__c = productService.ServiceName__c;
      finProductServiceObj.ShowQuestions__c = productService.ShowQuestions__c;
      finProductServiceObj.isSelected__c = false;
      serviceList.add(finProductServiceObj);
    }
    return serviceList;
  }
}
