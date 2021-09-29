/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Search Service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class SearchService extends AbstractService {
  @TestVisible
  private static SearchService serviceInstance;

  public SearchService() {
    super(SearchService.class);
  }
  /**
   * @description Provides a singleton instance of SearchService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static SearchService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (SearchService) getInstance(SearchService.class);
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align | 09-23-2021
   * @param Map<String Object> params
   * @return virtual
   **/
  global virtual List<Contact> retriveEmployees(Map<String, Object> params) {
    string userContactType = (String) params.get('userContactType');
    String searchString = (String) params.get('searchString');
    map<string, string> searchFilter = (map<string, string>) JSON.deserialize(
      JSON.serialize(params.get('searchFilter')),
      map<string, string>.class
    );
    return SearchRepository.retriveEmployees(
      searchString,
      searchFilter,
      userContactType
    );
  }
}
