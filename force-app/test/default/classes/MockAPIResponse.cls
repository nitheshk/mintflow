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
    }
    return response;
  }

  private void sampleRequest(HttpResponse response) {
    if (value.equalsIgnoreCase('200')) {
      response.setStatusCode(200);
      response.setBody('');
    }
  }

  private void atomicFIRequest(HttpResponse response) {
    if (value.equalsIgnoreCase('200')) {
      response.setStatusCode(200);
      response.setBody('{"data":{"publicToken":"publicToken"}}');
    }
  }
}
