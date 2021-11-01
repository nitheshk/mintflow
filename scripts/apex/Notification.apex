Map<String, Object> data = new Map<String, Object>();
dau01__Applicant__c applicant = new dau01__Applicant__c();
data.put('ApplicantId', 'a0a0w000001EvfeAAC');
String apiconst = new NotificationService().sendOTPMessage(data);

Map<String, Object> params = new Map<String, Object>();
params.put('ApplicantId', 'a0a0w000001EvfeAAC');
params.put('OTP', 8793);
String apiconst = new NotificationService().verifyOTPMessage(params);
system.debug(apiconst);
