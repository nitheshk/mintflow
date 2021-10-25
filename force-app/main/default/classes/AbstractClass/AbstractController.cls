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
      //validate token;
    } else {
      throw new CustomException('Invalid Request');
    }
  }
}
