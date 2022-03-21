@istest
global with sharing class RpaServiceMock implements HttpCalloutMock {
  private string className { get; set; }
  private string value { get; set; }
  public RpaServiceMock(String className, String value) {
    this.className = className;
    this.value = value;
  }
  global HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    switch on className {
      when 'OAuthProvider' {
        OAuthProvider(response);
      }
      when 'updatememberdetails' {
        updatememberdetails(response);
      }
      when 'updatememberdetailsFailed' {
        updatememberdetailsFailed(response);
      }
      when else {
        return null;
      }
    }
    return response;
  }
  private void OAuthProvider(HttpResponse response) {
    if (value.equalsIgnoreCase('200')) {
      response.setStatusCode(200);
      response.setBody(
        '{"access_token":"eyJhbGciOiJSUzI1NiIsImtpZCI6IkExRTAxNjE4MkYxMTI5QjMwNTIxOUY2OUQ2REY0N0UzMEQzRDJGQzJSUzI1NiIsInR5cCI6IkpXVCIsIng1dCI6Im9lQVdHQzhSS2JNRklaOXAxdDlINHcwOUw4SSJ9.eyJuYmYiOjE2NDczNDY4MDMsImV4cCI6MTY0NzM1MDcwMywiaXNzIjoiaHR0cHM6Ly9jbG91ZC51aXBhdGguY29tL2lkZW50aXR5XyIsImF1ZCI6IlVpUGF0aC5PcmNoZXN0cmF0b3IiLCJjbGllbnRfaWQiOiI3Njc1MzBlMi1mZGQ1LTQ0MGQtYmZhMy1lMDI3YTIyNjIzNmMiLCJwcnRfaWQiOiIyZmZkZTZhMy0wNzZlLTRiNDEtOGZhNC1jNGJkMDVkODRkODQiLCJqdGkiOiI2MjQzOEE3NEMxMzM5NkRDNjhCMURFNzMyOUIyNzdBMCIsImlhdCI6MTY0NzM0NzEwMywic2NvcGUiOlsiT1IuUXVldWVzLldyaXRlIl19.pXGqFy2dMlgbflxDmwYS2fLzGILBd3TU9pMDbJRUg3Kis5O7CJcTURL4YyeiZl6EkhqBffgr0SoYRJfS5XoKVly3tq7tY50KLC2GpNqAghAXd48VdfR4IIcOA22LqjlkA0zXjU_MuU1KOusiJMrrqIlF6K5QODFK530V-x36TcUva7Pfe65SX0T0bsI9xRyRRcxcehlimDQAqOh-tLZQGf1IESu40wICZRvP-_Q3KdSwEygUA97giMtP2dVgRym3BnN68ZLK3mj6UlrRYjnLjzNxkWKcILLIbvzUgSh4hmb9TRDonIi54-F6tl4aukNeEpemNayyO35mkQD8vS3EFQ","expires_in":3600,"token_type":"Bearer","scope":"OR.Queues.Write"}'
      );
    }
  }
  private void updatememberdetails(HttpResponse response) {
    if (value.equalsIgnoreCase('200')) {
      response.setStatusCode(200);
      response.setHeader('Content-Type', 'application/json');
      response.setBody(
        '{"@odata.context":"https://cloud.uipath.com/digtalalign/P1FCUdev/orchestrator_/odata/$metadata#QueueItems/$entity","QueueDefinitionId":50586,"OutputData":null,"AnalyticsData":null,"Status":"New","ReviewStatus":"None","ReviewerUserId":null,"Key":"30a6c685-e95e-453c-adff-9a2279f69774","Reference":"0010p0dccdHGbnDAAS","ProcessingExceptionType":null,"DueDate":null,"RiskSlaDate":null,"Priority":"High","DeferDate":null,"StartProcessing":null,"EndProcessing":null,"SecondsInPreviousAttempts":0,"AncestorId":null,"RetryNumber":0,"SpecificData":"{\"DynamicProperties\":{\"LoanID\":\"App-00014\"}}","CreationTime":"2022-03-15T12:25:28.228388Z","Progress":null,"RowVersion":"AAAAABP4vwI=","OrganizationUnitId":323945,"OrganizationUnitFullyQualifiedName":null,"Id":125031656,"ProcessingException":null,"SpecificContent":{"LoanID":"App-00014"},"Output":null,"Analytics":null}'
      );
    }
  }
  private void updatememberdetailsFailed(HttpResponse response) {
    if (value.equalsIgnoreCase('400')) {
      response.setStatusCode(400);
      response.setHeader('Content-Type', 'application/json');
      response.setBody(
        '{"@odata.context":"https://cloud.uipath.com/digtalalign/P1FCUdev/orchestrator_/odata/$metadata#QueueItems/$entity","QueueDefinitionId":50586,"OutputData":null,"AnalyticsData":null,"Status":"New","ReviewStatus":"None","ReviewerUserId":null,"Key":"30a6c685-e95e-453c-adff-9a2279f69774","Reference":"0010p0dccdHGbnDAAS","ProcessingExceptionType":null,"DueDate":null,"RiskSlaDate":null,"Priority":"High","DeferDate":null,"StartProcessing":null,"EndProcessing":null,"SecondsInPreviousAttempts":0,"AncestorId":null,"RetryNumber":0,"SpecificData":"{\"DynamicProperties\":{\"LoanID\":\"App-00014\"}}","CreationTime":"2022-03-15T12:25:28.228388Z","Progress":null,"RowVersion":"AAAAABP4vwI=","OrganizationUnitId":323945,"OrganizationUnitFullyQualifiedName":null,"Id":125031656,"ProcessingException":null,"SpecificContent":{"LoanID":"App-00014"},"Output":null,"Analytics":null}'
      );
    }
  }
}
