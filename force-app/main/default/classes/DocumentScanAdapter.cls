/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class DocumentScanAdapter {
  /**
   * @description
   * @author Digital Align | 08-12-2021
   * @param Map<String object> params
   * @return Map<String, object>
   **/
  public static Map<String, object> invokeAPI(Map<String, object> params) {
    try {
      if (params == null) {
        throw new CustomException('Empty Parameter');
      }
      APIConfiguration.setAPIConfig(APINames.DOCUMENTSCAN);
      Map<String, object> data = params.clone();
      return (new DocumentScanProvider()).executeRequest(data);
    } catch (exception e) {
      throw e;
    }
  }
}
