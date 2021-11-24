/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class SObjectConstructor {
  private SObject parentObj;
  private Map<String, List<SObject>> childObjects = new Map<String, List<SObject>>();
  private Map<String, SObject> lookupObjects = new Map<String, SObject>();

  global static SObjectConstructor getInstance(SObject parentObj) {
    SObjectConstructor newConstructor = new SObjectConstructor();
    newConstructor.parentObj = parentObj;
    return newConstructor;
  }

  /**
   * @description
   * @author Digital Align Team | 10-07-2021
   * @param String relationShipName
   * @param SObject lookupObj
   * @return SObjectConstructor
   **/
  global SObjectConstructor setLookupObject(
    String relationShipName,
    SObject lookupObj
  ) {
    lookupObjects.put(relationShipName, lookupObj);
    return this;
  }
  /**
   * @description
   * @author Digital Align Team | 10-07-2021
   * @param String relationShipName
   * @param SObject childObj
   * @return SObjectConstructor
   **/
  global SObjectConstructor addChildObject(
    String relationShipName,
    SObject childObj
  ) {
    return this.addChildObjects(
      relationShipName,
      new List<SObject>{ childObj }
    );
  }

  /**
   * @description
   * @author Digital Align Team | 10-07-2021
   * @param String relationShipName
   * @param List<SObject> childObjs
   * @return SObjectConstructor
   **/
  global SObjectConstructor addChildObjects(
    String relationShipName,
    List<SObject> childObjs
  ) {
    List<SObject> objects = (List<SObject>) this.childObjects.get(
      relationshipName
    );
    if (CollectionUtils.isListEmpty(objects)) {
      objects = childObjs;
    } else {
      objects.addAll(childObjs);
    }
    this.childObjects.put(relationShipName, objects);
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 10-07-2021
   * @param String relationShipName
   * @param SObject childObj
   * @return SObjectConstructor
   **/
  global SObjectConstructor setChildObject(
    String relationShipName,
    SObject childObj
  ) {
    return this.setChildObjects(
      relationShipName,
      new List<SObject>{ childObj }
    );
  }

  /**
   * @description
   * @author Digital Align Team | 10-07-2021
   * @param String relationShipName
   * @param List<SObject> childObjs
   * @return SObjectConstructor
   **/
  global SObjectConstructor setChildObjects(
    String relationShipName,
    List<SObject> childObjs
  ) {
    this.childObjects.put(relationShipName, childObjs);
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 10-07-2021
   * @return SObject
   **/
  global SObject build() {
    if (this.parentObj == null) {
      return null;
    }
    Map<String, Object> parentMap = (Map<String, Object>) JSON.deserializeUntyped(
      Json.Serialize(this.parentObj)
    );

    for (String relationshipName : this.childObjects.keySet()) {
      List<SObject> childObjs = (List<SObject>) this.childObjects.get(
        relationshipName
      );
      parentMap.put(
        relationshipName,
        new Map<String, Object>{
          'totalSize' => childObjs?.size(),
          'done' => true,
          'records' => childObjs
        }
      );
    }

    for (String relationshipName : this.lookupObjects.keySet()) {
      parentMap.put(relationshipName, this.lookupObjects.get(relationshipName));
    }

    return (SObject) JSON.deserialize(
      Json.Serialize(parentMap),
      Type.forName(SObjectUtils.getObjectName(this.parentObj.getSObjectType()))
    );
  }

  /**
   * @description deserialize json into apex type
   * @author Digital Align Team | 11-24-2021
   * @param String jsonBody
   * @param Type cType
   * @return Object
   **/
  global static Object deserialize(String jsonBody, Type cType) {
    JSONGenerator gen = System.JSON.createGenerator(false);
    JSONParser parser = System.JSON.createParser(jsonBody);
    JSONToken nextToken = parser.nextToken();
    if (nextToken == System.JSONToken.START_OBJECT) {
      writeObject(gen, parser);
    } else if (nextToken == System.JSONToken.START_ARRAY) {
      gen.writeStartArray();
      while (parser.nextToken() != System.JSONToken.END_ARRAY) {
        writeObject(gen, parser);
      }
      gen.writeEndArray();
    } else {
      throw new customException('Invalid JSON Format');
    }
    return System.JSON.deserialize(gen.getAsString(), cType);
  }

  /**
   * @description write json generator from parser
   * @author Digital Align Team | 11-23-2021
   * @param JSONGenerator gen
   * @param JSONParser parser
   **/
  private static void writeObject(JSONGenerator gen, JSONParser parser) {
    gen.writeStartObject();
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      String fieldName = parser.getCurrentName();
      JSONToken jt = parser.nextToken();
      String val = parser.getText();
      JSONToken fieldType = parser.getCurrentToken();
      if (jt == System.JSONToken.START_ARRAY) {
        // arrary parsing
        gen.writeFieldName(fieldName);
        gen.writeStartObject();
        gen.writeBooleanField('done', true);
        gen.writeFieldName('records');
        gen.writeStartArray();
        Integer totalSize = 0;
        while (parser.nextToken() != System.JSONToken.END_ARRAY) {
          writeObject(gen, parser);
          totalSize++;
        }
        gen.writeEndArray();
        gen.writeNumberField('size', totalSize);
        gen.writeEndObject();
      } else if (jt == System.JSONToken.START_OBJECT) {
        gen.writeFieldName(fieldName);
        writeObject(gen, parser);
      } else {
        if (jt == System.JSONToken.VALUE_NULL) {
          gen.writeNullField(fieldName);
        } else {
          if (
            fieldType == System.JSONToken.VALUE_FALSE ||
            fieldType == System.JSONToken.VALUE_TRUE
          ) {
            gen.writeBooleanField(fieldName, parser.getBooleanValue());
          } else {
            gen.writeStringField(fieldName, val);
          }
        }
      }
    }
    gen.writeEndObject();
  }

  /**
   * @description serilaize the object
   * @author Digital Align Team | 11-23-2021
   * @param Object data
   * @return String
   **/
  global static String serialize(Object data) {
    if (data instanceof List<SObject>) {
      return System.JSON.serialize(writeFieldsAsList((List<SObject>) data));
    } else if (data instanceof SObject) {
      return System.JSON.serialize(writeFieldsAsMap((SObject) data));
    } else {
      return System.JSON.serialize(data);
    }
  }

  /**
   * @description Write Sobject fields as List
   * @author Digital Align Team | 11-24-2021
   * @param List<SObject> records
   * @return List<Object>
   **/
  global static List<Object> writeFieldsAsList(List<SObject> records) {
    List<Object> sList = new List<Object>();
    for (SObject record : records) {
      sList.add(writeFieldsAsMap(record));
    }
    return sList;
  }

  /**
   * @description Returns a map of populated field names and their corresponding values.
   * @author Digital Align Team | 11-23-2021
   * @param SObject record
   * @return Map<String, Object>
   **/
  global static Map<String, Object> writeFieldsAsMap(SObject record) {
    Map<String, Object> sMap = record.getPopulatedFieldsAsMap();
    Map<String, Object> populatedFieldsAsMap = new Map<String, Object>();
    for (string fieldName : sMap.keySet()) {
      Object fieldValue = sMap.get(fieldName);
      if (fieldValue instanceof List<SObject>) {
        populatedFieldsAsMap.put(
          fieldName,
          writeFieldsAsList((List<SObject>) fieldValue)
        );
      } else if (fieldValue instanceof SObject) {
        populatedFieldsAsMap.put(
          fieldName,
          writeFieldsAsMap((SObject) fieldValue)
        );
      } else {
        populatedFieldsAsMap.put(fieldName, fieldValue);
      }
    }
    return populatedFieldsAsMap;
  }
}
