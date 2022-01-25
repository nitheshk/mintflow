/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicationSubmissionService extends AbstractService {
  @TestVisible
  private static ApplicationSubmissionService serviceInstance;

  public ApplicationSubmissionService() {
    super(ApplicationSubmissionService.class);
  }

  /**
   * @description Provides a singleton instance of ApplicationSubmissionService from which all other class methods can be accessed.
   * @author Digital Align Team | 01/25/2022
   * @return Object  singleton
   **/
  public static ApplicationSubmissionService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicationSubmissionService) getInstance(
        ApplicationSubmissionService.class
      );
    }
    return serviceInstance;
  }


  /**
  * @description final application submit 
  * @author Digital Align Team | 01-25-2022 
  * @param String data 
  * @return Account 
  **/
  global virtual Account submitApplication(String data){
    return null;
  }
}
