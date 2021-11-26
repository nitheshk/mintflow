Map<String, Object> data = new Map<String, Object>();
mflow__Applicant__c applicant = new mflow__Applicant__c();
data.put('ApplicantId', 'a0b9D000002h0JcQAI');
object apiconst = new NotificationService().sendOTPMessage(data);
system.debug(apiconst);
logger.persist();

Map<String, Object> params = new Map<String, Object>();
params.put('applicantId', 'a0a0w000001EvfeAAC');
params.put('OTP', 8267);
String apiconst = new IdentityService().verifyOTPMessage(params);
system.debug(apiconst);

String messageText = 'Test Message';
String toPhone = '7892981668';
String requestBody =
  '' +
  'From=' +
  EncodingUtil.urlEncode('+14195185222', 'UTF-8') +
  '&To=' +
  EncodingUtil.urlEncode(
    HttpBuilder.getApiConstant('Twillio_Country') + toPhone,
    'UTF-8'
  ) +
  '&Body=' +
  +EncodingUtil.urlEncode(messageText, 'UTF-8');
System.debug(' The request body is ' + requestBody);

Map<String, String> header = new Map<String, String>();
header.put(
  'X-Twilio-Client',
  'salesforce-' + HttpBuilder.getApiConstant('Version')
);
header.put(
  'User-Agent',
  'twilio-salesforce-' + HttpBuilder.getApiConstant('Version')
);
header.put('Accept', 'application/json');
header.put(
  'Authorization',
  'Basic ' +
  EncodingUtil.base64Encode(
    Blob.valueOf(
      HttpBuilder.getApiConstant('Twillio_Account') +
      ':' +
      HttpBuilder.getApiConstant('Twillio_Token')
    )
  )
);

HttpBuilder.setAPISetting(APINames.TwillioMessaging);
HttpBuilder.replaceEndpoint(
  '{Twillio_Account}',
  HttpBuilder.getApiConstant('Twillio_Account')
);
HttpBuilder.replaceEndpoint('{Version}', HttpBuilder.getApiConstant('Version'));
HttpResponse response = HttpBuilder.httpCallOut(requestBody, header);
system.debug(response.getBody());

//
Map<String, Object> header = new Map<String, Object>{
  'APIMapper' => APINames.TwillioMessaging
};
NotificationService ns = new NotificationService();
ns.sendOTPMessage(header);
