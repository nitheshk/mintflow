/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OnlinePortalController extends AbstractController {
  private static logger log = logger.getInstance(OnlinePortalController.class);
  public OnlinePortalController() {
    super(OnlinePortalController.class);
  }

  global OnlinePortalController(AbstractController controller) {
    super(OnlinePortalController.class);
  }

  /**
   * @description
   * @author Digital Align Team | 06-02-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
  @RemoteAction
  global static ApexResponse productSelector(ApexRequest request) {
    try {
      validateRequest(request, true);
      return ApexResponse.ok(ProductService.getInstance().productSelector());
    } catch (Exception ex) {
      log?.debug(ex.getMessage());
      return ApexResponse.fail(ex);
    }
  }
}
