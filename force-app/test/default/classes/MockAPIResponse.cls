@isTest
public with sharing class MockAPIResponse implements HttpCalloutMock {
  private string className { get; set; }
  private string value { get; set; }
  public MockAPIResponse(String className, String value) {
    this.className = className;
    this.value = value;
  }
  public HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    switch on className {
      when 'SampleRequest' {
        sampleRequest(response);
      }
      when 'AtomicFIRequest' {
        atomicFIRequest(response);
      }
      when 'RpaReviewQueue' {
        rpaReviewQueue(response, request);
      }
    }
    return response;
  }
  //sampleRequest
  private void sampleRequest(HttpResponse response) {
    if (value.equalsIgnoreCase('200')) {
      response.setStatusCode(200);
      response.setBody('');
    }
  }
  //atomicFIRequest
  private void atomicFIRequest(HttpResponse response) {
    if (value.equalsIgnoreCase('200')) {
      response.setStatusCode(200);
      response.setBody('{"data":{"publicToken":"publicToken"}}');
    }
  }
  //rpaReviewQueue
  private void rpaReviewQueue(HttpResponse response, HttpRequest request) {
    if (value.equalsIgnoreCase('ReviewSubmit_200')) {
      response.setStatusCode(200);
      if (HttpBuilder.getAPISetting().DeveloperName == APINames.UiPath.name()) {
        response.setBody(
          '{"access_token":"access_token","expires_in":3600,"token_type":"Bearer","scope":"OR.Queues.Write"}'
        );
      } else if (request.getEndpoint().endsWith('/UiPathODataSvc.AddQueueItem')) {
        response.setStatusCode(201);
        response.setBody(
          '{"QueueDefinitionId":50586,"Status":"New","ReviewStatus":"None","Id":128070509,"SpecificContent":{"LoanID":"App-0011"}}'
        );
      }
    }
  }
}
