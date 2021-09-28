/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class AbstractService {
  private Type classType = AbstractService.class;

  public AbstractService() {
    classType = AbstractService.class;
  }

  public AbstractService(Type classType) {
    this.classType = classType;
  }

  /**
   * @description Provides a singleton instance of classType from which all other class methods can be accessed.
   * @author Digital Align Team | 07-12-2021
   * @param System.Type classType
   * @return Object  singleton
   **/
  global static Object getInstance(System.Type classType) {
    //resolve namespace issue get append into class name
    String className = classType.getName();
    if (className.contains('.')) {
      className = className.split('\\.')[1];
    }
    ServiceClassSetting__mdt serviceClassObj = SystemSettingRepository.fetchSystemClassSetting(
      className
    );
    if (serviceClassObj != null) {
      return Type.forName(serviceClassObj.ApexClassName__c).newInstance();
    } else {
      throw new CustomException(
        'Unable to find service class setting for : ' + classType.getName()
      );
    }
  }
}
