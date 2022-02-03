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
  public static List<Contact> retrieveEmployees(
    String searchString,
    map<string, string> searchFilter,
    string userContactType
  ) {
    String searchStr1 = searchString;
    String dynamicString = '';
    String searchQuery;
    List<Contact> employeeList = new List<Contact>();
    if (String.isNotBlank(searchString)) {
      if (searchFilter != null) {
        dynamicString = ApexUtils.obtainSearchString(searchFilter);
      }
      if (searchFilter.isEmpty()) {
        searchQuery =
          'FIND {' +
          searchStr1 +
          '} IN ALL FIELDS RETURNING  Contact(Id,FirstName,LastName,Email,MobilePhone,mflow__EmployeeId__c)';
      } else {
        searchQuery =
          'FIND {' +
          searchStr1 +
          '} IN ALL FIELDS RETURNING  Contact(Id,FirstName,LastName,Email,MobilePhone,mflow__EmployeeId__c WHERE ' +
          dynamicString +
          ')';
      }
      System.debug('searchQuery:' + searchQuery);
      List<List<sObject>> objectList = search.query(searchQuery);
      employeeList = (List<Contact>) objectList[0];
      System.debug('employeeList :' + employeeList);
      return employeeList;
    } else {
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
      }
      employeeList = (List<Contact>) DatabaseUtils.getRecords(q.toString(true));
      System.debug('employeeList:' + employeeList);

      return employeeList;
    }
  }
}
