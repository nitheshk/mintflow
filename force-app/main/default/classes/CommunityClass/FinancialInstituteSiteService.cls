/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Financial Institute Site Service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class FinancialInstituteSiteService extends AbstractService {
  @TestVisible
  private static FinancialInstituteSiteService serviceInstance;

  public FinancialInstituteSiteService() {
    super(FinancialInstituteSiteService.class);
  }

  /**
   * @description Provides a singleton instance of FinancialInstituteSiteService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static FinancialInstituteSiteService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (FinancialInstituteSiteService) getInstance(
        FinancialInstituteSiteService.class
      );
    }
    return serviceInstance;
  }
}
