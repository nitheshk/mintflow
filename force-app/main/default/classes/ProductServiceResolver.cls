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

    List<FinancialAccountService__c> financialAccountService = new List<FinancialAccountService__c>();

    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      financialAccountService.addAll(ProductServiceRepository.readExistingService(financialAccount.Id));
    }

    if (!financialAccountService.isEmpty()) {
      return financialAccountService;
    }

    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      List<ProductService__c> services = ProductServiceRepository.fetchServicesByProduct(
        financialAccount.FinancialProduct__c
      );

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
    log?.fine('Inside fetchReferralProducts');
    Id applicationId = ApexRequest.getApplicationId();
    mflow__Application__c application = ProductServiceRepository.readApplicationForReferral(applicationId);

    List<CustomerInterest__c> oldCustomerInterestInitial = new List<CustomerInterest__c>();
    List<CustomerInterest__c> oldCustomerInterestReferral = new List<CustomerInterest__c>();
    if (!application.mflow__CustomerInterests__r.isEmpty()) {
      for (CustomerInterest__c customerInterest : application.mflow__CustomerInterests__r) {
        if (CustomerInterest.mflow__Focus__c == 'Initial Interest') {
          oldCustomerInterestInitial.add(CustomerInterest);
        } else {
          oldCustomerInterestReferral.add(CustomerInterest);
        }
      }
    }

    if (!oldCustomerInterestInitial.isEmpty()) {
      return oldCustomerInterestInitial;
    }

    Set<Id> productIds = new Set<Id>();
    for (FinancialAccount__c financialAccount : application.financialAccounts__r) {
      productIds.add(financialAccount.FinancialProduct__c);
    }

    List<CustomerInterest__c> customerInterests = buildCustomerInterest(
      ProductServiceRepository.fetchReferralProducts(productIds),
      applicationId
    );

    Map<String, CustomerInterest__c> customerInterestMap = new Map<String, CustomerInterest__c>();
    for (CustomerInterest__c customerInterest : customerInterests) {
      customerInterestMap.put(customerInterest.mflow__InterestProduct__c, customerInterest);
    }
    for (CustomerInterest__c customerInterest : oldCustomerInterestReferral) {
      customerInterestMap.put(customerInterest.mflow__InterestProduct__c, customerInterest);
    }

    return customerInterestMap.values();
  }

  /**
   * @description
   * @author Digital Align Team | 04-08-2022
   * @param List<ReferralProduct__c> referralProducts
   * @param Id applicationId
   * @return List<CustomerInterest__c>
   **/
  global virtual List<CustomerInterest__c> buildCustomerInterest(
    List<ReferralProduct__c> referralProducts,
    Id applicationId
  ) {
    List<CustomerInterest__c> customerInterests = new List<CustomerInterest__c>();
    for (ReferralProduct__c referralProduct : referralProducts) {
      CustomerInterest__c customerInterest = new CustomerInterest__c();
      customerInterest.mflow__Application__c = applicationId;
      customerInterest.Name = referralProduct.CrossSellProduct__r.mflow__DisplayLabel__c;
      customerInterest.mflow__Focus__c = ApplicationConstant.CUSTOMER_INTEREST_FOCUS_REFERRAL;
      customerInterest.mflow__InterestProduct__c = referralProduct.CrossSellProduct__c;
      customerInterest.mflow__InterestProduct__r = referralProduct.CrossSellProduct__r;
      customerInterest.mflow__isSelected__c = referralProduct.IsSelected__c;
      customerInterest.mflow__Order__c = referralProduct.mflow__Order__c;
      customerInterest.mflow__Required__c = referralProduct.mflow__Required__c;
      customerInterests.add(customerInterest);
    }
    return customerInterests;
  }
}
