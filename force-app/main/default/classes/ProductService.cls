/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class ProductService extends AbstractService {
  @TestVisible
  private static ProductService serviceInstance;

  global ProductService() {
    super(ProductService.class);
  }

  /**
   * @description Provides a singleton instance of ProductService from which all other class methods can be accessed.
   * @author Digital Align Team | 03/22/2022
   * @return Object  singleton
   **/
  global static ProductService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ProductService) getInstance(ProductService.class);
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align Team | 03-22-2022
   * @param String data
   * @return List<financialProduct__c>
   **/
  global virtual List<financialProduct__c> fetchProducts() {
    List<financialProduct__c> products = ProductServiceRepository.fetchProducts();
    for (financialProduct__c product : products) {
      product.mflow__ImageURL__c = SiteSetting__c.getInstance().mflow__OnlineContentUrl__c + product.mflow__ImageURL__c;
    }
    return products;
  }
}
