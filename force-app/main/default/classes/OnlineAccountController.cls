/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description Online Account controller
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OnlineAccountController {
  public String recordId { get; set; }
  public Account application { get; set; }
  public Map<String, String> pageParams { get; set; }

  /**
   * @description
   * @author Digital Align Team | 09-29-2021
   **/
  global void initializeApplication() {
    pageParams = PageUtils.getCurrentPageParameters();
    if (String.isNotBlank(pageParams.get('recordId'))) {
      //resume application with recordId
      this.application = (Account) ApplicationService.getInstance()
        .resumeApplication(pageParams);
    } else {
      this.application = (Account) ApplicationService.getInstance()
        .CreateApplication(pageParams);
        this.recordId=this.application.Id; 
    }
  }
}
