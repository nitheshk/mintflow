/**
 * Copyright (c) 2021 Digital Align
 * @group Exception
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class CustomException extends Exception {
  public CustomException(Exception ex, String message) {
    system.debug('error : ' + ex.getStackTraceString());
    throw new CustomException(ex.getMessage());
  }
}
