// #2

HttpRequest req = new HttpRequest();
String requestBody = '{"itemData":{"Name":"MintFlow_LoanInfo","Priority":"High","SpecificContent":{"LoanID":"APP-1001"},"DeferDate":"2021-12-07T06:39:42.988Z","DueDate":"2021-12-07T06:39:42.988Z","RiskSlaDate":"2021-12-07T06:39:42.988Z","Reference":"string22034223","Progress":"New"}}';
req.setEndpoint(
  'callout:UiPath/digtalalign/P1FCUdev/orchestrator_/odata/Queues/UiPathODataSvc.AddQueueItem'
);
req.setMethod('POST');
req.setHeader('content-type', 'application/json');
req.setHeader('Accept', 'application/json');
req.setHeader('X-UIPATH-OrganizationUnitId', '323945');
req.setBody(requestBody);
Http http = new Http();
HTTPResponse res = http.send(req);
System.debug(res.getBody());
system.debug(HttpBuilder.getAPISetting());

// #4 // applicationFlow
ApexRequest request = new ApexRequest();
ApexRequest.setFlowType(ApplicationConstant.FLOW_TYPE_APPLICATION);
Account res = ApplicationService.getInstance()
  .readApplicationWithChild('0016D00000apNDpQAM');
System.debug(RpaProcessService.getInstance().scheduleApplication(res));

// #5 // fundingFlow
ApexRequest request = new ApexRequest();
ApexRequest.setFlowType(ApplicationConstant.FLOW_TYPE_FUNDING);
Account res = ApplicationService.getInstance()
  .readApplicationWithChild('0016D00000apNDpQAM');
System.debug(RpaProcessService.getInstance().scheduleApplication(res));
