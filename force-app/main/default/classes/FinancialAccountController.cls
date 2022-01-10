/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description Contian functionality related financial account resolver
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FinancialAccountController extends AbstractController {
  private static logger log = logger.getInstance(ApplicationController.class);

  public FinancialAccountController(AbstractController controller) {
    super(FinancialAccountController.class);
  }

  /**
   * @description Save Financial Account
   * @author Digital Align Team | 01-10-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse saveFinancialAccounts(ApexRequest request) {
    try {
      validateRequest(request);
      log?.debug('params : ' + ApexRequest.request.params);
      List<FinServ__FinancialAccount__c> financialAccounts = (List<FinServ__FinancialAccount__c>) SObjectConstructor.deserialize(
        request.data,
        List<FinServ__FinancialAccount__c>.class
      );
      financialAccounts = FinancialAccountService.getInstance()
        .saveFinancialAccounts(
          financialAccounts,
          ApexRequest.getApplicationId()
        );
      return ApexResponse.ok(financialAccounts);
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      Logger.persist();
    }
  }
}
