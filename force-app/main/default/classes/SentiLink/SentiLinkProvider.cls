public with sharing class SentiLinkProvider extends AbstractAPIProvider {
  private SentiLinkDTO dto;
  public SentiLinkProvider() {
    super(SentiLinkProvider.class);
  }
  protected override String buildRequest(Map<String, object> params) {
    string request = '{"application": {"phone" : "4155550000","email" : "johndoe@email.com","user_id": "849228","first_name": "John","last_name": "Doe","dob": "1990-01-01","ssn": "123-45-6789","address_line_1": "123 Main Street","city": "Pleasantville","zipcode": "32407","state_code": "CA","application_id": "APP-10848","application_created": "2019-05-02T15:23:10"},"scores": [{"score_name": "sentilink_abuse_score"},{"score_name": "sentilink_first_party_synthetic_score"},{"score_name": "sentilink_third_party_synthetic_score"},{"score_name": "sentilink_id_theft_score"}]}';
    return request;
    // SentiLinkDTO.Request request = (SentiLinkDTO.Request) params.get('DTO');
    // return dto.generateRequest(request);
  }
  protected override Map<String, String> getHeader(Map<String, object> params) {
    Map<String, String> header = new Map<String, String>();
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
  // public override Map<String, Object> executeRequest(
  //   Map<String, object> params
  // ) {
  //   switch on ((APINames) params.get('APIMapper')) {
  //     when SentiLinkScores {
  //       return super.executeRequest(params);
  //     }
  //     when SentiLinkIdCompletion {
  //       return super.executeRequest(params);
  //     }
  //     when else {
  //       throw new CustomException('Undefined Mapper for the API call');
  //     }
  //   }
  // }
}
