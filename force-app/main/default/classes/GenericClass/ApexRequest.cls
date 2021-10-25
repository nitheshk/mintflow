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

  global Map<String, Object> params { get; set; }
  global static ApexRequest request { get; set; }

  global void setRequest() {
    ApexRequest request = new ApexRequest();
    request.applicationId = this.applicationId;
    request.token = this.token;
    request.event = this.event;
    request.currentPage = this.currentPage;
    request.flowType = this.flowType;
    request.nextPage = this.nextPage;
    if (String.isNotBlank(this.header)) {
      request.params = (Map<String, Object>) Json.deserializeUntyped(
        this.header
      );
    }

    ApexRequest.request = request;
  }
}
