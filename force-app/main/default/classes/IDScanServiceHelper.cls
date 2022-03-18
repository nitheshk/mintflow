/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class IDScanServiceHelper extends AbstractService {
  @TestVisible
  private static IDScanServiceHelper serviceInstance;

  public IDScanServiceHelper() {
    super(IDScanServiceHelper.class);
  }

  /**
   * @description Provides a singleton instance of IDScanServiceHelper from which all other class methods can be accessed.
   * @author Digital Align Team | 03/18/2022
   * @return Object  singleton
   **/
  public static IDScanServiceHelper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (IDScanServiceHelper) getInstance(IDScanServiceHelper.class);
    }
    return serviceInstance;
  }
}
