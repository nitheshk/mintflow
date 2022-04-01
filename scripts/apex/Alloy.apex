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
request.token = SecurityUtils.generateTokenForTesting('a020p000009cytTAAQ', 'a000p000008liO7AAI', 'Primary', 'ApplicationFlow');
system.debug(request.token);

ApexRequest request = new ApexRequest();
request.token = 'pyh8mYAVjrnj1iy5gF7JFK47w+KxidbycgQrn9aXie8bVMnJ0tILYn5zM5yBWdXbbsNIQgMwRkn3YhRkvSKoXAaiBuaXNGTOR+Un/dnxwJvRFaWvZ8O1ua1LZyBge2BvZiESHwwNE1j5ftgj0VVxXw==';
ApexResponse res = ApplicantController.verifyKYC(request);
system.debug('Full Json : ' + res.data);
