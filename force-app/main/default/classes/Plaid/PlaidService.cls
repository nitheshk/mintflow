/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class PlaidService extends AbstractService {
  @TestVisible
  private static PlaidService serviceInstance;

  public PlaidService() {
    super(PlaidService.class);
  }

  /**
   * @description Provides a singleton instance of PlaidService from which all other class methods can be accessed.
   * @author Digital Align Team | 12/28/2021
   * @return Object  singleton
   **/
  public static PlaidService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (PlaidService) getInstance(PlaidService.class);
    }
    return serviceInstance;
  }
}
