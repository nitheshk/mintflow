public with sharing class SentiLinkAdapter {
  public static Map<String, object> invokeAPI(Map<String, object> params) {
    Map<String, Object> data = params.clone();
    try {
      if (params != null) {
        setApiConfiguration(data);
        return (new SentiLinkProvider()).executeRequest(data);
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
   * @param Map<String object> params
   * @return void
   **/
  private static void setApiConfiguration(Map<String, object> params) {
    system.debug('APIname = ' + (String.valueof(params.get('APIName'))));
    system.debug('APINames.SentiLinkScores = ' + APINames.SentiLinkScores);

    APIConfigurationService.setAPISettings(APINames.SentiLinkScores);
  }
}
