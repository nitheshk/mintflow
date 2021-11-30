/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description Visualforce Extensions class need to extend with common class to include
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global abstract with sharing class AbstractController {
  private Type classType = AbstractService.class;
  protected logger log;

  public AbstractController() {
    classType = AbstractController.class;
    log = logger.getInstance(classType);
  }

  public AbstractController(Type classType) {
    this.classType = classType;
    log = logger.getInstance(this.classType);
  }

  /**
   * @description validate apex request
   * @author Digital Align Team | 10-25-2021
   * @param ApexRequest request
   **/
  global static void validateRequest(ApexRequest request) {
    if (request != null) {
      request?.setRequest();
      if (
        !Test.isRunningTest() &&
        UserInfo.getUserName() ==
        SiteSetting__c.getInstance().mflow__OnlineSiteUserName__c
      ) {
        //validate token;
        //throw custom exception on any error
        SecurityUtils.validateSession();
      }
    } else {
      throw new CustomException('Invalid Request');
    }
  }

  /**
   * @description validate request, Can skip the validation  on flag true
   * @author Digital Align Team | 11-19-2021
   * @param ApexRequest request
   * @param Boolean skipValidation
   **/
  global static void validateRequest(
    ApexRequest request,
    Boolean skipValidation
  ) {
    if (request != null) {
      request?.setRequest();
      if (String.isBlank(ApexRequest.getToken()) && skipValidation) {
        return;
      }
      if (!Test.isRunningTest()) {
        //validate token;
        //throw custom exception on any error
        SecurityUtils.validateSession();
      }
    } else {
      throw new CustomException('Invalid Request');
    }
  }
}
