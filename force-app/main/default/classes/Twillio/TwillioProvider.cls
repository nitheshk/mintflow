/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description Provider for sending SMS using Twillio API
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class TwillioProvider extends AbstractService {
  public static Integer OTPNumber { get; set; }
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
   * @description
   * @author Digital Align | 11-02-2021
   * @param Map<String object> params
   * @return virtual
   **/
  global virtual HttpBuilder.Response sendMessageUsingTwillio(
    Map<String, object> params
  ) {
    log
      ?.fine(
        'Inside sendMessageUsingTwillio -> params -> ' + Json.serialize(params)
      );
    system.debug('in provider params =' + params);
    //header
    Map<String, String> header = new Map<String, String>();
    header.put('X-Twilio-Client', 'salesforce-' + params.get('Version'));
    header.put('User-Agent', 'twilio-salesforce-' + params.get('Version'));
    header.put('Accept', 'application/json');
    header.put(
      'Authorization',
      'Basic ' +
      EncodingUtil.base64Encode(
        Blob.valueOf(
          params.get('Twillio_Account') +
          ':' +
          params.get('Twillio_Token')
        )
      )
    );
    system.debug('in provider header =' + header);
    //request
    String OTPText = String.valueof(params.get('OTP'));
    String messageText = System.Label.CustomerOTPMessage.replace(
      '[OTP]',
      OTPText
    );
    String toPhone = (String) params.get('Phone');
    String requestBody =
      '' +
      'From=' +
      EncodingUtil.urlEncode(String.valueof(params.get('FromPhone')), 'UTF-8') +
      '&To=' +
      EncodingUtil.urlEncode(
        String.valueof(params.get('CountryCode')) + tophone,
        'UTF-8'
      ) +
      '&Body=' +
      +EncodingUtil.urlEncode(messageText, 'UTF-8');
    System.debug(' The request body is ' + requestBody);

    HttpResponse response = HttpBuilder.httpCallOut(
      json.serialize(requestBody),
      header
    );
    system.debug('response =' + response.getStatusCode());
    system.debug('response =' + response.getBody());
    if (response.getStatusCode() != 200) {
      throw new CustomException(response.getStatus());
    }

    return HttpBuilder.buildResponse(
      response.getStatusCode(),
      response.getStatus(),
      response.getBody()
    );
  }

  // protected override String buildRequest(Map<String, object> params) {
  //   String OTPText = String.valueof(params.get('OTP'));
  //   String messageText = System.Label.CustomerOTPMessage.replace(
  //     '[OTP]',
  //     OTPText
  //   );
  //   String toPhone = (String) params.get('Phone');
  //   String requestBody =
  //     '' +
  //     'From=' +
  //     EncodingUtil.urlEncode(String.valueof(params.get('FromPhone')), 'UTF-8') +
  //     '&To=' +
  //     EncodingUtil.urlEncode(
  //       String.valueof(params.get('CountryCode')) + tophone,
  //       'UTF-8'
  //     ) +
  //     '&Body=' +
  //     +EncodingUtil.urlEncode(messageText, 'UTF-8');
  //   System.debug(' The request body is ' + requestBody);
  //   return requestBody;
  // // }

  // public override Map<String, Object> executeRequest(
  //   Map<String, object> params
  // ) {
  //   switch on ((APINames) params.get('APIMapper')) {
  //     when TwillioMessaging {
  //       return super.executeRequest(params);
  //     }
  //     when else {
  //       throw new CustomException('Undefined Mapper for the API call');
  //     }
  //   }
  // }

  // protected override Map<String, String> getHeader(Map<String, object> params) {
  //   switch on ((APINames) params.get('APIMapper')) {
  //     when TwillioMessaging {
  //       Map<String, String> header = new Map<String, String>();
  //       header.put('X-Twilio-Client', 'salesforce-' + params.get('Version'));
  //       header.put('User-Agent', 'twilio-salesforce-' + params.get('Version'));
  //       header.put('Accept', 'application/json');
  //       header.put(
  //         'Authorization',
  //         'Basic ' +
  //         EncodingUtil.base64Encode(
  //           Blob.valueOf(
  //             params.get('Twillio_Account') +
  //             ':' +
  //             params.get('Twillio_Token')
  //           )
  //         )
  //       );
  //       return header;
  //     }
  //     when else {
  //       return null;
  //     }
  //   }
  // }
}

// /**
//  * Copyright (c) 2021 Digital Align
//  * @group Provider
//  * @author Digital Align Team
//  * @reference
//  * @description Provider for sending SMS using Twillio API
//  **/

// global with sharing class TwillioProvider extends AbstractAPIProvider {
//   public static Integer OTPNumber { get; set; }
//   public TwillioProvider() {
//     super(TwillioProvider.class);
//   }

//   protected override String buildRequest(Map<String, object> params) {
//     String OTPText = String.valueof(params.get('OTP'));
//     String messageText = System.Label.DealerOTPMessage.replace(
//       '[OTP]',
//       OTPText
//     );
//     String toPhone = (String) params.get('Phone');
//     String requestBody =
//       '' +
//       'From=' +
//       EncodingUtil.urlEncode(String.valueof(params.get('FromPhone')), 'UTF-8') +
//       '&To=' +
//       EncodingUtil.urlEncode(
//         String.valueof(params.get('CountryCode')) + tophone,
//         'UTF-8'
//       ) +
//       '&Body=' +
//       +EncodingUtil.urlEncode(messageText, 'UTF-8');
//     System.debug(' The request body is ' + requestBody);
//     return requestBody;
//   }

//   public override Map<String, Object> executeRequest(
//     Map<String, object> params
//   ) {
//     switch on ((APINames) params.get('APIMapper')) {
//       when TwillioMessaging {
//         return super.executeRequest(params);
//       }
//       when else {
//         throw new CustomException('Undefined Mapper for the API call');
//       }
//     }
//   }

//   protected override Map<String, String> getHeader(Map<String, object> params) {
//     switch on ((APINames) params.get('APIMapper')) {
//       when TwillioMessaging {
//         Map<String, String> header = new Map<String, String>();
//         header.put('X-Twilio-Client', 'salesforce-' + params.get('Version'));
//         header.put('User-Agent', 'twilio-salesforce-' + params.get('Version'));
//         header.put('Accept', 'application/json');
//         header.put(
//           'Authorization',
//           'Basic ' +
//           EncodingUtil.base64Encode(
//             Blob.valueOf(
//               params.get('Twillio_Account') +
//               ':' +
//               params.get('Twillio_Token')
//             )
//           )
//         );
//         return header;
//       }
//       when else {
//         return null;
//       }
//     }
//   }
// }

