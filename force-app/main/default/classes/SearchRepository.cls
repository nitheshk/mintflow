/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class SearchRepository extends DatabaseUtils {
  /**
   * @description
   * @author Digital Align | 09-23-2021
   * @param String searchString
   * @param map<string string> searchFilter
   * @param string userContactType
   * @return List<Contact>
   **/
  public static List<Contact> retriveEmployees(
    String searchString,
    map<string, string> searchFilter,
    string userContactType
  ) {
    query q = Query.newInstance(Contact.SObjectType)
      .addFields()
      .whereEq('mflow__UserContactType__c', userContactType);
    if (!searchFilter.isEmpty()) {
      if (String.isNotBlank(searchFilter.get('FirstName'))) {
        q.andCon().whereLike('FirstName', searchFilter.get('FirstName'));
      }
      if (String.isNotBlank(searchFilter.get('LastName'))) {
        q.andCon().whereLike('LastName', searchFilter.get('LastName'));
      }
      if (String.isNotBlank(searchFilter.get('Email'))) {
        q.andCon().whereLike('Email', searchFilter.get('Email'));
      }
      if (String.isNotBlank(searchFilter.get('MobilePhone'))) {
        q.andCon().whereLike('MobilePhone', searchFilter.get('MobilePhone'));
      }
      if (String.isNotBlank(searchFilter.get('mflow__EmployeeId__c'))) {
        q.andCon()
          .whereLike(
            'mflow__EmployeeId__c',
            searchFilter.get('mflow__EmployeeId__c')
          );
      }
    } else {
      q.andCon()
        .grpOpen()
        .whereLike('FirstName', searchString)
        .orCon()
        .whereLike('LastName', searchString)
        .orCon()
        .whereLike('Email', searchString)
        .orCon()
        .whereLike('MobilePhone', searchString)
        .orCon()
        .whereLike('mflow__EmployeeId__c', searchString)
        .grpClose();
    }
    List<Contact> employeeList = (List<Contact>) DatabaseUtils.getRecords(
      q.toString(true)
    );
    return employeeList;
  }
}
