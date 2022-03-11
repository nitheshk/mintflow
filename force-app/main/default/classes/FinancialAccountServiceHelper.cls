/**
 * Copyright (c) 2021 Digital Align
 * @group Helper
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class FinancialAccountServiceHelper extends AbstractService {
  @TestVisible
  private static FinancialAccountServiceHelper serviceInstance;

  public FinancialAccountServiceHelper() {
    super(FinancialAccountServiceHelper.class);
  }

  /**
   * @description Provides a singleton instance of FinancialAccountServiceHelper from which all other class methods can be accessed.
   * @author Digital Align Team | 12/13/2021
   * @return Object  singleton
   **/
  public static FinancialAccountServiceHelper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (FinancialAccountServiceHelper) getInstance(FinancialAccountServiceHelper.class);
    }
    return serviceInstance;
  }
}
