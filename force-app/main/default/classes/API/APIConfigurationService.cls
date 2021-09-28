/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Service for API related metadata settings
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class APIConfigurationService extends AbstractService {
  @TestVisible
  private static APIConfigurationService serviceInstance;
  public static APISetting__mdt apiSetting { get; set; }

  public APIConfigurationService() {
    super(APIConfigurationService.class);
  }

  /**
   * @description Provides a singleton instance of APIConfigurationService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-12-2021
   * @return Object  singleton
   **/
  public static APIConfigurationService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (APIConfigurationService) getInstance(
        APIConfigurationService.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description returns value of API constants from metadata developer name.
   * @author Digital Align Team | 07-12-2021
   * @return String
   **/
  public static String getAPIConstants(String developerName) {
    APIConstant__mdt apiconstant = APIConfigurationRepository.getAPIconstants(
      developerName
    );

    return apiconstant.Value__c;
  }
  /**
   * @description set value of APISetting object.
   * @author Digital Align Team | 07-12-2021
   * @return void
   **/
  public static void setAPISettings(APINames apiMapper) {
    apiSetting = APIConfigurationRepository.setAPISettings(apiMapper);
  }

  public static APISetting__mdt getAPISettings() {
    if (apiSetting != null) {
      return apiSetting;
    } else {
      return (new APISetting__mdt());
    }
  }
}
