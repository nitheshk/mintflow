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
  global Sobject build() {
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

    return (Sobject) JSON.deserialize(
      Json.Serialize(parentMap),
      Type.forName(SObjectUtils.getObjectName(this.parentObj.getSObjectType()))
    );
  }

  /**
   * @description Convert json into Sobject format, json has single record
   * @author Digital Align Team | 11-23-2021
   * @param String jsonBody
   * @param SobjectType sType
   * @return Sobject
   **/
  global static Sobject deserializeRecord(String jsonBody, SobjectType sType) {
    JSONGenerator gen = JSON.createGenerator(false);
    JSONParser parser = JSON.createParser(jsonBody);
    if (parser.nextToken() == JSONToken.START_OBJECT) {
      writeObject(gen, parser);
    } else {
      throw new customException('Invalid JSON');
    }

    return (SObject) JSON.deserialize(
      gen.getAsString(),
      SObjectUtils.getSobjectClassType(sType)
    );
  }

  /**
   * @description Convert json into Sobject format, json has list of records
   * @author Digital Align Team | 11-23-2021
   * @param String jsonBody
   * @param SobjectType sType
   * @return List<Sobject>
   **/
  global static List<Sobject> deserializeRecords(
    String jsonBody,
    SobjectType sType
  ) {
    JSONGenerator gen = JSON.createGenerator(false);
    JSONParser parser = JSON.createParser(jsonBody);
    if (parser.nextToken() == JSONToken.START_ARRAY) {
      gen.writeStartArray();
      while (parser.nextToken() != JSONToken.END_ARRAY) {
        writeObject(gen, parser);
      }
      gen.writeEndArray();
    } else {
      throw new customException('Invalid JSON');
    }

    return (List<Sobject>) JSON.deserialize(
      gen.getAsString(),
      SObjectUtils.getListSobjectClassType(sType)
    );
  }

  /**
   * @description write json generator from parser
   * @author Digital Align Team | 11-23-2021
   * @param JSONGenerator gen
   * @param JSONParser parser
   **/
  global static void writeObject(JSONGenerator gen, JSONParser parser) {
    gen.writeStartObject();
    //system.debug('parser.getCurrentToken() :' + parser.getCurrentToken());
    //system.debug('parser.getCurrentName() :' + parser.getCurrentName());
    //system.debug('parser.getText() :' + parser.getText());
    while (parser.nextToken() != JSONToken.END_OBJECT) {
      String fieldName = parser.getCurrentName();
      JSONToken jt = parser.nextToken();
      String val = parser.getText();
      JSONToken fieldType = parser.getCurrentToken();
      //system.debug('Val :' + val);
      //system.debug('jt :' + jt);
      //system.debug('fieldType :' + fieldType);
      //system.debug('fieldName :' + fieldName);
      if (jt == JSONToken.START_ARRAY) {
        // arrary parsing
        gen.writeFieldName(fieldName);
        gen.writeStartObject();
        gen.writeBooleanField('done', true);
        gen.writeFieldName('records');
        gen.writeStartArray();
        Integer totalSize = 0;
        while (parser.nextToken() != JSONToken.END_ARRAY) {
          writeObject(gen, parser);
          totalSize++;
        }
        gen.writeEndArray();
        gen.writeNumberField('size', totalSize);
        gen.writeEndObject();
      } else if (jt == JSONToken.START_OBJECT) {
        gen.writeFieldName(fieldName);
        writeObject(gen, parser);
      } else {
        if (jt == JSONToken.VALUE_NULL) {
          gen.writeNullField(fieldName);
        } else {
          gen.writeObjectField(fieldName, val);
          switch on fieldType {
            when VALUE_FALSE, VALUE_TRUE {
              gen.writeBooleanField(fieldName, parser.getBooleanValue());
            }
            when else {
              gen.writeStringField(fieldName, val);
            }
          }
        }
      }
    }
    gen.writeEndObject();
  }
}
