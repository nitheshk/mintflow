/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description Financial Transaction controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FinancingController extends AbstractController {
  private static Logger log = Logger.getInstance(FinancingController.class);
  global FinancingController(AbstractController controller) {
    super(FinancingController.class);
  }

  /**
   * @description
   * @author Digital Align Team | 12-28-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse fetchLinkToken(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.ok(
        PlaidService.getInstance().fetchLinkToken(ApexRequest.getParams())
      );
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      Flow.finalize();
      Logger.persist();
    }
  }

  /**
   * @description Fetch Accounts For Transaction
   * @author Digital Align Team | 12-29-2021
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse fetchAccountsForTransaction(ApexRequest request) {
    try {
      validateRequest(request);
      return ApexResponse.ok(
        PlaidService.getInstance()
          .fetchAccountsForTransaction(ApexRequest.getParams())
      );
    } catch (CustomException ex) {
      log?.error(ex);
      return ApexResponse.exception(ex);
    } catch (Exception ex) {
      log?.error(ex);
      return ApexResponse.fail(ex);
    } finally {
      Flow.finalize();
      Logger.persist();
    }
  }
}
