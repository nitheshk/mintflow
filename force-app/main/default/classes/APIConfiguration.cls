/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class APIConfiguration {
  public static APISetting__mdt apiConfig { get; set; }
  /**
   * @description
   * @author Digital Align | 08-12-2021
   * @return APISetting__mdt
   **/
  public static APISetting__mdt getAPIConfig() {
    if (apiConfig != null) {
      return apiConfig;
    } else {
      return (new APISetting__mdt());
    }
  }
  /**
   * @description
   * @author Digital Align | 08-12-2021
   * @param APINames apiName
   **/
  public static void setAPIConfig(APINames apiName) {
    apiConfig = APISetting__mdt.getInstance(apiName.name());
  }
}
