public with sharing class IdScanAnalyzerProvider extends AbstractAPIProvider {
  private GeocodingDTO dto;
  public IdScanAnalyzerProvider() {
    super(IdScanAnalyzerProvider.class);
  }
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
  protected override String buildRequest(Map<String, object> params) {
    IdScanAnalyzerDTO.Request requestDTO = (IdScanAnalyzerDTO.Request) params.get(
      'DTO'
    );
    return dto.generateRequest(requestDTO, true);
  }
  protected override Map<String, String> getHeader(Map<String, object> params) {
    {
      Map<String, String> header = new Map<String, String>();
      header.put('Content-Type', 'application/json');
      header.put('Accept', 'application/json');
      return header;
    }
  }
}
