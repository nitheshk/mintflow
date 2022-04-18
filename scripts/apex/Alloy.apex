ApexRequest request = new ApexRequest();
request.applicantId = 'a000p000008liO7AAI';
request.applicationId = 'a020p000009cytTAAQ';

ApexResponse res = ApplicantController.verifyKYC(request);
//========================================
HttpRequest req = new HttpRequest();
req.setEndpoint('callout:AlloyKYC');
req.setMethod('POST');
Http http = new Http();
HTTPResponse res = http.send(req);
System.debug(res.getBody());
//============================================

ApexRequest request = new ApexRequest();
request.token = SecurityUtils.generateTokenForTesting(
  'a020w000007EK0yAAG',
  'a000w000005UqqBAAS',
  'Primary',
  'ApplicationFlow'
);
system.debug(request.token);

ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFK47w+KxidbycgQrn9aXie/fSISX3xmsYujSo7TXWikRijE97EsG+NYyw9O4Q5MPG72+mG286no8c62L0/vPsftOVGT7enkLYry0e+Tl9eFzb06WTR/bk1ZtGHsmLP2tWg==';
ApexResponse res = ApplicantController.verifyKYC(request);
system.debug('Full Json : ' + res.data);

ApexRequest request = new ApexRequest(request);
request.token = 'pyh8mYAVjrnj1iy5gF7JFK47w+KxidbycgQrn9aXie/fSISX3xmsYujSo7TXWikRijE97EsG+NYyw9O4Q5MPG72+mG286no8c62L0/vPsftOVGT7enkLYry0e+Tl9eFzb06WTR/bk1ZtGHsmLP2tWg==';
ApexResponse res = ApplicantController.getBaseURL();
system.debug('Full Json : ' + res.data);
