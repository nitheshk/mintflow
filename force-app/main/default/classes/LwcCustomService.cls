/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class LwcCustomService extends AbstractService {
  @TestVisible
  private static LwcCustomService serviceInstance;

  public LwcCustomService() {
    super(LwcCustomService.class);
  }

  /**
   * @description Provides a singleton instance of LwcCustomService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static LwcCustomService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (LwcCustomService) getInstance(LwcCustomService.class);
    }
    return serviceInstance;
  }

  /**
   * @description readflow by entity id
   * @author Digital Align Team | 10-20-2021
   * @param Map<String Object> params
   * @return List<Flow__c>
   **/
  public List<Flow__c> readFlows(Map<String, Object> params) {
    String entityId = String.valueOf(params.get('recordId'));
    return LwcCustomRepository.fetchFlowByEntityId(entityId);
  }
}
