/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class PlaidProvider extends AbstractService {
  @TestVisible
  private static PlaidProvider serviceInstance;

  public PlaidProvider() {
    super(PlaidProvider.class);
  }

  /**
   * @description Provides a singleton instance of PlaidProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 12/28/2021
   * @return Object  singleton
   **/
  public static PlaidProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (PlaidProvider) getInstance(PlaidProvider.class);
    }
    return serviceInstance;
  }
}
