ApexRequest request = new ApexRequest();
ApexRequest.SetapplicantId('a000p000008liO7AAI');
ApexRequest.SetapplicationId('a020p000009cytTAAQ');
ApexResponse res = ApplicantController.verifyKYC(request);

HttpRequest req = new HttpRequest();
req.setEndpoint('callout:AlloyKYC');
req.setMethod('POST');
Http http = new Http();
HTTPResponse res = http.send(req);
System.debug(res.getBody());
