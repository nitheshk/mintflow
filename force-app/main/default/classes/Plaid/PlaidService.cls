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
  global virtual Object fetchAccountsForTransaction(
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
      if (tokenResponse.statusCode == 200) {
        Flow.setSubFlowPassed(tokenResponse.status);
      } else {
        Flow.setSubFlowFailed(tokenResponse.status);
        throw new CustomException('Unable to retrieve Auth');
      }

      // parse the result of auth

      Flow.setFlowPassed();
      return authResponse.data;
    } catch (Exception ex) {
      Flow.setSubFlowFailed(ex.getStackTraceString());
      Flow.setFlowFailed(ex.getStackTraceString());
      throw ex;
    }
  }
}
