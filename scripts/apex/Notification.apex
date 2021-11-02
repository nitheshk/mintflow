Map<String, Object> data = new Map<String, Object>();
dau01__Applicant__c applicant = new dau01__Applicant__c();
data.put('ApplicantId', 'a0a0w000001EvfeAAC');
object apiconst = new NotificationService().sendOTPMessage(data);
system.debug(apiconst);

Map<String, Object> params = new Map<String, Object>();
params.put('applicantId', 'a0a0w000001EvfeAAC');
params.put('OTP', 8267);
String apiconst = new IdentityService().verifyOTPMessage(params);
system.debug(apiconst);
