/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class LwcOnlineSiteController extends AbstractController {
  private static logger log = logger.getInstance(LwcOnlineSiteController.class);

  global LwcOnlineSiteController(AbstractController controller) {
    super(LwcOnlineSiteController.class);
  }

  /**
   * @description  product Selector to show all product in online page
   * @author Digital Align Team | 03-22-2022
   * @param ApexRequest request
   * @return ApexResponse
   **/
  @AuraEnabled(cacheable=true)
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
