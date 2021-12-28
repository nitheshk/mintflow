/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description Fiancial Transcation controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class FinancingController extends AbstractController {
  private static logger log = logger.getInstance(FinancingController.class);
  public FinancingController(AbstractController controller) {
    super(FinancingController.class);
  }
}
