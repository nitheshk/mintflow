/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApexRequest {
  @AuraEnabled
  global String applicationId { get; set; }
  @AuraEnabled
  global String applicationName { get; set; }
  @AuraEnabled
  global String applicantId { get; set; }
  @AuraEnabled
  global String token { get; set; }
  @AuraEnabled
  global String event { get; set; }
  //Primary Flow or Joint Flow
  @AuraEnabled
  global String flowType { get; set; }
  @AuraEnabled
  global String currentPage { get; set; }
  @AuraEnabled
  global String nextPage { get; set; }
  @AuraEnabled
  global String header { get; set; }
  @AuraEnabled
  global String data { get; set; }
  @AuraEnabled
  global Map<String, Object> params { get; set; }
  @AuraEnabled
  public static ApexRequest request { get; set; }

  static {
    request = new ApexRequest();
  }

  global ApexRequest() {
    params = new Map<String, Object>();
  }

  global void setRequest() {
    ApexRequest request = new ApexRequest();
    request.applicationId = this.applicationId;
    request.applicationName = this.applicationName;
    request.token = this.token;
    request.event = this.event;
    request.currentPage = this.currentPage;
    request.flowType = this.flowType;
    request.nextPage = this.nextPage;
    request.applicantId = this.applicantId;
    if (String.isNotBlank(this.header)) {
      request.params = (Map<String, Object>) Json.deserializeUntyped(
        this.header
      );
    }
    if (String.isNotBlank(this.applicationId)) {
      Logger.setEntity(this.applicationId);
    }
    if (String.isNotBlank(this.applicationName)) {
      Logger.setApplicationName(this.applicationName);
    }
    ApexRequest.request = request;
  }

  /**
   * @description Get Request
   * @author Digital Align Team | 10-27-2021
   * @return ApexRequest
   **/
  global static ApexRequest getRequest() {
    return ApexRequest.request;
  }

  /**
   * @description get Params
   * @author Digital Align Team | 10-27-2021
   * @return Map<String, Object>
   **/
  global static Map<String, Object> getParams() {
    return ApexRequest.request?.params;
  }

  /**
   * @description get value from params
   * @author Digital Align Team | 10-28-2021
   * @param String key
   * @return Object
   **/
  global static Object getParams(String key) {
    return ApexRequest.request?.params.get(key);
  }

  /**
   * @description get application id
   * @author Digital Align Team | 10-27-2021
   * @return String
   **/
  global static String getApplicationId() {
    return ApexRequest.request?.applicationId;
  }

  /**
   * @description get Application Number
   * @author Digital Align Team | 11-02-2021
   * @return String
   **/
  global static String getApplicationName() {
    return ApexRequest.request?.applicationName;
  }

  /**
   * @description  set application id
   * @author Digital Align Team | 10-27-2021
   * @param String applicationId
   * @return ApexRequest
   **/
  global ApexRequest setApplicationId(String applicationId) {
    this.applicationId = applicationId;
    Logger.setEntity(applicationId);
    return this;
  }

  /**
   * @description set header
   * @author Digital Align Team | 10-27-2021
   * @param Map<String Object> header
   * @return ApexRequest
   **/
  global ApexRequest setHeader(Map<String, Object> header) {
    this.header = Json.serialize(header);
    return this;
  }

  /**
   * @description set header
   * @author Digital Align Team | 10-27-2021
   * @param String header
   * @return ApexRequest
   **/
  global ApexRequest setHeader(String header) {
    this.header = header;
    return this;
  }

  /**
   * @description set data of type string
   * @author Digital Align Team | 10-28-2021
   * @param String data
   * @return ApexRequest
   **/
  global ApexRequest setData(String data) {
    this.data = data;
    return this;
  }

  /**
   * @description set data if type object
   * @author Digital Align Team | 10-28-2021
   * @param Object data
   * @return ApexRequest
   **/
  global ApexRequest setData(Object data) {
    this.data = Json.serialize(data);
    return this;
  }
}
