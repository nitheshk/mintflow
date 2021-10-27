/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class IdScanAnalyzerProvider extends AbstractAPIProvider {
  private IdScanAnalyzerDTO dto;
  public IdScanAnalyzerProvider() {
    super(IdScanAnalyzerProvider.class);
    dto = new IdScanAnalyzerDTO();
  }
  /**
   * @description
   * @author Digital Align | 10-27-2021
   * @param Map<String object> params
   * @return Map<String, object>
   **/
  public static Map<String, object> invokeAPI(Map<String, object> params) {
    try {
      if (params != null) {
        setApiConfiguration();
        return (new IdScanAnalyzerProvider()).executeRequest(params);
      } else {
        throw new CustomException('Empty Parameter Passed');
      }
    } catch (Exception ex) {
      return (new Map<String, object>{
        'Status' => '400',
        'StatusMessage' => ex.getMessage(),
        'Data' => null
      });
    }
  }
  /**
   * @description
   * @author Digital Align | 10-27-2021
   **/
  private static void setApiConfiguration() {
    if (
      APIConfigurationService.getAPISettings(APINames.IdScanAnalyzer)
        .isActive__c
    ) {
      APIConfigurationService.setAPISettings(APINames.IdScanAnalyzer);
    } else {
      throw new CustomException('API Name not found');
    }
  }
  /**
   * @description
   * @author Digital Align | 10-27-2021
   * @param Map<String object> params
   * @return String
   **/
  protected override String buildRequest(Map<String, object> params) {
    IdScanAnalyzerDTO.Request requestDTO = (IdScanAnalyzerDTO.Request) params.get(
      'DTO'
    );
    return dto.generateRequest(requestDTO, true);
  }
  /**
   * @description
   * @author Digital Align | 10-27-2021
   * @param Map<String object> params
   * @return Map<String, String>
   **/
  protected override Map<String, String> getHeader(Map<String, object> params) {
    {
      Map<String, String> header = new Map<String, String>();
      header.put('Content-Type', 'application/json');
      header.put('Accept', 'application/json');
      return header;
    }
  }
}
