/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.CognitiveComplexity,PMD.NcssMethodCount')
public with sharing class SObjectWithSharing {
  private static logger log = Logger.getInstance(SObjectWithSharing.class);
  /**
   * @description Dynamic SOQL query
   * @author Digital Align | 05-03-2021
   * @param String queryString
   * @return List<SObject>
   **/
  public static List<SObject> getRecords(String queryString) {
    return Database.query(queryString);
  }

  /**
   * @description  Dynamic SOQL query with variable binding
   * @author Digital Align | 05-04-2021
   * @param String queryString
   * @param List<Object> values
   * @return List<SObject>
   **/
  public static List<SObject> getRecords(String queryString, List<Object> values) {
    if (values == null) {
      return Database.query(queryString);
    }

    Object obj0, obj1, obj2, obj3, obj4, obj5;

    for (Integer i = 0; i < values.size(); i++) {
      queryString = queryString.replace('{' + i + '}', ':obj' + i);
    }

    while (true) {
      Integer size = values.size();
      if (size == 0) {
        break;
      }
      obj0 = values[0];
      if (size == 1) {
        break;
      }
      obj1 = values[1];
      if (size == 2) {
        break;
      }
      obj2 = values[2];
      if (size == 3) {
        break;
      }
      obj3 = values[3];
      if (size == 4) {
        break;
      }
      obj4 = values[4];
      if (size == 5) {
        break;
      }
      obj5 = values[5];
      if (size == 6) {
        break;
      }
    }
    return Database.query(queryString);
  }

  /**
   * @description Perform dml operation
   * @author Digital Align | 05-12-2021
   * @param CrudType crudType
   * @param List<SObject> records
   * @param SObjectField externalFieldName
   * @return List<SObject>
   **/
  public static List<SObject> processRecords(CrudType crudType, List<SObject> records, SObjectField externalFieldName) {
    if (CollectionUtils.isListEmpty(records)) {
      return records;
    }
    switch on crudType {
      when CREATABLE {
        insert records;
      }
      when UPDATABLE {
        update records;
      }
      when UPSERTABLE {
        if (externalFieldName == null) {
          upsert records;
        } else {
          Database.upsert(records, externalFieldName);
        }
      }
      when DELETEABLE {
        delete records;
        return null;
      }
    }
    log?.fine(crudType.Name() + ' ' + SObjectUtils.getObjectName(records));
    return records;
  }
}
