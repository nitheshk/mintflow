public with sharing class SentiLinkProvider extends AbstractAPIProvider {
  private SentiLinkDTO dto;
  public SentiLinkProvider() {
    super(SentiLinkProvider.class);
    dto = new SentiLinkDTO();
  }
  protected override String buildRequest(Map<String, object> params) {
    SentiLinkDTO.Request requestDTO = (SentiLinkDTO.Request) params.get('DTO');
    return dto.generateRequest(requestDTO, true);
  }
  protected override Map<String, String> getHeader(Map<String, object> params) {
    Map<String, String> header = new Map<String, String>();
    header.put('Content-Type', 'application/json');
    header.put('Accept', 'application/json');
    header.put(
      'Authorization',
      'Basic ' +
      EncodingUtil.base64Encode(
        Blob.valueOf(
          APIConfigurationService.getAPIConstants('SentiLinkAccount') +
          ':' +
          (APIConfigurationService.getAPIConstants('SentiLinkToken'))
        )
      )
    );

    return header;
  }
  protected override Object parseResponse(String reponseBody) {
    // parse respose body
    return dto.parse(reponseBody);
  }
}
