/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class RpaProcessProvider extends AbstractService {
  @TestVisible
  private static RpaProcessProvider serviceInstance;

  public RpaProcessProvider() {
    super(RpaProcessProvider.class);
  }

  /**
   * @description Provides a singleton instance of RpaProcessProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 11/25/2021
   * @return Object  singleton
   **/
  public static RpaProcessProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (RpaProcessProvider) getInstance(
        RpaProcessProvider.class
      );
    }
    return serviceInstance;
  }

  global virtual HttpBuilder.Response addKycReviewQueue() {
    return null;
  }
}
