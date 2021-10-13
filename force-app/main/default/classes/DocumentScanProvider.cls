/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class DocumentScanProvider extends AbstractAPIProvider {
  public DocumentScanProvider() {
    super(DocumentScanProvider.class);
  }
  /**
   * @description
   * @author Digital Align | 08-12-2021
   * @param Map<String object> params
   * @return String
   **/
  protected override String buildRequest(Map<String, object> params) {
    blob file = (blob) params.get('file');
    String authKey = 'cc813132-58b3-445e-8a56-305e6b77a285';
    String requestBody =
      '{"authKey":"' +
      authKey +
      '", "data" : "' +
      EncodingUtil.base64Encode(file) +
      '"}';

    return requestBody;
  }

  protected override Map<String, String> getHeader(Map<String, object> params) {
    return null;
  }
}
