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
    if (filters == null) {
      throw new CustomException(
        'Filter is not mentioned, Need to pass at least EventIdentifier as filter option'
      );
    }
    // fetch consent item by  custom filter
    List<ConsentLineItem__c> consentLineItems = ConsentRepository.fetchConsentByFilter(
      filters,
      'mflow__Filter'
    );
    // map consent items into consent
    List<Consent__c> consents = mapConsentItemToConsent(consentLineItems);
    return consents;
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
    return null;
  }
}
