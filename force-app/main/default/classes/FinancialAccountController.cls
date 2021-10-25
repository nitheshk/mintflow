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
}
