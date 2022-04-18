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
      when 'PlaidRequest' {
        PlaidRequest(response);
      }
      when 'PlaidRequestFailed' {
        PlaidRequestFailed(response);
      }
      when 'PlaidExchangeToken' {
        PlaidExchangeToken(response);
      }
      when 'PlaidExchangeTokenFailed' {
        PlaidExchangeTokenFailed(response);
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
  //PlaidRequest
  private void PlaidRequest(HttpResponse response) {
    if (value.equalsIgnoreCase('200')) {
      response.setStatusCode(200);
      response.setBody(
        '{"accounts":[{"account_id":"GP7rbAmvxvFWyPe9E5pQTNzG7QrxxPfnBmAzn","balances":{"available":100,"current":110,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"0000","name":"Plaid Checking","official_name":"Plaid Gold Standard 0% Interest Checking","subtype":"checking","type":"depository"},{"account_id":"nVNqmejaQatJNDbyqK7zFa8XbZp44EIGerKLE","balances":{"available":200,"current":210,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"1111","name":"Plaid Saving","official_name":"Plaid Silver Standard 0.1% Interest Saving","subtype":"savings","type":"depository"},{"account_id":"bV5berqvzvt8me1Eg4JBSqLo7PzyyKH3xaNME","balances":{"available":null,"current":1000,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"2222","name":"Plaid CD","official_name":"Plaid Bronze Standard 0.2% Interest CD","subtype":"cd","type":"depository"},{"account_id":"mV4lW7PdXdtjmMbolqwkidqlE3W44NtAmxMVr","balances":{"available":null,"current":410,"iso_currency_code":"USD","limit":2000,"unofficial_currency_code":null},"mask":"3333","name":"Plaid Credit Card","official_name":"Plaid Diamond 12.5% APR Interest Credit Card","subtype":"credit card","type":"credit"},{"account_id":"WGb1wV9vyvuMladxW5mASp47prX4rAc49nwJx","balances":{"available":43200,"current":43200,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"4444","name":"Plaid Money Market","official_name":"Plaid Platinum Standard 1.85% Interest Money Market","subtype":"money market","type":"depository"},{"account_id":"A3dD56m8k8sPL3areZM7u1Re1GgRGwuojZ6n3","balances":{"available":null,"current":320.76,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"5555","name":"Plaid IRA","official_name":null,"subtype":"ira","type":"brokerage"},{"account_id":"GP7rbAmvxvFWyPe9E5pQTNzoN1Xz1ainBmAzj","balances":{"available":null,"current":23631.9805,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"6666","name":"Plaid 401k","official_name":null,"subtype":"401k","type":"brokerage"},{"account_id":"nVNqmejaQatJNDbyqK7zFa8laL98LjUGerKLp","balances":{"available":null,"current":65262,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"7777","name":"Plaid Student Loan","official_name":null,"subtype":"student","type":"loan"},{"account_id":"bV5berqvzvt8me1Eg4JBSqLXqkWLkZS3xaNMR","balances":{"available":null,"current":56302.06,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"8888","name":"Plaid Mortgage","official_name":null,"subtype":"mortgage","type":"loan"}],"item":{"available_products":["assets","balance","credit_details","identity","income","investments","liabilities","transactions"],"billed_products":["auth"],"consent_expiration_time":null,"error":null,"institution_id":"ins_3","item_id":"48XEwDPNkNfABn8pjEKNH1wn53lakvIdkyaVB","optional_products":null,"products":["auth"],"update_type":"background","webhook":""},"numbers":{"ach":[{"account":"1111222233330000","account_id":"GP7rbAmvxvFWyPe9E5pQTNzG7QrxxPfnBmAzn","routing":"011401533","wire_routing":"021000021"},{"account":"1111222233331111","account_id":"nVNqmejaQatJNDbyqK7zFa8XbZp44EIGerKLE","routing":"011401533","wire_routing":"021000021"}],"eft":[]},"request_id":"O3H1XbUMwLQgbgp"}'
      );
    }
  }
  //PlaidRequestFailed
  private void PlaidRequestFailed(HttpResponse response) {
    if (value.equalsIgnoreCase('400')) {
      response.setStatusCode(400);
      response.setBody('');
    }
  }
  //PlaidExchangeToken
  private void PlaidExchangeToken(HttpResponse response) {
    if (value.equalsIgnoreCase('200')) {
      response.setStatusCode(200);
      response.setBody(
        '{"access_token":"access-sandbox-ce4aa453-eb68-45cc-9efa-f0f9ea620bc5","item_id":"48XEwDPNkNfABn8pjEKNH1wn53lakvIdkyaVB","request_id":"yxXu6b7tvJu67MT"}'
      );
    }
  }
  //PlaidExchangeTokenFailed
  private void PlaidExchangeTokenFailed(HttpResponse response) {
    if (value.equalsIgnoreCase('400')) {
      response.setStatusCode(400);
      response.setBody('');
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
  private void Plaid(HttpResponse response, HttpRequest request) {
    if (value.equalsIgnoreCase('200')) {
      response.setStatusCode(200);
      if (request.getEndpoint().endsWith('mflow__Plaid/item/public_token/exchange')) {
        response.setBody(
          '{"access_token":"access-sandbox-ce4aa453-eb68-45cc-9efa-f0f9ea620bc5","item_id":"48XEwDPNkNfABn8pjEKNH1wn53lakvIdkyaVB","request_id":"yxXu6b7tvJu67MT"}'
        );
      } else if (request.getEndpoint().endsWith('mflow__Plaid/auth/get')) {
        response.setStatusCode(200);
        response.setBody(
          '{"accounts":[{"account_id":"GP7rbAmvxvFWyPe9E5pQTNzG7QrxxPfnBmAzn","balances":{"available":100,"current":110,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"0000","name":"Plaid Checking","official_name":"Plaid Gold Standard 0% Interest Checking","subtype":"checking","type":"depository"},{"account_id":"nVNqmejaQatJNDbyqK7zFa8XbZp44EIGerKLE","balances":{"available":200,"current":210,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"1111","name":"Plaid Saving","official_name":"Plaid Silver Standard 0.1% Interest Saving","subtype":"savings","type":"depository"},{"account_id":"bV5berqvzvt8me1Eg4JBSqLo7PzyyKH3xaNME","balances":{"available":null,"current":1000,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"2222","name":"Plaid CD","official_name":"Plaid Bronze Standard 0.2% Interest CD","subtype":"cd","type":"depository"},{"account_id":"mV4lW7PdXdtjmMbolqwkidqlE3W44NtAmxMVr","balances":{"available":null,"current":410,"iso_currency_code":"USD","limit":2000,"unofficial_currency_code":null},"mask":"3333","name":"Plaid Credit Card","official_name":"Plaid Diamond 12.5% APR Interest Credit Card","subtype":"credit card","type":"credit"},{"account_id":"WGb1wV9vyvuMladxW5mASp47prX4rAc49nwJx","balances":{"available":43200,"current":43200,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"4444","name":"Plaid Money Market","official_name":"Plaid Platinum Standard 1.85% Interest Money Market","subtype":"money market","type":"depository"},{"account_id":"A3dD56m8k8sPL3areZM7u1Re1GgRGwuojZ6n3","balances":{"available":null,"current":320.76,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"5555","name":"Plaid IRA","official_name":null,"subtype":"ira","type":"brokerage"},{"account_id":"GP7rbAmvxvFWyPe9E5pQTNzoN1Xz1ainBmAzj","balances":{"available":null,"current":23631.9805,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"6666","name":"Plaid 401k","official_name":null,"subtype":"401k","type":"brokerage"},{"account_id":"nVNqmejaQatJNDbyqK7zFa8laL98LjUGerKLp","balances":{"available":null,"current":65262,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"7777","name":"Plaid Student Loan","official_name":null,"subtype":"student","type":"loan"},{"account_id":"bV5berqvzvt8me1Eg4JBSqLXqkWLkZS3xaNMR","balances":{"available":null,"current":56302.06,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"8888","name":"Plaid Mortgage","official_name":null,"subtype":"mortgage","type":"loan"}],"item":{"available_products":["assets","balance","credit_details","identity","income","investments","liabilities","transactions"],"billed_products":["auth"],"consent_expiration_time":null,"error":null,"institution_id":"ins_3","item_id":"48XEwDPNkNfABn8pjEKNH1wn53lakvIdkyaVB","optional_products":null,"products":["auth"],"update_type":"background","webhook":""},"numbers":{"ach":[{"account":"1111222233330000","account_id":"GP7rbAmvxvFWyPe9E5pQTNzG7QrxxPfnBmAzn","routing":"011401533","wire_routing":"021000021"},{"account":"1111222233331111","account_id":"nVNqmejaQatJNDbyqK7zFa8XbZp44EIGerKLE","routing":"011401533","wire_routing":"021000021"}],"eft":[]},"request_id":"O3H1XbUMwLQgbgp"}'
        );
      } else if (request.getEndpoint().endsWith('/mflow__Plaid/institutions/get_by_id')) {
        response.setStatusCode(200);
        response.setBody(
          '{"accounts":[{"account_id":"GP7rbAmvxvFWyPe9E5pQTNzG7QrxxPfnBmAzn","balances":{"available":100,"current":110,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"0000","name":"Plaid Checking","official_name":"Plaid Gold Standard 0% Interest Checking","subtype":"checking","type":"depository"},{"account_id":"nVNqmejaQatJNDbyqK7zFa8XbZp44EIGerKLE","balances":{"available":200,"current":210,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"1111","name":"Plaid Saving","official_name":"Plaid Silver Standard 0.1% Interest Saving","subtype":"savings","type":"depository"},{"account_id":"bV5berqvzvt8me1Eg4JBSqLo7PzyyKH3xaNME","balances":{"available":null,"current":1000,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"2222","name":"Plaid CD","official_name":"Plaid Bronze Standard 0.2% Interest CD","subtype":"cd","type":"depository"},{"account_id":"mV4lW7PdXdtjmMbolqwkidqlE3W44NtAmxMVr","balances":{"available":null,"current":410,"iso_currency_code":"USD","limit":2000,"unofficial_currency_code":null},"mask":"3333","name":"Plaid Credit Card","official_name":"Plaid Diamond 12.5% APR Interest Credit Card","subtype":"credit card","type":"credit"},{"account_id":"WGb1wV9vyvuMladxW5mASp47prX4rAc49nwJx","balances":{"available":43200,"current":43200,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"4444","name":"Plaid Money Market","official_name":"Plaid Platinum Standard 1.85% Interest Money Market","subtype":"money market","type":"depository"},{"account_id":"A3dD56m8k8sPL3areZM7u1Re1GgRGwuojZ6n3","balances":{"available":null,"current":320.76,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"5555","name":"Plaid IRA","official_name":null,"subtype":"ira","type":"brokerage"},{"account_id":"GP7rbAmvxvFWyPe9E5pQTNzoN1Xz1ainBmAzj","balances":{"available":null,"current":23631.9805,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"6666","name":"Plaid 401k","official_name":null,"subtype":"401k","type":"brokerage"},{"account_id":"nVNqmejaQatJNDbyqK7zFa8laL98LjUGerKLp","balances":{"available":null,"current":65262,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"7777","name":"Plaid Student Loan","official_name":null,"subtype":"student","type":"loan"},{"account_id":"bV5berqvzvt8me1Eg4JBSqLXqkWLkZS3xaNMR","balances":{"available":null,"current":56302.06,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"8888","name":"Plaid Mortgage","official_name":null,"subtype":"mortgage","type":"loan"}],"item":{"available_products":["assets","balance","credit_details","identity","income","investments","liabilities","transactions"],"billed_products":["auth"],"consent_expiration_time":null,"error":null,"institution_id":"ins_3","item_id":"48XEwDPNkNfABn8pjEKNH1wn53lakvIdkyaVB","optional_products":null,"products":["auth"],"update_type":"background","webhook":""},"numbers":{"ach":[{"account":"1111222233330000","account_id":"GP7rbAmvxvFWyPe9E5pQTNzG7QrxxPfnBmAzn","routing":"011401533","wire_routing":"021000021"},{"account":"1111222233331111","account_id":"nVNqmejaQatJNDbyqK7zFa8XbZp44EIGerKLE","routing":"011401533","wire_routing":"021000021"}],"eft":[]},"request_id":"O3H1XbUMwLQgbgp"}'
        );
      }
    }
  }
}
