/**
 * Copyright (c) 2021 Digital Align
 * @group Builder
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class Flow extends AbstractService {
  //Constant
  private static final String STATUS_SUCCESS = 'Success';
  private static final String STATUS_FAILED = 'Failed';

  //Attribute
  @TestVisible
  private static Flow serviceInstance;
  private static String currentEntityId;
  private static Flow__c currentFlow = new Flow__c();
  private static Map<String, Flow__c> flowMap = new Map<String, Flow__c>();
  private static Flow__c currentSubFlow = new Flow__c();
  private static Map<String, Flow__c> subFlowMap = new Map<String, Flow__c>();
  private static Map<String, Map<String, Flow__c>> flows = new Map<String, Map<String, Flow__c>>();

  public Flow() {
    super(Flow.class);
  }

  /**
   * @description Provides a singleton instance of Flow from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static Flow getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (Flow) getNewInstance(Flow.class);
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align Team | 10-19-2021
   * @param String entityId
   **/
  global static void initialize(String entityId) {
    currentEntityId = entityId;
    for (Flow__c flow : CommonRespository.fetchFlowByEntityId(entityId)) {
      flowMap.put(flow.FlowName__c, flow);
      subFlowMap = new Map<String, Flow__c>();
      for (Flow__c subFlow : flow.SubFlows__r) {
        subFlowMap.put(subFlow.FlowName__c, subFlow);
      }
      flows.put(flow.FlowName__c, subFlowMap);
    }
  }

  // Flow Functions

  public static void setFlow(String flowName) {
    if (flowMap.containskey(flowName)) {
      currentFlow = flowMap.get(flowName);
      subFlowMap = flows.get(flowName);
    } else {
      currentFlow = new Flow__c(
        FlowName__c = flowName,
        Entity__c = currentEntityId
      );
      subFlowMap = new Map<String, Flow__c>();
    }
    flowMap.put(flowName, currentFlow);
    flows.put(flowName, subFlowMap);
  }

  /**
   * @description
   * @author Digital Align Team | 10-19-2021
   * @param String note
   **/
  public static void setFlowPassed(String note) {
    setFlow(STATUS_SUCCESS, note);
  }

  /**
   * @description
   * @author Digital Align Team | 10-19-2021
   * @param String note
   **/
  public static void setFlowFailed(String note) {
    setFlow(STATUS_FAILED, note);
  }

  /**
   * @description
   * @author Digital Align Team | 10-19-2021
   * @param String status
   * @param String note
   **/
  private static void setFlow(String status, String note) {
    currentFlow.Status__c = status;
    currentFlow.Note__c = note?.left(2000);
  }

  /**
   * @description
   * @author Digital Align Team | 10-19-2021
   * @param String flowName
   * @return Boolean
   **/
  public static Boolean isFlowPassed(String flowName) {
    if (flowMap?.get(flowName)?.Status__c == STATUS_SUCCESS) {
      return true;
    }
    return false;
  }

  /**
   * @description
   * @author Digital Align Team | 10-19-2021
   * @param String flowName
   * @return Boolean
   **/
  public static Boolean isFlowNotPassed(String flowName) {
    if (flowMap?.get(flowName)?.Status__c != STATUS_SUCCESS) {
      return true;
    }
    return false;
  }

  // Sub Flow Functions

  /**
   * @description
   * @author Digital Align Team | 10-19-2021
   * @param Flow__c flow
   * @return String
   **/
  private static String setSubFlow(Flow__c flow) {
    if (subFlowMap.containskey(flow.FlowName__c)) {
      currentSubFlow = subFlowMap.get(flow.FlowName__c);
    } else {
      currentSubFlow = flow;
    }
    subFlowMap.put(flow.FlowName__c, currentSubFlow);
    return flow.FlowName__c;
  }

  /**
   * @description
   * @author Digital Align Team | 10-19-2021
   * @param Object flowName
   * @return String
   **/
  public static String setSubFlow(Object flowName) {
    return setSubFlow(new Flow__c(FlowName__c = String.valueOf(flowName)));
  }

  /**
   * @description
   * @author Digital Align Team | 10-19-2021
   * @param String entity
   * @param Object serviceName
   * @return String
   **/
  public static String setSubFlow(String entity, Object serviceName) {
    String uniqueName = entity + '_' + String.valueOf(serviceName);
    return setSubFlow(
      new Flow__c(
        Flowname__c = uniqueName,
        ServiceName__c = String.valueOf(serviceName)
      )
    );
  }

  /**
   * @description
   * @author Digital Align Team | 10-19-2021
   * @param String entity
   * @param String childEntity
   * @param Object serviceName
   * @return String
   **/
  public static String setSubFlow(
    String entity,
    String childEntity,
    Object serviceName
  ) {
    String uniqueName =
      entity +
      '_' +
      childEntity +
      '_' +
      String.valueOf(serviceName);
    return setSubFlow(
      new Flow__c(
        Flowname__c = uniqueName,
        ServiceName__c = String.valueOf(serviceName)
      )
    );
  }

  /**
   * @description set sub flow to completed
   * @author Digital Align Team | 10-19-2021
   **/
  public static void setSubFlowPassed() {
    currentSubFlow.Status__c = STATUS_SUCCESS;
  }

  /**
   * @description set sub flow to completed
   * @author Digital Align Team | 10-19-2021
   * @param String note
   **/
  public static void setSubFlowPassed(String note) {
    currentSubFlow.Status__c = STATUS_SUCCESS;
    currentSubFlow.Note__c = note?.left(2000);
  }

  /**
   * @description set sub flow to Failed
   * @author Digital Align Team | 10-19-2021
   **/
  public static void setSubFlowFailed() {
    currentSubFlow.Status__c = STATUS_FAILED;
  }

  /**
   * @description set sub flow to Failed
   * @author Digital Align Team | 10-19-2021
   * @param String note
   **/
  public static void setSubFlowFailed(String note) {
    currentSubFlow.Status__c = STATUS_FAILED;
    currentSubFlow.Note__c = note?.left(2000);
  }

  /**
   * @description check sub flow is sucessful
   * @author Digital Align Team | 10-19-2021
   * @param String flowName
   * @return Boolean
   **/
  public static Boolean isSubFlowPassed(String flowName) {
    if (subFlowMap?.get(flowName)?.Status__c == STATUS_SUCCESS) {
      return true;
    }
    return false;
  }

  /**
   * @description  check sub flow is not sucessful
   * @author Digital Align Team | 10-19-2021
   * @param String flowName
   * @return Boolean
   **/
  public static Boolean isSubFlowNotPassed(String flowName) {
    if (subFlowMap?.get(flowName)?.Status__c != STATUS_SUCCESS) {
      return true;
    }
    return false;
  }

  /**
   * @description set no
   * @author Digital Align Team | 10-19-2021
   * @param String note
   **/
  public static void setSubFlowNote(String note) {
    currentSubFlow.Note__c = note?.left(2000);
  }

  /**
   * @description set request context
   * @author Digital Align Team | 10-19-2021
   * @param Object request
   **/
  public static void setSubFlowRequest(Object request) {
    if (currentSubFlow != null) {
      currentSubFlow.Request__c = String.valueOf(request)?.left(131072);
    }
  }

  /**
   * @description set response context
   * @author Digital Align Team | 10-19-2021
   * @param Object response
   **/
  public static void setSubFlowResponse(Object response) {
    if (currentSubFlow != null) {
      currentSubFlow.Request__c = String.valueOf(response)?.left(131072);
    }
  }
}
