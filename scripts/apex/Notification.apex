Map<String, Object> data = new Map<String, Object>();
dau01__Applicant__c applicant = new dau01__Applicant__c();
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
    APIConfigurationService.getAPIConstants('Twillio_Country') + toPhone,
    'UTF-8'
  ) +
  '&Body=' +
  +EncodingUtil.urlEncode(messageText, 'UTF-8');
System.debug(' The request body is ' + requestBody);

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

APIConfigurationService.setAPISettings(APINames.TwillioMessaging);
APIConfigurationService.apiSetting.EndPoint__c = APIConfigurationService.apiSetting.EndPoint__c.replace(
  '{Twillio_Account}',
  APIConfigurationService.getAPIConstants('Twillio_Account')
);
APIConfigurationService.apiSetting.EndPoint__c = APIConfigurationService.apiSetting.EndPoint__c.replace(
  '{Version}',
  APIConfigurationService.getAPIConstants('Version')
);

HttpResponse response = ExternalAPICallOut.execute(requestBody, header);
system.debug(response.getBody());

//
Map<String, Object> header = new Map<String, Object>{
  'APIMapper' => APINames.TwillioMessaging
};
NotificationService ns = new NotificationService();
ns.sendOTPMessage(header);
