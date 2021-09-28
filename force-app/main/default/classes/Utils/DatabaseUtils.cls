/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference  https://github.com/trailheadapps/apex-recipes
 * @description  Secure code that prevents users from seeing and accessing fields
 * they cannot access.
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual inherited sharing class DatabaseUtils {
  /*
   * group by with sharing
   */
  /**
   * @description
   * @author Digital Align | 05-11-2021
   * @param String queryString
   * @return List<SObject>
   **/
  global static List<SObject> getRecordsBySharing(String queryString) {
    //use enforcefls for more secure soql in query constructor
    return SObjectWithSharing.getRecords(queryString);
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String queryString
   * @return SObject
   **/
  global static SObject getRecordBySharing(String queryString) {
    //use enforcefls for more secure soql in query constructor
    List<SObject> sObjectList = SObjectWithSharing.getRecords(queryString);
    return sObjectList.isEmpty() ? null : sObjectList[0];
  }

  /**
   * @description
   * @author Digital Align | 05-11-2021
   * @param String queryString
   * @param List<Object> records
   * @return List<Object>
   **/
  global static List<SObject> getRecordsBySharing(
    String queryString,
    List<Object> records
  ) {
    //use enforcefls for more secure soql in query constructor
    return SObjectWithSharing.getRecords(queryString, records);
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String queryString
   * @param List<Object> records
   * @return SObject
   **/
  global static SObject getRecordBySharing(
    String queryString,
    List<Object> records
  ) {
    List<SObject> sObjectList = SObjectWithSharing.getRecords(
      queryString,
      records
    );
    return sObjectList.isEmpty() ? null : sObjectList[0];
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param CrudType crudType
   * @param List<SObject> records
   * @param SObjectField externalFieldName
   **/
  private static List<SObject> processRecordsWithSharing(
    CrudType crudType,
    List<SObject> records,
    SObjectField externalFieldName
  ) {
    if (CollectionUtils.isListEmpty(records)) {
      return records;
    }

    if (!SecurityUtils.crud(records, crudType)) {
      throw new SObjectException(
        'Insufficient ' +
        crudType +
        ' permission on object : ' +
        SObjectUtils.getObjectName(records)
      );
    }
    return SObjectWithSharing.processRecords(
      crudType,
      records,
      externalFieldName
    );
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param List<SObject> records
   * @return List<SObject>
   **/
  global static List<SObject> insertRecordsBySharing(List<SObject> records) {
    system.debug('test 0.4:' + records.getSObjectType());
    return processRecordsWithSharing(CrudType.CREATABLE, records, null);
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @return SObject
   **/
  global static SObject insertRecordBySharing(SObject record) {
    if (record == null) {
      return record;
    }
    return insertRecordsBySharing(
      CollectionUtils.convertSobjectToListSobject(record)
    )[0];
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param List<SObject> records
   * @return List<SObject>
   **/
  global static List<SObject> updateRecordsBySharing(List<SObject> records) {
    return processRecordsWithSharing(CrudType.UPDATABLE, records, null);
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @return SObject
   **/
  global static SObject updateRecordBySharing(SObject record) {
    if (record == null) {
      return record;
    }
    return updateRecordsBySharing(
      CollectionUtils.convertSobjectToListSobject(record)
    )[0];
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param List<SObject> records
   * @return List<SObject>
   **/
  global static List<SObject> upsertRecordsBySharing(List<SObject> records) {
    return processRecordsWithSharing(CrudType.UPSERTABLE, records, null);
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @return SObject
   **/
  global static SObject upsertRecordBySharing(SObject record) {
    if (record == null) {
      return record;
    }
    return upsertRecordsBySharing(
      CollectionUtils.convertSobjectToListSobject(record)
    )[0];
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param List<SObject> records
   * @param SObjectField externalFieldName
   * @return List<SObject>
   **/
  global static List<SObject> upsertRecordsBySharing(
    List<SObject> records,
    SObjectField externalFieldName
  ) {
    return processRecordsWithSharing(
      CrudType.UPSERTABLE,
      records,
      externalFieldName
    );
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @param SObjectField externalFieldName
   * @return SObject
   **/
  global static SObject upsertRecordBySharing(
    SObject record,
    SObjectField externalFieldName
  ) {
    if (record == null) {
      return record;
    }
    return upsertRecordsBySharing(
      CollectionUtils.convertSobjectToListSobject(record),
      externalFieldName
    )[0];
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param List<SObject> records
   **/
  global static void deleteRecordsBySharing(List<SObject> records) {
    processRecordsWithSharing(CrudType.DELETEABLE, records, null);
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   **/
  global static void deleteRecordBySharing(SObject record) {
    if (record == null) {
      return;
    }
    deleteRecordsBySharing(CollectionUtils.convertSobjectToListSobject(record));
  }

  /*
   * group by  stripInaccessible
   */

  /**
   * @description
   * @author Digital Align | 05-11-2021
   * @param String queryString
   * @return List<SObject>
   **/
  global static List<SObject> getRecordsByStrip(String queryString) {
    return SecurityUtils.stripInaccessible(
      SObjectWithoutSharing.getRecords(queryString),
      CrudType.READABLE
    );
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String queryString
   * @return SObject
   **/
  global static SObject getRecordByStrip(String queryString) {
    List<SObject> sObjectList = SecurityUtils.stripInaccessible(
      SObjectWithoutSharing.getRecords(queryString),
      CrudType.READABLE
    );
    return sObjectList.isEmpty() ? null : sObjectList[0];
  }

  /**
   * @description
   * @author Digital Align | 05-11-2021
   * @param String queryString
   * @param List<Object> records
   * @return List<SObject>
   **/
  global static List<SObject> getRecordsByStrip(
    String queryString,
    List<Object> records
  ) {
    return SecurityUtils.stripInaccessible(
      SObjectWithoutSharing.getRecords(queryString, records),
      CrudType.READABLE
    );
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String queryString
   * @param List<Object> records
   * @return SObject
   **/
  global static SObject getRecordByStrip(
    String queryString,
    List<Object> records
  ) {
    List<SObject> sObjectList = SecurityUtils.stripInaccessible(
      SObjectWithoutSharing.getRecords(queryString, records),
      CrudType.READABLE
    );
    return sObjectList.isEmpty() ? null : sObjectList[0];
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param CrudType crudType
   * @param List<SObject> records
   * @param SObjectField externalFieldName
   * @return List<SObject>
   **/
  private static List<SObject> processRecordsByStrip(
    CrudType crudType,
    List<SObject> records,
    SObjectField externalFieldName
  ) {
    if (CollectionUtils.isListEmpty(records)) {
      return records;
    }
    return SObjectWithoutSharing.processRecords(
      crudType,
      SecurityUtils.stripInaccessible(records, crudType),
      null
    );
  }

  /**
   * @description
   * @author Digital Align | 05-11-2021
   * @param List<Object> records
   * @return List<SObject>
   **/
  global static List<SObject> insertRecordsByStrip(List<SObject> records) {
    return processRecordsByStrip(CrudType.CREATABLE, records, null);
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @return SObject
   **/
  global static SObject insertRecordByStrip(SObject record) {
    if (record == null) {
      return record;
    }
    return insertRecordsByStrip(
      CollectionUtils.convertSobjectToListSobject(record)
    )[0];
  }

  /**
   * @description
   * @author Digital Align | 05-11-2021
   * @param List<Object> records
   * @return List<SObject>
   **/
  global static List<SObject> updateRecordsByStrip(List<sObject> records) {
    return processRecordsByStrip(CrudType.UPDATABLE, records, null);
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @return SObject
   **/
  global static SObject updateRecordByStrip(SObject record) {
    if (record == null) {
      return record;
    }
    return updateRecordsByStrip(
      CollectionUtils.convertSobjectToListSobject(record)
    )[0];
  }

  /**
   * @description
   * @author Digital Align | 05-11-2021
   * @param List<Object> records
   * @return List<SObject>
   **/
  global static List<SObject> upsertRecordsByStrip(List<sObject> records) {
    return processRecordsByStrip(CrudType.UPSERTABLE, records, null);
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @return SObject
   **/
  global static SObject upsertRecordByStrip(SObject record) {
    if (record == null) {
      return record;
    }
    return upsertRecordsByStrip(
      CollectionUtils.convertSobjectToListSobject(record)
    )[0];
  }

  /**
   * @description
   * @author Digital Align | 05-12-2021
   * @param List<sObject> records
   * @param SObjectField externalFieldName
   * @return List<SObject>
   **/
  global static List<SObject> upsertRecordsByStrip(
    List<sObject> records,
    SObjectField externalFieldName
  ) {
    return processRecordsByStrip(
      CrudType.UPSERTABLE,
      records,
      externalFieldName
    );
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @param SObjectField externalFieldName
   * @return SObject
   **/
  global static SObject upsertRecordByStrip(
    SObject record,
    SObjectField externalFieldName
  ) {
    if (record == null) {
      return record;
    }
    return upsertRecordsByStrip(
      CollectionUtils.convertSobjectToListSobject(record),
      externalFieldName
    )[0];
  }

  /*
   * group by without sharing soql and dml operation
   */
  /**
   * @description
   * @author Digital Align | 05-11-2021
   * @param String queryString
   * @return List<SObject>
   **/
  global static List<SObject> getRecords(String queryString) {
    return SObjectWithoutSharing.getRecords(queryString);
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String queryString
   * @return SObject
   **/
  global static SObject getRecord(String queryString) {
    List<SObject> sObjectList = SObjectWithoutSharing.getRecords(queryString);
    return sObjectList.isEmpty() ? null : sObjectList[0];
  }

  /**
   * @description
   * @author Digital Align | 05-11-2021
   * @param String queryString
   * @param List<Object> records
   * @return List<SObject>
   **/
  global static List<SObject> getRecords(
    String queryString,
    List<Object> records
  ) {
    return SObjectWithoutSharing.getRecords(queryString, records);
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String queryString
   * @param List<Object> records
   * @return SObject
   **/
  global static SObject getRecord(String queryString, List<Object> records) {
    List<SObject> sObjectList = SObjectWithoutSharing.getRecords(
      queryString,
      records
    );
    return sObjectList.isEmpty() ? null : sObjectList[0];
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param CrudType crudType
   * @param List<SObject> records
   * @param SObjectField externalFieldName
   * @return List<SObject>
   **/
  private static List<SObject> processRecordsWithoutSharing(
    CrudType crudType,
    List<SObject> records,
    SObjectField externalFieldName
  ) {
    if (CollectionUtils.isListEmpty(records)) {
      return records;
    }
    return SObjectWithoutSharing.processRecords(
      crudType,
      records,
      externalFieldName
    );
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param List<sObject> records
   * @return List<sObject>
   **/
  global static List<SObject> insertRecords(List<SObject> records) {
    return processRecordsWithoutSharing(CrudType.CREATABLE, records, null);
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @return SObject
   **/
  global static SObject insertRecord(SObject record) {
    if (record == null) {
      return record;
    }
    return insertRecords(
      CollectionUtils.convertSobjectToListSobject(record)
    )[0];
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param List<sObject> records
   * @return List<SObject>
   **/
  global static List<SObject> updateRecords(List<sObject> records) {
    return processRecordsWithoutSharing(CrudType.UPDATABLE, records, null);
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @return SObject
   **/
  global static SObject updateRecord(SObject record) {
    if (record == null) {
      return record;
    }
    return updateRecords(
      CollectionUtils.convertSobjectToListSobject(record)
    )[0];
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param List<sObject> records
   * @return List<SObject>
   **/
  global static List<SObject> upsertRecords(List<sObject> records) {
    return processRecordsWithoutSharing(CrudType.UPSERTABLE, records, null);
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @return SObject
   **/
  global static SObject upsertRecord(SObject record) {
    if (record == null) {
      return record;
    }
    return upsertRecords(
      CollectionUtils.convertSobjectToListSobject(record)
    )[0];
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param List<sObject> records
   * @param SObjectField externalFieldName
   * @return List<SObject>
   **/
  global static List<SObject> upsertRecords(
    List<sObject> records,
    SObjectField externalFieldName
  ) {
    return processRecordsWithoutSharing(
      CrudType.UPSERTABLE,
      records,
      externalFieldName
    );
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @param SObjectField externalFieldName
   * @return SObject
   **/
  global static SObject upsertRecord(
    SObject record,
    SObjectField externalFieldName
  ) {
    if (record == null) {
      return record;
    }
    return upsertRecords(
      CollectionUtils.convertSobjectToListSobject(record),
      externalFieldName
    )[0];
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param List<sObject> records
   **/
  global static void deleteRecords(List<sObject> records) {
    processRecordsWithoutSharing(CrudType.DELETEABLE, records, null);
  }

  /**
   * @description
   * @author Digital Align | 05-15-2021
   * @param SObject record
   **/
  global static void deleteRecord(SObject record) {
    if (record == null) {
      return;
    }
    deleteRecords(CollectionUtils.convertSobjectToListSobject(record));
  }
}
