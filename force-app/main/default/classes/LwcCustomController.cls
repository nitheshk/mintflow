/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description main application controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class LwcCustomController extends AbstractController {
  private static logger log = logger.getInstance(LwcCustomController.class);
  public LwcCustomController(AbstractController controller) {
    super(LwcCustomController.class);
  }

  /**
   * @description Read flows by entity id
   * Used in displaying flow in lwc
   * @author Digital Align Team | 10-20-2021
   * @param Map<String String> params
   * @return ApexResponse
   **/
  @AuraEnabled
  @RemoteAction
  global static ApexResponse readFlows(Map<String, String> params) {
    try {
      return ApexResponse.ok(LwcCustomService.getInstance().readFlows(params));
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
