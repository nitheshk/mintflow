/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Employment service
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

  /**
   * @description to perform AtomicFI Authentication for employment verification of an applicant
   * @author Digital Align Team | 10-26-2021
   * @param applicantId applicantId
   **/
  global virtual String atomicAuthenticate(
    String applicantId,
    String employerId
  ) {
    System.debug('inside employement service');
    String body = AtomicFIProvider.getInstance()
      .authenticate(applicantId, employerId);
    return body;
  }
  /**
   * @description Get  AtomicFI response of employment verification
   * @author Digital Align Team | 10-26-2021
   * @param applicantId applicantId
   * @param employerId employerId
   **/
  global virtual String getAtomicResponse(
    String applicantId,
    String employerId
  ) {
    String responseJson = AtomicFIProvider.getInstance()
      .getAtomicResponse(applicantId, employerId);
    return responseJson;
  }

  /**
   * @description Get  AtomicFI response of employment verification
   * @author Digital Align Team | 10-26-2021
   * @param applicantId applicantId
   * @param employerId employerId
   **/
  global virtual String generatePaySlipsW2(
    String applicantId,
    String employerId
  ) {
    String responseJson = AtomicFIProvider.getInstance()
      .generatePaySlipsW2(applicantId, employerId);
    return responseJson;
  }
}
