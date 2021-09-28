/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class EmailService extends AbstractService {
  @TestVisible
  private static EmailService serviceInstance;

  public EmailService() {
    super(EmailService.class);
  }

  /**
   * @description Provides a singleton instance of EmailService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-12-2021
   * @return Object  singleton
   **/
  public static EmailService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (EmailService) getInstance(EmailService.class);
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align Team | 08-18-2021
   * @param Set<String> documentNames
   * @return virtual
   **/
  global virtual Map<String, String> generateDocumentUrl(
    Set<String> documentNames
  ) {
    Map<String, String> documentURL = new Map<String, String>();
    String baseUrl =
      URL.getSalesforceBaseUrl().getProtocol() +
      '://' +
      System.URL.getSalesforceBaseUrl().getHost().remove('-api') +
      '/servlet/servlet.ImageServer?id={{docID}}' +
      '&oid=' +
      userinfo.getorganizationid();
    for (
      Document doc : EmailNotificationRepository.fetchDocumentByDevName(
        documentNames
      )
    ) {
      documentURL.put(
        '{{' +
        doc.DeveloperName +
        '}}',
        baseUrl.replace('{{docID}}', doc.Id)
      );
    }
    return documentURL;
  }
}
