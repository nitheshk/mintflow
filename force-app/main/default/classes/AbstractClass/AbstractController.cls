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
}
