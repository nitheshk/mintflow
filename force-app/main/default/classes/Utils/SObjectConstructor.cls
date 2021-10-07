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
          'totalSize' => childObjs.size(),
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
}
