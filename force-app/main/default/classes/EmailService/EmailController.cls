/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description Email controller utilized in Email Templates to prefill data dynamically
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class EmailController {
  private Set<String> documentNames = new Set<String>{
    'DaBackGround1',
    'DAContent1',
    'AltifiLogo',
    'facebook',
    'twitter',
    'youtube',
    'skype'
  };
  global Map<String, String> documentUrl { get; set; }

  /**
   * @description
   * @author Digital Align Team | 08-18-2021
   **/
  public EmailController() {
    documentUrl = EmailService.getInstance().generateDocumentUrl(documentNames);
  }
}
