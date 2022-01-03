/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class PlaidService extends AbstractService {
  @TestVisible
  private static PlaidService serviceInstance;
  private String accessToken;

  public PlaidService() {
    super(PlaidService.class);
  }

  /**
   * @description Provides a singleton instance of PlaidService from which all other class methods can be accessed.
   * @author Digital Align Team | 12/28/2021
   * @return Object  singleton
   **/
  public static PlaidService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (PlaidService) getInstance(PlaidService.class);
    }
    return serviceInstance;
  }

  /**
   * @description Generate Link token
   * @author Digital Align Team | 12-28-2021
   * @param  Map<String, Object> params
   * @return Object
   **/
  global virtual Object generatelinkToken(Map<String, Object> params) {
    try {
      Flow.initialize(ApexRequest.getApplicationId());
      Flow.setFlow('Plaid');
      // get public token
      Flow.setSubFlow(
        APINames.PlaidLinkToken.name(),
        ApexRequest.getApplicationId()
      );
      HttpBuilder.Response tokenResponse = PlaidProvider.getInstance()
        .generatelinkToken(params);
      PlaidTokenDTO.LinkTokenResponse responseDTO;
      if (tokenResponse.statusCode == 200) {
        responseDTO = (PlaidTokenDTO.LinkTokenResponse) System.JSON.deserialize(
          (String) tokenResponse.data,
          PlaidTokenDTO.LinkTokenResponse.class
        );
        Flow.setSubFlowPassed(tokenResponse.status);
      } else {
        Flow.setSubFlowFailed(tokenResponse.status);
        throw new CustomException('Unable to generate link token');
      }
      Flow.setFlowPassed();
      return responseDTO;
    } catch (Exception ex) {
      Flow.setSubFlowFailed(ex.getStackTraceString());
      Flow.setFlowFailed(ex.getStackTraceString());
      throw ex;
    }
  }

  /**
   * @description fetch Accounts For Transaction
   * @author Digital Align Team | 12-28-2021
   * @param String data
   * @return Object
   **/
  global virtual map<string, object> fetchAccountsForTransaction(
    Map<String, Object> params
  ) {
    try {
      Flow.initialize(ApexRequest.getApplicationId());
      Flow.setFlow('Plaid');
      // get public token
      Flow.setSubFlow(
        APINames.PlaidTokenExchange.name(),
        ApexRequest.getApplicationId()
      );
      HttpBuilder.Response tokenResponse = PlaidProvider.getInstance()
        .generateExchangeToken(ApexRequest.getParams());
      if (tokenResponse.statusCode == 200) {
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(
          (String) tokenResponse.data
        );
        accessToken = (String) result.get('access_token');
        Flow.setSubFlowPassed(tokenResponse.status);
      } else {
        Flow.setSubFlowFailed(tokenResponse.status);
        throw new CustomException('Unable to generate access token for plaid');
      }

      // get account details
      Flow.setSubFlow(
        APINames.PlaidRetrieveAuth.name(),
        ApexRequest.getApplicationId()
      );
      ApexRequest.getParams().put('accessToken', accessToken);
      HttpBuilder.Response authResponse = PlaidProvider.getInstance()
        .retrieveAuth(ApexRequest.getParams());
      // object data = '{"accounts":[{"account_id":"wp5rJy31NMfyEJNDvoqXhbwLlRaEGyCrwWWdy","balances":{"available":100,"current":110,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"0000","name":"Plaid Checking","official_name":"Plaid Gold Standard 0% Interest Checking","subtype":"checking","type":"depository"},{"account_id":"l418dp7olxiDAaok8E1pi5Q7n9NGkzfZQbbAp","balances":{"available":200,"current":210,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"1111","name":"Plaid Saving","official_name":"Plaid Silver Standard 0.1% Interest Saving","subtype":"savings","type":"depository"},{"account_id":"5NVq637arPcAbDxWd7GZUd3g5pjXPWFZlNNLz","balances":{"available":null,"current":1000,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"2222","name":"Plaid CD","official_name":"Plaid Bronze Standard 0.2% Interest CD","subtype":"cd","type":"depository"},{"account_id":"kamgkLwoG3iMQPzlvEaZSGnMVR36rLiWnZZRW","balances":{"available":null,"current":410,"iso_currency_code":"USD","limit":2000,"unofficial_currency_code":null},"mask":"3333","name":"Plaid Credit Card","official_name":"Plaid Diamond 12.5% APR Interest Credit Card","subtype":"credit card","type":"credit"},{"account_id":"Jzbo9AkW8vcleKXgyPJ4cjva1KQw7qid3RRNb","balances":{"available":43200,"current":43200,"iso_currency_code":"USD","limit":null,"unofficial_currency_code":null},"mask":"4444","name":"Plaid Money Market","official_name":"Plaid Platinum Standard 1.85% Interest Money Market","subtype":"money market","type":"depository"}],"item":{"available_products":["assets","balance","credit_details"],"billed_products":["auth","identity","income","transactions"],"error":null,"institution_id":"ins_3","item_id":"QNWnmvzAKwcx9RwPXqVMSoRBjkroVnhpge7bq","webhook":"https://www.genericwebhookurl.com/webhook"},"numbers":{"ach":[{"account":"1111222233330000","account_id":"wp5rJy31NMfyEJNDvoqXhbwLlRaEGyCrwWWdy","routing":"011401533","wire_routing":"021000021"},{"account":"1111222233331111","account_id":"l418dp7olxiDAaok8E1pi5Q7n9NGkzfZQbbAp","routing":"011401533","wire_routing":"021000021"}],"eft":[]},"request_id":"snosJ"}';
      // HttpBuilder.Response authResponse = HttpBuilder.buildResponse(
      //   200,
      //   'ok',
      //   data
      // );
      if (authResponse.statusCode == 200) {
        Flow.setSubFlowPassed(authResponse.status);
      } else {
        Flow.setSubFlowFailed(authResponse.status);
        throw new CustomException('Unable to retrieve Auth');
      }

      // parse the result of auth
      PlaidAccountDTO.Response PlaidAccountResponse = (PlaidAccountDTO.Response) JSON.deserialize(
        PlaidAccountDTO.removeReserveFields((string) authResponse.data),
        PlaidAccountDTO.Response.class
      );
      map<string, object> balances = fetchAccountBalances(PlaidAccountResponse);

      Flow.setFlowPassed();
      return balances;
    } catch (Exception ex) {
      Flow.setSubFlowFailed(ex.getStackTraceString());
      Flow.setFlowFailed(ex.getStackTraceString());
      throw ex;
    }
  }

  /**
   * @description
   * @author Digital Align | 01-03-2022
   * @param PlaidAccountDTO.Response response
   * @return virtual
   **/
  public virtual map<string, object> fetchAccountBalances(
    PlaidAccountDTO.Response response
  ) {
    map<string, PlaidAccountDTO.Account> accountMap = new Map<string, PlaidAccountDTO.Account>();
    if (response.accounts != null) {
      for (PlaidAccountDTO.Account account : response.accounts) {
        accountMap.put(account.account_id, account);
      }
      map<string, object> balances = new Map<string, object>();
      for (PlaidAccountDTO.Ach item : response.numbers.ach) {
        PlaidAccountDTO.Account account = accountMap.get(item.account_id);
        balances.put(item.account, account.balances.available);
      }
      return balances;
    }
    return null;
  }
}
