/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description  This class implement utils function for some
 * basic function for handling collection
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class CollectionUtils {
  /**
   * @description Verify list is empty
   * @author Digital Align | 05-12-2021
   * @param list<Object> records
   * @return Boolean
   **/
  global static Boolean isListEmpty(list<Object> records) {
    if (records == null || records.isEmpty()) {
      return true;
    }
    return false;
  }

  /**
   * @description Return list<SObject> of SObjectType to maintain the context
   * @author Digital Align | 05-15-2021
   * @param Schema.SObjectType sObjectType
   * @return List<SObject>
   **/
  global static List<SObject> instanceOfListBySobjectType(Schema.SObjectType sObjectType) {
    String listType = 'List<' + sObjectType + '>';
    List<SObject> records = (List<SObject>) Type.forName(listType).newInstance();
    return (List<SObject>) Type.forName(listType).newInstance();
  }

  /**
   * @description  Convert record to List<SObject> by holding SObject context
   * @author Digital Align | 05-15-2021
   * @param SObject record
   * @return List<SObject>
   **/
  global static List<SObject> convertSobjectToListSobject(SObject record) {
    List<SObject> records = instanceOfListBySobjectType(record.getSObjectType());
    records.add(record);
    return records;
  }

  /**
   * @description String conversion method
   * @author Digital Align | 05-07-2021
   * @param List<String> values
   **/
  global static String joinListByComma(List<String> values) {
    List<String> newValues = new List<String>();
    if (CollectionUtils.isListEmpty(values)) {
      return '';
    }
    for (String s : values) {
      newValues.add('\'' + String.escapeSingleQuotes(s) + '\'');
    }
    return String.join(newValues, ',');
  }
}
