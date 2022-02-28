/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class {{ServiceClass}} extends {{Namespace}}AbstractService {
  @TestVisible
  private static {{ServiceClass}} serviceInstance;

  public {{ServiceClass}}() {
    super({{ServiceClass}}.class);
  }

  /**
   * @description Provides a singleton instance of {{ServiceClass}} from which all other class methods can be accessed.
   * @author Digital Align Team | {{Date}}
   * @return Object  singleton
   **/
  public static {{ServiceClass}} getInstance() {
    if (serviceInstance == null) {
      serviceInstance = ({{ServiceClass}}) getInstance(
        {{ServiceClass}}.class
      );
    }
    return serviceInstance;
  }
}
