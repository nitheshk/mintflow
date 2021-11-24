/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApexResponse {
  //attribute

  @AuraEnabled
  global object status { get; set; }
  @AuraEnabled
  global object entity { get; set; }
  @AuraEnabled
  global object data { get; set; }

  /**
   * @description  return status with 200 and data
   * @author Digital Align Team | 07-15-2021
   * @param object data
   * @return ApexResponse
   **/
  global static ApexResponse ok(object data) {
    ApexResponse response = new ApexResponse();
    response.status = 200;
    response.data = SObjectConstructor.serialize(data);
    return response;
  }

  /**
   * @description  return status with 200 and data with serialized json
   * @author Digital Align Team | 07-15-2021
   * @param object data
   * @return ApexResponse
   **/
  /*global static ApexResponse success(object data) {
    ApexResponse response = new ApexResponse();
    response.status = 200;
    response.data = JSON.serialize(data);
    return response;
  }*/

  /**
   * @description  return status with 200
   * @author Digital Align Team | 09-02-2021
   * @return ApexResponse
   **/
  global static ApexResponse ok() {
    ApexResponse response = new ApexResponse();
    response.status = 200;
    return response;
  }

  /**
   * @description return status with 400 and data
   * @author Digital Align Team | 07-15-2021
   * @param object data
   * @return ApexResponse
   **/
  global static ApexResponse fail(object data) {
    ApexResponse response = new ApexResponse();
    response.status = 400;
    response.data = data;
    return response;
  }

  /**
   * @description return status with 400 and exception details
   * @author Digital Align Team | 11-01-2021
   * @param Exception ex
   * @return ApexResponse
   **/
  global static ApexResponse fail(Exception ex) {
    ApexResponse response = new ApexResponse();
    response.status = 400;
    response.data = ex.getMessage();
    response.entity =
      'Message: ' +
      ex.getMessage() +
      ' ; Line Number: ' +
      ex.getLineNumber() +
      ' ; Type: ' +
      ex.getTypeName() +
      ' ; Stack Trace: ' +
      ex.getStackTraceString();
    return response;
  }
  /**
   * @description return status with 400
   * @author Digital Align Team | 09-02-2021
   * @return ApexResponse
   **/
  global static ApexResponse fail() {
    ApexResponse response = new ApexResponse();
    response.status = 400;
    return response;
  }

  /**
   * @description return status with 500 with error
   * @author Digital Align Team | 07-15-2021
   * @param object error
   * @return ApexResponse
   **/
  global static ApexResponse exception(object error) {
    ApexResponse response = new ApexResponse();
    response.status = 500;
    response.data = error;
    return response;
  }

  /**
   * @description  return status with 500 and exception details
   * @author Digital Align Team | 11-01-2021
   * @param Exception ex
   * @return ApexResponse
   **/
  global static ApexResponse exception(Exception ex) {
    ApexResponse response = new ApexResponse();
    response.status = 500;
    response.data = ex.getMessage();
    response.entity =
      'Message: ' +
      ex.getMessage() +
      ' ; Line Number: ' +
      ex.getLineNumber() +
      ' ; Type: ' +
      ex.getTypeName() +
      ' ; Stack Trace: ' +
      ex.getStackTraceString();
    return response;
  }

  /**
   * @description
   * @author Digital Align Team | 07-15-2021
   * @param object data
   * @return ApexResponse
   **/
  global static ApexResponse unauthorized(object data) {
    ApexResponse response = new ApexResponse();
    response.status = 503;
    response.data = data;
    return response;
  }

  /**
   * @description
   * @author Digital Align Team | 07-15-2021
   * @param object status
   * @return ApexResponse
   **/
  global static ApexResponse setStatus(object status) {
    ApexResponse response = new ApexResponse();
    response.status = status;
    return response;
  }

  /**
   * @description
   * @author Digital Align Team | 07-15-2021
   * @param Object entity
   * @return ApexResponse
   **/
  public ApexResponse setEntity(Object entity) {
    this.entity = entity;
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 07-15-2021
   * @param Object data
   * @return ApexResponse
   **/
  public ApexResponse setData(Object data) {
    this.data = data;
    return this;
  }
}
