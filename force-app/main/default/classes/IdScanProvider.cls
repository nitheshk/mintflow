/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description IdScanProvider to perform customer due diligence
 **/
global with sharing class IdScanProvider extends AbstractService {
  @TestVisible
  private static IdScanProvider serviceInstance;

  public IdScanProvider() {
    super(IdScanProvider.class);
  }

  public static IdScanProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (IdScanProvider) getInstance(IdScanProvider.class);
    }
    return serviceInstance;
  }

  public static String customerDueDiligence(String applicantId) {
    return '';
  }
}
