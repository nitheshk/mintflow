/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class AbstractService {
  protected Type classType = AbstractService.class;
  protected Logger log;
  public AbstractService() {
    classType = AbstractService.class;
    log = Logger.getInstance(classType);
  }

  public AbstractService(Type classType) {
    this.classType = classType;
    log = Logger.getInstance(this.classType);
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
    ServiceClassSetting__mdt serviceClassObj = ServiceClassSetting__mdt.getInstance(className);

    if (serviceClassObj != null && !serviceClassObj.Disabled__c) {
      return Type.forName(serviceClassObj.ApexClassName__c).newInstance();
    } else {
      throw new CustomException('Unable to find service class setting for : ' + classType.getName());
    }
  }

  /**
   * @description Provides a singleton instance of classType from which all other class methods can be accessed.
   * New Instance Created without configuration
   * @author Digital Align Team | 07-12-2021
   * @param System.Type classType
   * @return Object  singleton
   **/
  global static Object getNewInstance(System.Type classType) {
    //resolve namespace issue get append into class name
    String className = classType.getName();
    if (className.contains('.')) {
      className = className.split('\\.')[1];
    }
    return Type.forName(className).newInstance();
  }
}
