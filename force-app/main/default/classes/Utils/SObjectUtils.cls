/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description Basic SObject Functionality
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class SObjectUtils {
  //attribute
  private static Map<SObjectType, DescribeSObjectResult> sObjectDescribeMap;
  private static Map<SObjectType, Map<String, Schema.SObjectField>> sObjectFieldMap;
  private static Map<SObjectType, Map<String, Schema.SObjectField>> sObjectReference;
  private static Map<SObjectType, Map<String, ChildRelationship>> sObjectChildReference;
  //public static Map<SObjectType, Map<String, Schema.FieldSet>> sObjectFieldSet = new Map<SObjectType, Map<String, Schema.FieldSet>>();

  static {
    sObjectDescribeMap = new Map<SObjectType, DescribeSObjectResult>();
    sObjectFieldMap = new Map<SObjectType, Map<String, Schema.SObjectField>>();
    sObjectReference = new Map<SObjectType, Map<String, Schema.SObjectField>>();
    sObjectChildReference = new Map<SObjectType, Map<String, ChildRelationship>>();
  }
  /**
   * @description get SObject DescribeSObjectResult by SObject type
   * @author Digital Align | 05-14-2021
   * @param SObjectType sType
   * @return DescribeSObjectResult
   **/
  global static DescribeSObjectResult getDescribeSObjectResult(SObjectType sType) {
    if (sType == null) {
      return null;
    }
    if (!sObjectDescribeMap.containsKey(sType)) {
      sObjectDescribeMap.put(sType, sType.getDescribe(SObjectDescribeOptions.DEFERRED));
    }
    return sObjectDescribeMap.get(sType);
  }

  /**
   * @description  get SObject DescribeSObjectResult by SObject type
   * @author Digital Align | 05-15-2021
   * @param List<SObject> records
   * @return DescribeSObjectResult
   **/
  global static DescribeSObjectResult getDescribeSObjectResult(List<SObject> records) {
    return getDescribeSObjectResult(records?.getSObjectType());
  }

  /**
   * @description get SObject DescribeSObjectResult by SObject type
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @return DescribeSObjectResult
   **/
  global static DescribeSObjectResult getDescribeSObjectResult(SObject record) {
    return getDescribeSObjectResult(record?.getSObjectType());
  }

  /**
   * @description Get SObject name by passing SObjectType
   * @author Digital Align | 05-14-2021
   * @param SObjectType sType
   * @return String
   **/
  global static String getObjectName(SObjectType sType) {
    return getDescribeSObjectResult(sType)?.getName();
  }

  /**
   * @description Get Sobject Type from Sobject Name
   * @author Digital Align Team | 11-30-2021
   * @param String sObjectName
   * @return Schema.SObjectType
   **/
  global static Schema.SObjectType getSobjectType(String sObjectName) {
    return Schema.getGlobalDescribe().get(sObjectName);
  }

  /**
   * @description Get SObject name by passing SObject list
   * @author Digital Align | 05-15-2021
   * @param List<SObject> records
   * @return String
   **/
  global static String getObjectName(List<SObject> records) {
    return getObjectName(records?.getSObjectType());
  }

  /**
   * @description Get SObject name by passing SObject
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @return String
   **/
  global static String getObjectName(SObject record) {
    return getObjectName(record?.getSObjectType());
  }

  /**
   * @description get SObject name by record id
   * @author Digital Align Team | 10-28-2021
   * @param Id entityId
   * @return String
   **/
  global static String getObjectName(Id recordId) {
    return getObjectName(recordId?.getSobjectType());
  }

  /**
   * @description Get all field name based on SObject type
   * @author Digital Align | 05-02-2021
   * @param SObjectType sType
   * @return Map<String, Schema.SObjectField> Return all field of sType
   **/
  global static Map<String, Schema.SObjectField> getFields(SObjectType sType) {
    if (!sObjectFieldMap.containsKey(sType)) {
      sObjectFieldMap.put(sType, getDescribeSObjectResult(sType).fields.getMap());
    }
    return sObjectFieldMap.get(sType);
  }

  /**
   * @description Get fieldset base on the SObject and field set name
   * @author Digital Align | 05-04-2021
   * @param SObjectType sType
   * @param String fieldSetName
   * @return FieldSet
   **/
  global static FieldSet getFieldSet(SObjectType sType, String fieldSetName) {
    return getDescribeSObjectResult(sType).FieldSets.getMap().get(fieldSetName);
  }

  /**
   * @description Get object field based on the relationship name
   * @author Digital Align | 05-02-2021
   * @param SObjectType sType
   * @param String fieldRelationName
   * @return Schema.SObjectField
   **/
  global static Schema.SObjectField resolveReferenceByRelationName(SObjectType sType, String fieldRelationName) {
    if (!sObjectReference.containsKey(sType)) {
      Map<String, Schema.SObjectField> allFields = getFields(sType);
      //rMap -> Referene Field Map
      Map<String, Schema.SObjectField> rMap = new Map<String, Schema.SObjectField>();
      for (String key : allFields.keySet()) {
        DescribeFieldResult fieldDesc = allFields.get(key).getDescribe();

        if (String.isNotBlank(fieldDesc.getRelationshipName())) {
          rMap.put(fieldDesc.getRelationshipName(), allFields.get(key));
        }
      }
      sObjectReference.put(sType, rMap);
    }
    return sObjectReference.get(sType).get(fieldRelationName);
  }

  /**
   * @description Get object field based on the filed name
   * @author Digital Align | 05-02-2021
   * @param sObjectType sType sObjectType
   * @param String fieldName
   * @return Schema.SObjectField
   **/
  global static Schema.SObjectField resolveReferenceByFieldName(SObjectType sType, String fieldName) {
    return getFields(sType).get(fieldName.toLowerCase());
  }

  /**
   * @description Get ChildRelationship  based on the child relationship name
   * @author Digital Align | 05-04-2021
   * @param SObjectType sType
   * @param String ChildRelationshipMap
   * @return ChildRelationship
   **/
  global static ChildRelationship resolveChildReferenceByRelationName(SObjectType sType, String childRelationshipMap) {
    if (!sObjectChildReference.containsKey(sType)) {
      //crmap -> ChildRelationshipMap
      Map<String, ChildRelationship> crMap = new Map<String, ChildRelationship>();
      //cr -> ChildRelationship
      for (ChildRelationship cr : sObjectDescribeMap.get(sType).getChildRelationships()) {
        if (cr.getRelationshipName() != null) {
          crMap.put(cr.getRelationshipName(), cr);
        }
      }
      sObjectChildReference.put(sType, crMap);
    }
    return sObjectChildReference.get(sType).get(childRelationshipMap);
  }

  /**
   * @description Get recordTypeId by Object Type & Record Type Name
   * @author Digital Align Team | 07-14-2021
   * @param SObjectType sType
   * @param string recordTypeName
   * @return Id
   **/
  global static Id recordTypeIdByName(SObjectType sType, string recordTypeName) {
    return SObjectUtils.getDescribeSObjectResult(sType)
      ?.getRecordTypeInfosByName()
      .get(recordTypeName)
      ?.getRecordTypeId();
  }

  /**
   * @description //Get recordTypeId by Object Name & Record Type Developer Name
   * @author Digital Align Team | 07-14-2021
   * @param SObjectType sType
   * @param string recordTypeDevName
   * @return Id
   **/
  global static Id recordTypeIdByDevName(SObjectType sType, string recordTypeDevName) {
    return SObjectUtils.getDescribeSObjectResult(sType)
      ?.getRecordTypeInfosByDeveloperName()
      .get(recordTypeDevName)
      ?.getRecordTypeId();
  }

  /**
   * @description get SObject class  type from SobjectType
   * @author Digital Align Team | 11-23-2021
   * @param SobjectType sType
   * @return Type
   **/
  global static Type getSobjectClassType(SObjectType sType) {
    return Type.forName(getObjectName(sType));
  }

  /**
   * @description get list of SObject class  type from SobjectType
   * @author Digital Align Team | 11-23-2021
   * @param SObjectType sType
   * @return Type
   **/
  global static Type getListSobjectClassType(SObjectType sType) {
    return Type.forName('List<' + getSobjectClassType(sType) + '>');
  }
}
