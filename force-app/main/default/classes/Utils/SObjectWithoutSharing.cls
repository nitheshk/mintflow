/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings(
  'PMD.CognitiveComplexity,PMD.NcssMethodCount,PMD.AvoidGlobalModifier'
)
global without sharing class SObjectWithoutSharing {
  private static logger log = Logger.getInstance(SObjectWithoutSharing.class);
  /**
   * @description Dynamic SOQL  query
   * @author Digital Align | 05-03-2021
   * @param String queryString
   * @return List<SObject>
   **/
  public static List<SObject> getRecords(String queryString) {
    return Database.query(queryString);
  }

  /**
   * @description Dynamic SOQL query with variable binding
   * @author Digital Align | 05-04-2021
   * @param String queryString
   * @param List<Object> values
   * @return List<SObject>
   **/
  public static List<SObject> getRecords(
    String queryString,
    List<Object> values
  ) {
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
   * @description Perform dml operation on list of SObject with specified external filedname for upsert operation,
   * @author Digital Align | 05-12-2021
   * @param CrudType crudType
   * @param List<SObject> records
   * @param SObjectField externalFieldName
   * @return List<SObject>
   **/
  public static List<SObject> processRecords(
    CrudType crudType,
    List<SObject> records,
    SObjectField externalFieldName
  ) {
    if (CollectionUtils.isListEmpty(records)) {
      return records;
    }
    switch on crudType {
      when CREATABLE {
        log?.fine('Total record to Insert : ' + records.size());
        insert records;
      }
      when UPDATABLE {
        log?.fine('Total record to Update : ' + records.size());
        update records;
      }
      when UPSERTABLE {
        log?.fine('Total record to Upsert : ' + records.size());
        if (externalFieldName == null) {
          upsert records;
        } else {
          Database.upsert(records, externalFieldName);
        }
      }
      when DELETEABLE {
        log?.fine('Total record to Delete : ' + records.size());
        delete records;
        return null;
      }
    }
    log?.fine(crudType.Name() + ' ' + SObjectUtils.getObjectName(records));
    return records;
  }

  /**
   * @description The optional allOrNone parameter specifies whether the operation allows partial success.
   * If you specify false for this parameter and a record fails, the remainder of the DML operation can still succeed.
   * This method returns a result object that can be used to verify which records succeeded, which failed, and why.
   * If the parameter is not set or is set true, an exception is thrown if the method is not successful.
   * @author Digital Align Team | 10-28-2021
   * @param List<ID> recordIds
   * @param Boolean allOrNone
   * @return List<Database.DeleteResult>
   **/
  public static List<Database.DeleteResult> deleteRecords(
    List<ID> recordIds,
    Boolean allOrNone
  ) {
    List<Database.DeleteResult> results = Database.delete(recordIds, allOrNone);
    log
      ?.fine(
        CrudType.DELETEABLE +
        ' ' +
        SObjectUtils.getObjectName(recordIds[0])
      );
    return results;
  }

  /**
   * @description  The reason behind this is external users or guest users and so on will not have access to ProfileId field in user object.
   * profileID need to assign inside without sharing context
   * @Reference Solution for a known issue : System.SObjectException: Field is not writeable: User.ProfileId
   * https://salesforce.stackexchange.com/questions/123105/sobjectexception-field-is-not-writeable-user-profileid
   * https://www.infallibletechie.com/2016/06/systemsobjectexception-field-is-not.html
   * @author Digital Align Team | 07-23-2021
   * @param User userObj
   * @param ID profileId
   * @return user
   **/
  @NamespaceAccessible
  public static user assignProfileIdToUser(User userObj, ID profileId) {
    userObj.ProfileId = profileId;
    return userObj;
  }

  /**
   * @description Convert lead into account and contact,
   * running without sharing ocntext ,as community user doesn't has permission to convert lead
   * @author Digital Align Team | 08-23-2021
   * @param Database.LeadConvert leadToConvert
   * @return Database.LeadConvertResult
   **/
  public static Database.LeadConvertResult convertLead(
    Database.LeadConvert leadToConvert
  ) {
    return Database.convertLead(leadToConvert);
  }

  /**
   * @description render stored email template
   * Run wihout sharing context as certain object doesn't have access to object such as lead
   * @author Digital Align Team | 09-06-2021
   * @param Messaging.SingleEmailMessage emailMessage
   * @return Messaging.SingleEmailMessage
   **/
  public static Messaging.SingleEmailMessage renderStoredEmailTemplate(
    Messaging.SingleEmailMessage emailMessage
  ) {
    return Messaging.renderStoredEmailTemplate(
      emailMessage.getTemplateId(),
      emailMessage.getTargetObjectId(),
      emailMessage.getWhatId()
    );
  }
}
