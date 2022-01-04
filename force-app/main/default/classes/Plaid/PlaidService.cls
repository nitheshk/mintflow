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
  global virtual Map<string, object> fetchAccountsForTransaction(
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
      if (authResponse.statusCode == 200) {
        Flow.setSubFlowPassed(authResponse.status);
      } else {
        Flow.setSubFlowFailed(authResponse.status);
        throw new CustomException('Unable to retrieve Auth');
      }

      PlaidAccountDTO.AuthResponse plaidAccountResponse = (PlaidAccountDTO.AuthResponse) JSON.deserialize(
        PlaidAccountDTO.removeReserveFields((string) authResponse.data),
        PlaidAccountDTO.AuthResponse.class
      );

      // get institute details
      Flow.setSubFlow(
        APINames.PlaidRetriveInstitue.name(),
        ApexRequest.getApplicationId()
      );
      ApexRequest.getParams()
        .put('institution_id', plaidAccountResponse.item.institution_id);
      HttpBuilder.Response instituteResponse = PlaidProvider.getInstance()
        .retriveInstitue(ApexRequest.getParams());
      if (instituteResponse.statusCode == 200) {
        Flow.setSubFlowPassed(instituteResponse.status);
      } else {
        Flow.setSubFlowFailed(instituteResponse.status);
        throw new CustomException('Unable to retrieve Institute');
      }

      PlaidAccountDTO.InstituteResponse plaidInstituteResponse = (PlaidAccountDTO.InstituteResponse) JSON.deserialize(
        (string) instituteResponse.data,
        PlaidAccountDTO.InstituteResponse.class
      );

      // parse the result of auth and institute
      Map<string, object> balances = fetchAccountBalances(
        plaidAccountResponse,
        plaidInstituteResponse
      );

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
  public virtual Map<string, object> fetchAccountBalances(
    PlaidAccountDTO.AuthResponse accountResponse,
    PlaidAccountDTO.InstituteResponse instituteResponse
  ) {
    map<string, PlaidAccountDTO.Account> accountMap = new Map<string, PlaidAccountDTO.Account>();
    if (accountResponse.accounts != null) {
      for (PlaidAccountDTO.Account account : accountResponse.accounts) {
        accountMap.put(account.account_id, account);
      }
      List<object> balancesList = new List<object>();
      for (PlaidAccountDTO.Ach item : accountResponse.numbers.ach) {
        map<string, object> balances = new Map<string, object>();
        PlaidAccountDTO.Account account = accountMap.get(item.account_id);
        balances.put('AccountNumber', item.account);
        balances.put('AvailableBalance', account.balances.available);
        balances.put('Routing', item.routing);
        balances.put('WireRouting', item.wire_routing);
        balances.put(
          'Label',
          account.name +
          ' (' +
          item.account +
          ')' +
          ' - ' +
          account.balances.available
        );
        balancesList.add(balances);
      }

      return new Map<string, object>{
        'Institute' => instituteResponse.institution.name,
        'Accounts' => balancesList
      };
    }
    return null;
  }
}
