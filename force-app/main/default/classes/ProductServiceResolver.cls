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
      serviceInstance = (ProductServiceResolver) getInstance(ProductServiceResolver.class);
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
    Application__c application = ProductServiceRepository.readApplicationWithFA(ApexRequest.getApplicationId());
    log?.debug('application=' + application);

    List<FinancialAccountService__c> financialAccountService = new List<FinancialAccountService__c>();

    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      financialAccountService.addAll(ProductServiceRepository.readExistingService(financialAccount.Id));
    }

    if (!financialAccountService.isEmpty()) {
      return financialAccountService;
    }

    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      List<ProductService__c> services = ProductServiceRepository.fetchServicesByProduct(
        financialAccount.FinancialProduct__r.Id
      );
      log?.debug(services);

      financialAccountService.addAll(this.buildService(services, financialAccount.Id));
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
  /**
   * @description fetch referral Product product for the product selected in the application
   * @author Digital Align Team | 04-03-2022
   * @param String data
   * @return List<CustomerInterest__c>
   **/
  global virtual List<CustomerInterest__c> fetchReferralProducts(String data) {
    mflow__Application__c application = ProductServiceRepository.readApplicationWithFA(ApexRequest.getApplicationId());

    List<CustomerInterest__c> customerInterests = new List<CustomerInterest__c>();

    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      List<ReferralProduct__c> ReferralProducts = ProductServiceRepository.fetchReferralProductByProduct(
        financialAccount.FinancialProduct__r.Id
      );
      customerInterests.addAll(this.buildReferralProduct(ReferralProducts, application.Id));
    }
    ProductServiceRepository.upsertRecords(customerInterests);
    return customerInterests;
  }
  /**
   * @description  build referral Products based on the interest list
   * @author Digital Align Team | 04-03-2022
   * @param List<ReferralProduct__c> ReferralProducts
   * @param Id applicationId
   * @return  List<CustomerInterest__c>
   **/
  global virtual List<CustomerInterest__c> buildReferralProduct(
    List<ReferralProduct__c> ReferralProducts,
    Id applicationId
  ) {
    List<CustomerInterest__c> customerInterests = new List<CustomerInterest__c>();
    for (ReferralProduct__c referralProduct : ReferralProducts) {
      CustomerInterest__c customerInterestObj = new CustomerInterest__c();

      if (String.isNotBlank(applicationId)) {
        customerInterestObj.Application__c = applicationId;
      }
      customerInterestObj.Name = referralProduct.Name;
      customerInterestObj.EndDate__c = referralProduct.EndDate__c;
      customerInterestObj.ExternalCode__c = referralProduct.ExternalCode__c;
      customerInterestObj.ImageName__c = referralProduct.ImageName__c;
      customerInterestObj.ImageURL__c = referralProduct.ImageURL__c;
      customerInterestObj.InternalCode__c = referralProduct.InternalCode__c;
      customerInterestObj.InterestProduct__c = referralProduct.CrossSellProduct__c;
      customerInterestObj.LongDescription__c = referralProduct.LongDescription__c;
      customerInterestObj.Order__c = referralProduct.Order__c;
      customerInterestObj.StartDate__c = referralProduct.StartDate__c;
      customerInterestObj.Required__c = referralProduct.Required__c;
      customerInterestObj.isSelected__c = false;
      customerInterests.add(customerInterestObj);
    }
    return customerInterests;
  }
}
