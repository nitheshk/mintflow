/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ReviewInformationService extends AbstractService {
  @TestVisible
  private static ReviewInformationService serviceInstance;

  public ReviewInformationService() {
    super(ReviewInformationService.class);
  }

  /**
   * @description Provides a singleton instance of ReviewInformationService from which all other class methods can be accessed.
   * @author Digital Align Team | 11/12/2021
   * @return Object  singleton
   **/
  public static ReviewInformationService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ReviewInformationService) getInstance(
        ReviewInformationService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description Submit the application review by Primary/Joint
   * @author Digital Align Team | 11-12-2021
   * @param Id applicationId
   * @return virtual
   **/
  global virtual Account reviewSubmit(Id applicationId) {
    Account application = ApplicationService.getInstance()
      .readApplicationWithChild(applicationId);

    String flowType = ApexRequest.getRequest().flowType;
    String applicantId = ApexRequest.getRequest().applicantId;

    return null;
  }
}
