/**
 * Copyright (c) 2021 Digital Align
 * @group Builder
 * @author Digital Align Team
 * @reference
 * @description Contain the business logic of the flow transition happening in behind the screen
 * Passing unique name to flow, to create different flow
 * Passing same flow name, it will pick up existing flow for process, this will useful for executing action multiple time for failed process
 * Subflow name can be unique or same in two Different flow to create new subflow context
 * Passing unique name to sub flow, to create different sub flow
 * Passing same sub flow name, it will pick up existing sub flow for process, this will useful for executing action multiple time for failed process
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class Flow extends AbstractService {
  //Constant
  private static final String STATUS_SUCCESS = 'Completed';
  private static final String STATUS_FAILED = 'Failed';
  private static final String RECORDTYPE_FLOW = SObjectUtils.recordTypeIdByDevName(Flow__c.SObjectType, 'Flow');
  private static final String RECORDTYPE_SUBFLOW = SObjectUtils.recordTypeIdByDevName(Flow__c.SObjectType, 'SubFlow');

  //Attribute
  @TestVisible
  private static Flow serviceInstance;
  private static String currentEntityId;
  private static Flow__c currentFlow = new Flow__c();
  private static Map<String, Flow__c> flowMap = new Map<String, Flow__c>();
  private static Flow__c currentSubFlow = new Flow__c();
  private static Map<String, Flow__c> subFlowMap = new Map<String, Flow__c>();
  private static Map<String, Map<String, Flow__c>> flows = new Map<String, Map<String, Flow__c>>();
  private static Logger log = Logger.getInstance(Flow.class);

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
   * @description Start the flow initialize , if any existing flow already present will be fetch
   * Pass Id of the object, its need to get linked
   * @author Digital Align Team | 10-19-2021
   * @param String entityId
   **/
  global static void initialize(String entityId) {
    log?.fine('Inside flow initialize');
    currentEntityId = entityId;
    for (Flow__c flow : CommonRepository.fetchFlowByEntityId(entityId)) {
      flowMap.put(flow.FlowName__c, flow);
      subFlowMap = new Map<String, Flow__c>();
      for (Flow__c subFlow : flow.SubFlows__r) {
        subFlowMap.put(subFlow.FlowName__c, subFlow);
      }
      flows.put(flow.FlowName__c, subFlowMap);
    }
  }

  /**
   * @description Persist the log into salesforce
   * @author Digital Align Team | 10-19-2021
   **/
  global static void finalize() {
    log?.fine('Before Logger Finalize');
    //upsert parent flows
    CommonRepository.upsertRecords(flowMap.values());
    List<Flow__c> toUpsertFlows = new List<Flow__c>();
    for (Flow__c flow : flowMap.values()) {
      for (Flow__c subFlow : flows.get(flow.FlowName__c).values()) {
        if (String.isBlank(subFlow.Flow__c)) {
          subFlow.Flow__c = flow.Id;
        }
        toUpsertFlows.add(subFlow);
      }
    }
    CommonRepository.upsertRecords(toUpsertFlows);
    log?.fine('After Logger Finalize');
  }

  // Flow Functions

  /**
   * @description First step to create any parent flow , by passing the unique flow name
   * if Same flow name already present with initialized entity, it will pickup from there.
   * @author Digital Align Team | 10-19-2021
   * @param String flowName
   **/
  public static void setFlow(String flowName) {
    if (flowMap.containsKey(flowName)) {
      currentFlow = flowMap.get(flowName);
      subFlowMap = flows.get(flowName);
    } else {
      currentFlow = new Flow__c(
        FlowName__c = flowName,
        Entity__c = currentEntityId,
        RecordTypeId = RECORDTYPE_FLOW,
        Status__c = 'In Progress'
      );
      subFlowMap = new Map<String, Flow__c>();
    }

    flowMap.put(flowName, currentFlow);
    flows.put(flowName, subFlowMap);
  }

  /**
   * @description set flow status to completed
   * @author Digital Align Team | 10-19-2021
   **/
  public static void setFlowPassed() {
    currentFlow.Status__c = STATUS_SUCCESS;
  }

  /**
   * @description set flow status to completed with note
   * @author Digital Align Team | 10-19-2021
   * @param String note
   **/
  public static void setFlowPassed(String note) {
    currentFlow.Status__c = STATUS_SUCCESS;
    currentFlow.Note__c = note?.left(2000);
  }

  /**
   * @description set flow status to Failed
   * @author Digital Align Team | 10-19-2021
   **/
  public static void setFlowFailed() {
    currentFlow.Status__c = STATUS_FAILED;
  }

  /**
   * @description set flow status to failed with note
   * @author Digital Align Team | 10-19-2021
   * @param String note
   **/
  public static void setFlowFailed(String note) {
    currentFlow.Status__c = STATUS_FAILED;
    currentFlow.Note__c = note?.left(2000);
  }

  /**
   * @description check flow is already completed
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
   * @description check flow is already not completed
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
   * @description set sub flow context
   * @author Digital Align Team | 10-19-2021
   * @param Flow__c flow
   * @return String
   **/
  private static String setSubFlow(Flow__c flow) {
    if (subFlowMap.containsKey(flow.FlowName__c)) {
      currentSubFlow = subFlowMap.get(flow.FlowName__c);
    } else {
      flow.RecordTypeId = RECORDTYPE_SUBFLOW;
      flow.Status__c = 'In Progress';
      currentSubFlow = flow;
    }
    subFlowMap.put(flow.FlowName__c, currentSubFlow);
    return flow.FlowName__c;
  }

  /**
   * @description set sub flow context
   * parameter will combined into single unique flow name
   * @author Digital Align Team | 10-19-2021
   * @param Object flowName
   * @return String
   **/
  public static String setSubFlow(Object flowName) {
    return setSubFlow(new Flow__c(FlowName__c = String.valueOf(flowName), ServiceName__c = String.valueOf(flowName)));
  }

  /**
   * @description set sub flow context with entity and service name
   * parameter will combined into single unique flow name
   * @author Digital Align Team | 10-19-2021
   * @param Object serviceName
   * @param String entity
   * @return String
   **/
  public static String setSubFlow(Object serviceName, String entity) {
    String uniqueName = String.valueOf(serviceName) + '_' + entity;
    return setSubFlow(
      new Flow__c(mflow__FlowName__c = uniqueName, Entity__c = entity, ServiceName__c = String.valueOf(serviceName))
    );
  }

  /**
   * @description set sub flow context with entity, child entity and service name
   * parameter will combined into single unique flow name
   * @author Digital Align Team | 10-19-2021
   * @param Object serviceName
   * @param String entity
   * @param String childEntity
   * @return String
   **/
  public static String setSubFlow(Object serviceName, String entity, String childEntity) {
    String uniqueName = String.valueOf(serviceName) + '_' + entity + '_' + childEntity;
    return setSubFlow(
      new Flow__c(
        mflow__FlowName__c = uniqueName,
        Entity__c = entity + '_' + childEntity,
        ServiceName__c = String.valueOf(serviceName)
      )
    );
  }

  /**
   * @description set sub flow to completed
   * @author Digital Align Team | 10-19-2021
   **/
  public static void setSubFlowPassed() {
    if (currentSubFlow == null) {
      return;
    }
    currentSubFlow.Status__c = STATUS_SUCCESS;
  }

  /**
   * @description set sub flow to completed with note
   * @author Digital Align Team | 10-19-2021
   * @param String note
   **/
  public static void setSubFlowPassed(String note) {
    if (currentSubFlow == null) {
      return;
    }
    currentSubFlow.Status__c = STATUS_SUCCESS;
    currentSubFlow.Note__c = note?.left(2000);
  }

  /**
   * @description set sub flow to Failed
   * @author Digital Align Team | 10-19-2021
   **/
  public static void setSubFlowFailed() {
    if (currentSubFlow == null) {
      return;
    }
    currentSubFlow.Status__c = STATUS_FAILED;
  }

  /**
   * @description set sub flow to Failed with note
   * @author Digital Align Team | 10-19-2021
   * @param String note
   **/
  public static void setSubFlowFailed(String note) {
    if (currentSubFlow == null) {
      return;
    }
    currentSubFlow.Status__c = STATUS_FAILED;
    currentSubFlow.Note__c = note?.left(2000);
  }

  /**
   * @description check sub flow is successful
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
   * @description  check sub flow is not successful
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
      currentSubFlow.Response__c = String.valueOf(response)?.left(131072);
    }
  }
}
