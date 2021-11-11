/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class EmploymentService extends AbstractService {
  @TestVisible
  private static EmploymentService serviceInstance;

  public EmploymentService() {
    super(EmploymentService.class);
  }

  /**
   * @description Provides a singleton instance of EmploymentService from which all other class methods can be accessed.
   * @author Digital Align Team | 11/11/2021
   * @return Object  singleton
   **/
  public static EmploymentService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (EmploymentService) getInstance(
        EmploymentService.class
      );
    }
    return serviceInstance;
  }
}
