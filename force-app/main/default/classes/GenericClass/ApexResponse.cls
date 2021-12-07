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
    return new ApexResponse().setStatus(200).setDataAsStringfy(data);
  }

  /**
   * @description  return status with 200
   * @author Digital Align Team | 09-02-2021
   * @return ApexResponse
   **/
  global static ApexResponse ok() {
    return new ApexResponse().setStatus(200);
  }

  /**
   * @description return status with 400 and data
   * @author Digital Align Team | 07-15-2021
   * @param object data
   * @return ApexResponse
   **/
  global static ApexResponse fail(object data) {
    return new ApexResponse().setStatus(400).setData(data);
  }

  /**
   * @description return status with 400 and exception details
   * @author Digital Align Team | 11-01-2021
   * @param Exception ex
   * @return ApexResponse
   **/
  global static ApexResponse fail(Exception ex) {
    return new ApexResponse().setStatus(400).setData(ex);
  }

  /**
   * @description return status with 400
   * @author Digital Align Team | 09-02-2021
   * @return ApexResponse
   **/
  global static ApexResponse fail() {
    return new ApexResponse().setStatus(400);
  }

  /**
   * @description return status with 500 with error
   * @author Digital Align Team | 07-15-2021
   * @param object error
   * @return ApexResponse
   **/
  global static ApexResponse exception(object error) {
    return new ApexResponse().setStatus(500).setData(error);
  }

  /**
   * @description  return status with 500 and exception details
   * @author Digital Align Team | 11-01-2021
   * @param Exception ex
   * @return ApexResponse
   **/
  global static ApexResponse exception(Exception ex) {
    return new ApexResponse().setStatus(500).setData(ex);
  }

  /**
   * @description set status code
   * @author Digital Align Team | 07-15-2021
   * @param object status
   * @return ApexResponse
   **/
  global ApexResponse setStatus(object status) {
    if (RestContext.request != null) {
      RestContext.response.statusCode = (Integer) status;
    } else {
      this.status = status;
    }
    return this;
  }

  /**
   * @description set entity for addtional message
   * @author Digital Align Team | 07-15-2021
   * @param Object entity
   * @return ApexResponse
   **/
  public ApexResponse setEntity(Object entity) {
    if (RestContext.request != null) {
      RestContext.response.responseBody = blob.valueOf((String) entity);
    } else {
      this.entity = entity;
    }
    return this;
  }

  /**
   * @description Add Http Response Header
   * @author Digital Align Team | 12-04-2021
   * @param String key
   * @param String value
   * @return ApexResponse
   **/
  public ApexResponse addHeader(String key, String value) {
    if (RestContext.request != null) {
      RestContext.response.addHeader(key, value);
    }
    return this;
  }

  /**
   * @description set data on exception
   * @author Digital Align Team | 12-03-2021
   * @param Exception ex
   * @return ApexResponse
   **/
  public ApexResponse setData(Exception ex) {
    String exceptionTrace =
      'Message: ' +
      ex.getMessage() +
      ' ; Line Number: ' +
      ex.getLineNumber() +
      ' ; Type: ' +
      ex.getTypeName() +
      ' ; Stack Trace: ' +
      ex.getStackTraceString();

    if (RestContext.request != null) {
      RestContext.response.responseBody = blob.valueOf(exceptionTrace);
    } else {
      this.data = ex.getMessage();
      this.entity = exceptionTrace;
    }
    return this;
  }

  /**
   * @description Set data value as Object
   * @author Digital Align Team | 07-15-2021
   * @param Object data
   * @return ApexResponse
   **/
  public ApexResponse setData(Object data) {
    if (RestContext.request != null) {
      if (data instanceof String) {
        RestContext.response.responseBody = blob.valueOf((String) data);
      } else {
        RestContext.response.responseBody = blob.valueOf(
          SObjectConstructor.serialize(data)
        );
      }
    } else {
      this.data = data;
    }
    return this;
  }

  /**
   * @description Set data value as Stringfy
   * @author Digital Align Team | 12-03-2021
   * @param Object data
   * @return ApexResponse
   **/
  public ApexResponse setDataAsStringfy(Object data) {
    if (RestContext.request != null) {
      if (data instanceof String) {
        RestContext.response.responseBody = blob.valueOf((String) data);
      } else {
        RestContext.response.responseBody = blob.valueOf(
          SObjectConstructor.serialize(data)
        );
      }
    } else {
      this.data = SObjectConstructor.serialize(data);
    }
    return this;
  }
}
