/**
 * Copyright (c) 2021 Digital Align
 * @group Resolver
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ConsentResolver extends AbstractService {
  @TestVisible
  private static ConsentResolver serviceInstance;

  public ConsentResolver() {
    super(ConsentResolver.class);
  }

  /**
   * @description Provides a singleton instance of ConsentResolver from which all other class methods can be accessed.
   * @author Digital Align Team | 12/22/2021
   * @return Object  singleton
   **/
  public static ConsentResolver getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ConsentResolver) getInstance(ConsentResolver.class);
    }
    return serviceInstance;
  }
}
