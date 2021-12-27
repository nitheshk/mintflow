/**
 * Copyright (c) 2021 Digital Align
 * @group Resolver
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ConsentResolver extends AbstractService {
  @TestVisible
  private static ConsentResolver serviceInstance;
  private Map<String, Document> documentMap;
  private String baseUrl =
    Url.getSalesforceBaseUrl().getProtocol() +
    '://' +
    System.Url.getSalesforceBaseUrl().getHost().remove('-api') +
    '/servlet/servlet.ImageServer?id={{docID}}' +
    '&oid=' +
    UserInfo.getOrganizationId();

  public ConsentResolver() {
    super(ConsentResolver.class);
  }

  /**
   * @description Provides a singleton instance of ConsentResolver from which all other class methods can be accessed.
   * @author Digital Align Team | 12/22/2021
   * @return Object  singleton
   **/
  public static ConsentResolver getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ConsentResolver) getInstance(ConsentResolver.class);
    }
    return serviceInstance;
  }

  /**
   * @description fetch consent using filter passed on the apex request params
   * @author Digital Align Team | 12-22-2021
   * @param String data Used pass additional data
   * @return List<Consent__c>
   **/
  global virtual List<Consent__c> fetchConsents(String data) {
    List<Object> filters = (List<Object>) ApexRequest.getParams('filter');
    String eventIdentifier = String.valueOf(
      ApexRequest.getParams('eventIdentifier')
    );
    if (eventIdentifier == null) {
      throw new CustomException(
        'Filter is not mentioned, Need to pass at least EventIdentifier as filter option'
      );
    }
    // fetch consent item by  custom filter
    List<ConsentLineItem__c> consentLineItems = ConsentRepository.fetchConsentByFilter(
      filters,
      'mflow__Filter',
      eventIdentifier
    );

    //prepare document mapping
    this.setDocumentMap(consentLineItems);

    // map consent items into consent
    List<Consent__c> consents = mapConsentItemToConsent(consentLineItems);
    return consents;
  }

  /**
   * @description get document by name to generate/show files on site
   * @author Digital Align Team | 12-22-2021
   * @param List<ConsentLineItem__c> consentLineItems
   **/
  private void setDocumentMap(List<ConsentLineItem__c> consentLineItems) {
    List<String> documentNames = new List<String>();
    documentMap = new Map<String, Document>();
    for (ConsentLineItem__c consentLineItem : consentLineItems) {
      if (consentLineItem.ConsentTemplate__r.DocumentType__c == 'Static') {
        documentNames.add(consentLineItem.ConsentTemplate__r.DocumentName__c);
      }
    }
    // map document with names
    for (Document document : ConsentRepository.readDocuments(documentNames)) {
      documentMap.put(document.DeveloperName, document);
    }
  }

  /**
   * @description Map consent items into consent
   * @author Digital Align Team | 12-22-2021
   * @param List<ConsentLineItem__c> consentLineItems
   * @return  List<Consent__c>
   **/
  global virtual List<Consent__c> mapConsentItemToConsent(
    List<ConsentLineItem__c> consentLineItems
  ) {
    //result consent
    List<Consent__c> consentList = new List<Consent__c>();
    // used to eliminate duplicate templates
    Set<String> consentCode = new Set<String>();

    for (ConsentLineItem__c consentLineItem : consentLineItems) {
      Consent__c consent = new Consent__c();
      consent.Application__c = ApexRequest.getApplicationId();
      if (ApexRequest.getParams('applicantId') != null) {
        consent.Applicant__c = (Id) ApexRequest.getParams('applicantId');
      }
      consent.Name = consentLineItem.ConsentTemplate__r.Name;
      consent.ConsentTemplate__c = consentLineItem.ConsentTemplate__c;
      consent.ConsentTemplate__r = consentLineItem.ConsentTemplate__r;
      consent.EventIdentifier__c = consentLineItem.EventIdentifier__c;
      consent.Order__c = consentLineItem.Order__c;
      // map document types
      if (consentLineItem.ConsentTemplate__r.DocumentType__c == 'Static') {
        String documentName = consentLineItem.ConsentTemplate__r.DocumentName__c;
        if (documentMap.containsKey(documentName)) {
          consent.URL__c = baseUrl.replace(
            '{{docID}}',
            documentMap.get(documentName)?.Id
          );
        }
      } else if (consentLineItem.ConsentTemplate__r.DocumentType__c == 'URL') {
        consent.URL__c = consentLineItem.ConsentTemplate__r.URL__c;
      } else if (
        consentLineItem.ConsentTemplate__r.DocumentType__c == 'Visualforce' ||
        consentLineItem.ConsentTemplate__r.DocumentType__c == 'Signed'
      ) {
        //#pending Logic is pending to add
        consent.URL__c = consentLineItem.ConsentTemplate__r.URL__c;
      }

      if (!consentCode.contains(consentLineItem.ConsentTemplate__r.Code__c)) {
        consentList.add(consent);
      }
      consentCode.add(consentLineItem.ConsentTemplate__r.Code__c);
    }
    return consentList;
  }
}
