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
  EncodingUtil.urlEncode(HttpBuilder.getApiConstant('Twillio_Country') + toPhone, 'UTF-8') +
  '&Body=' +
  +EncodingUtil.urlEncode(messageText, 'UTF-8');
System.debug(' The request body is ' + requestBody);

Map<String, String> header = new Map<String, String>();
header.put('X-Twilio-Client', 'salesforce-' + HttpBuilder.getApiConstant('Version'));
header.put('User-Agent', 'twilio-salesforce-' + HttpBuilder.getApiConstant('Version'));
header.put('Accept', 'application/json');
header.put(
  'Authorization',
  'Basic ' +
  EncodingUtil.base64Encode(
    Blob.valueOf(HttpBuilder.getApiConstant('Twillio_Account') + ':' + HttpBuilder.getApiConstant('Twillio_Token'))
  )
);

HttpBuilder.setAPISetting(APINames.TwillioMessaging);
HttpBuilder.replaceEndpoint('{Twillio_Account}', HttpBuilder.getApiConstant('Twillio_Account'));
HttpBuilder.replaceEndpoint('{Version}', HttpBuilder.getApiConstant('Version'));
HttpResponse response = HttpBuilder.httpCallOut(requestBody, header);
system.debug(response.getBody());

//
Map<String, Object> header = new Map<String, Object>{ 'APIMapper' => APINames.TwillioMessaging };
NotificationService ns = new NotificationService();
ns.sendOTPMessage(header);

// #4

String notificationTypeId = CommonRepository.readNotificationType('MintFlowNotification')?.Id;
Messaging.CustomNotification notification = new Messaging.CustomNotification();
notification.setTitle('title');
notification.setBody('body');
notification.setSenderId(Userinfo.getUserId());
notification.setNotificationTypeId(notificationTypeId);
notification.setTargetId('a0bN000000EZR1WIAX');
notification.send(new Set<String>{ NotificationBuilder.getRegularGroupId('OnKycSuccess') });

//

Map<String, String> params = new Map<String, String>{
  'aplType' => 'Joint',
  'flw' => 'JointFlow',
  'urlSuffix' => '/welcome',
  'aplId' => 'a0bN000000EZR1mIAH',
  'ch' => 'Virtual'
};

Map<String, String> params = new Map<String, String>{
  'aplType' => 'Primary',
  'flw' => 'FundingFlow',
  'urlSuffix' => '/otp',
  'aplId' => 'a0bN000000EZR1gIAH',
  'ch' => 'Virtual'
};

Map<String, String> params = new Map<String, String>{
  'aplType' => 'Primary',
  'flw' => 'ApplicationFlow',
  'urlSuffix' => '/other/resume/otp',
  'aplId' => 'a0bN000000EZR2ZIAX',
  'ch' => 'Virtual'
};

SecurityUtils.CipherDTO cipher = new SecurityUtils.CipherDTO();
cipher.aplType = params.get('aplType');
cipher.flw = params.get('flw');
String urlSuffix = params.get('urlSuffix');
cipher.appId = ApexRequest.getApplicationId();
cipher.aplId = params.get('aplId');
cipher.edt = Datetime.now().addHours((Integer) ApplicationConfiguration__c.getInstance().EmailLinkExpirationTime__c);
cipher.ch = params.get('ch');

String link =
  SiteSetting__c.getInstance().OnlineSiteUrl__c +
  '/OpenAccount' +
  '?vmf=' +
  SecurityUtils.encryptUrl(JSON.serialize(cipher, true)) +
  '&vue=' +
  EncodingUtil.urlEncode(urlSuffix, 'UTF-8');

system.debug(link);
