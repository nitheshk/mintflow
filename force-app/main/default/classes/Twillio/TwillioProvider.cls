/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description Provider for sending SMS using Twillio API
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class TwillioProvider extends AbstractService {
  @TestVisible
  private static TwillioProvider serviceInstance;

  public TwillioProvider() {
    super(TwillioProvider.class);
  }
  /**
   * @description Provides a singleton instance of TwillioProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static TwillioProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (TwillioProvider) getInstance(TwillioProvider.class);
    }
    return serviceInstance;
  }

  /**
   * @description send message using twillio
   * @author Digital Align | 11-02-2021
   * @param Map<String object> params
   * @return virtual
   **/
  global virtual HttpBuilder.Response sendMessageUsingTwillio(
    Map<String, object> params
  ) {
    String otp = String.valueof(params.get('otp'));
    String messageText = System.Label.TwillioOtpFormat.replace('{OTP}', otp);
    String requestBody =
      'From=' +
      EncodingUtil.urlEncode(
        APIConfigurationService.getAPIConstants('FromPhone'),
        'UTF-8'
      ) +
      '&To=' +
      EncodingUtil.urlEncode(
        APIConfigurationService.getAPIConstants('Twillio_Country') +
        params.get('toPhone').toString(),
        'UTF-8'
      ) +
      '&Body=' +
      +EncodingUtil.urlEncode(messageText, 'UTF-8');

    log?.debug(' The request body is ' + requestBody);
    flow.setSubFlowRequest(requestBody);

    HttpResponse response = HttpBuilder.httpCallOut(
      requestBody,
      getHeader(params)
    );

    flow.setSubFlowResponse(response.getBody());
    log?.debug(' The response body is ' + response.getBody());

    if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
      throw new CustomException(response.getStatus());
    }

    return HttpBuilder.buildResponse(
      response.getStatusCode(),
      response.getStatus(),
      response.getBody()
    );
  }

  /**
   * @description get header for twillio api
   * @author Digital Align Team | 11-03-2021
   * @param Map<String object> params
   * @return Map<String, String>
   **/
  private Map<String, String> getHeader(Map<String, object> params) {
    Map<String, String> header = new Map<String, String>();
    header.put(
      'X-Twilio-Client',
      'salesforce-' + APIConfigurationService.getAPIConstants('Version')
    );
    header.put(
      'User-Agent',
      'twilio-salesforce-' + APIConfigurationService.getAPIConstants('Version')
    );
    header.put('Accept', 'application/json');
    header.put(
      'Authorization',
      'Basic ' +
      EncodingUtil.base64Encode(
        Blob.valueOf(
          APIConfigurationService.getAPIConstants('Twillio_Account') +
          ':' +
          APIConfigurationService.getAPIConstants('Twillio_Token')
        )
      )
    );
    return header;
  }
}
