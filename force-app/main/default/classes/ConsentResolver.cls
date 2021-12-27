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
    List<Consent__c> consents = new List<Consent__c>();

    Account application = ConsentRepository.readApplicationWithFA(
      ApexRequest.getApplicationId()
    );

    //resolve consent using custom filter
    consents.addAll(resolveConsents(application, filters));
    //resolve consent using financial account
    consents.addAll(resolveConsents(application));
    // remove duplicate consent
    return removeDuplicateConsent(consents);
  }

  /**
   * @description resolve consent using custom filter
   * @author Digital Align Team | 12-27-2021
   * @param Account application
   * @param List<Object> filters
   * @return List<Consent__c>
   **/
  global virtual List<Consent__c> resolveConsents(
    Account application,
    List<Object> filters
  ) {
    if (!CollectionUtils.isListEmpty(filters)) {
      for (Object filter : filters) {
        Map<String, Object> filterMap = (Map<String, Object>) filter;
        filterMap.put(
          'mflow__ApplicantType__c',
          ApexRequest.getApplicantType()
        );
        filterMap.put('$mflow__ApplicantType__c', 'INCLUDES');
        filterMap.put('mflow__Channel__c', application.CreatedChannel__c);
        filterMap.put('$mflow__Channel__c', 'INCLUDES');
      }
    }

    String eventIdentifier = String.valueOf(
      ApexRequest.getParams('eventIdentifier')
    );

    // fetch consent item by  custom filter
    List<ConsentLineItem__c> consentLineItems = ConsentRepository.fetchConsentByFilter(
      filters,
      'mflow__Filter',
      eventIdentifier
    );
    //prepare document mapping
    this.setDocumentMap(consentLineItems);
    // map consent items into consent
    return this.mapConsentItemToConsent(consentLineItems, null);
  }

  /**
   * @description Resolve consent using Financial Account selection
   * @author Digital Align Team | 12-27-2021
   * @param Account application
   * @param List<Object> filters
   * @return List<Consent__c>
   **/
  global virtual List<Consent__c> resolveConsents(Account application) {
    List<Consent__c> consents = new List<Consent__c>();

    if (CollectionUtils.isListEmpty(application.FinancialAccounts__r)) {
      return consents;
    }

    String eventIdentifier = String.valueOf(
      ApexRequest.getParams('eventIdentifier')
    );

    for (
      FinServ__FinancialAccount__c financialAccount : application.FinancialAccounts__r
    ) {
      Map<String, Object> filterMap = new Map<String, Object>();
      filterMap.put('mflow__ApplicantType__c', ApexRequest.getApplicantType());
      filterMap.put('$mflow__ApplicantType__c', 'INCLUDES');
      filterMap.put('mflow__Channel__c', application.CreatedChannel__c);
      filterMap.put('$mflow__Channel__c', 'INCLUDES');
      filterMap.put(
        'mflow__FinancialProductCode__c',
        financialAccount.FinancialProduct__r.InternalCode__c
      );

      // fetch consent item by  custom filter
      List<ConsentLineItem__c> consentLineItems = ConsentRepository.fetchConsentByFilter(
        filterMap,
        'mflow__Filter',
        eventIdentifier
      );
      //prepare document mapping
      this.setDocumentMap(consentLineItems);
      // map consent items into consent
      consents.addAll(
        this.mapConsentItemToConsent(consentLineItems, financialAccount.Id)
      );
    }
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
    List<ConsentLineItem__c> consentLineItems,
    Id financialAccountId
  ) {
    //result consent
    List<Consent__c> consentList = new List<Consent__c>();

    for (ConsentLineItem__c consentLineItem : consentLineItems) {
      Consent__c consent = new Consent__c();
      consent.Application__c = ApexRequest.getApplicationId();
      if (ApexRequest.getParams('applicantId') != null) {
        consent.Applicant__c = (Id) ApexRequest.getParams('applicantId');
      }
      if (String.isNotBlank(financialAccountId)) {
        consent.FinancialAccount__c = financialAccountId;
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
      consentList.add(consent);
    }
    return consentList;
  }

  /**
   * @description remove duplicate consent
   * @author Digital Align Team | 12-27-2021
   * @param List<Consent__c> consents
   * @return List<Consent__c>
   **/
  global virtual List<Consent__c> removeDuplicateConsent(
    List<Consent__c> consents
  ) {
    Map<String, Consent__c> consentMap = new Map<String, Consent__c>();
    for (Consent__c consent : consents) {
      consentMap.put(consent.ConsentTemplate__r.Code__c, consent);
    }
    return consentMap.values();
  }
}
