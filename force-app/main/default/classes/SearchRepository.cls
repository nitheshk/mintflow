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
   * @param String retrieveEmployees
   * @param map<string,string> searchFilter
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
      List<List<sObject>> objectList = search.query(searchQuery);
      employeeList = (List<Contact>) objectList[0];
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

      return employeeList;
    }
  }

  /**
   * @description
   * @author Digital Align | 09-23-2021
   * @param String retrieveApplicants
   * @param map<string,string> searchFilter
   * @return List<Applicant__c>
>
   **/
  public static List<Applicant__c> retrieveApplicants(
    String searchString,
    map<string, string> searchFilter
  ) {
    String searchStr1 = searchString;
    String dynamicString = '';
    String searchQuery;
    List<Applicant__c> employeeList = new List<Applicant__c>();
    if (String.isNotBlank(searchString)) {
      if (searchFilter != null) {
        dynamicString = ApexUtils.obtainSearchString(searchFilter);
      }

      if (searchFilter.isEmpty()) {
        searchQuery =
          'FIND {' +
          searchStr1 +
          '} IN ALL FIELDS RETURNING  mflow__Applicant__c(Id,mflow__FirstName__c,mflow__LastName__c,mflow__Email__c,mflow__Phone__c,mflow__SSN__c,mflow__Application__r.Name,mflow__ApplicantName__c,mflow__KYCStatus__c ORDER BY CreatedDate Desc)';
      } else {
        searchQuery =
          'FIND {' +
          searchStr1 +
          '} IN ALL FIELDS RETURNING  mflow__Applicant__c(Id,mflow__FirstName__c,mflow__LastName__c,mflow__Email__c,mflow__Phone__c,mflow__SSN__c,mflow__Application__r.Name,mflow__ApplicantName__c,mflow__KYCStatus__c) WHERE ' +
          dynamicString +
          ' ORDER BY CreatedDate Desc)';
      }
      List<List<sObject>> objectList = new List<List<sObject>>();
      objectList = search.query(searchQuery);

      System.debug('employeeList first' + objectList);
      employeeList = (List<Applicant__c>) objectList[0];
      return employeeList;
    } else {
      query q = Query.newInstance(Applicant__c.SObjectType)
        .addFields()
        .whereNotNull('Name');
      if (!searchFilter.isEmpty()) {
        if (String.isNotBlank(searchFilter.get('FirstName'))) {
          q.andCon()
            .whereLike('mflow__FirstName__c', searchFilter.get('FirstName'));
        }
        if (String.isNotBlank(searchFilter.get('LastName'))) {
          q.andCon()
            .whereLike('mflow__LastName__c', searchFilter.get('LastName'));
        }
        if (String.isNotBlank(searchFilter.get('Email'))) {
          q.andCon().whereLike('mflow__Email__c', searchFilter.get('Email'));
        }
        if (String.isNotBlank(searchFilter.get('MobilePhone'))) {
          q.andCon()
            .whereLike('mflow__Phone__c', searchFilter.get('MobilePhone'));
        }
        if (String.isNotBlank(searchFilter.get('SSN'))) {
          q.andCon().whereLike('mflow__SSN__c', searchFilter.get('SSN'));
        }
      }
      employeeList = (List<Applicant__c>) DatabaseUtils.getRecords(
        q.toString(true)
      );
      System.debug('employeeList second' + employeeList);
      return employeeList;
    }
  }

  /**
   * @description
   * @author Digital Align | 09-23-2021
   * @param String retrieveApplications
   * @param map<string,string> searchFilter
   * @return List<Account>
   **/
  public static List<Account> retrieveApplications(
    String searchString,
    map<string, string> searchFilter
  ) {
    String searchStr1 = searchString;
    String dynamicString = '';
    String searchQuery;
    List<Account> applicationsList = new List<Account>();

    if (String.isNotBlank(searchString)) {
      if (searchFilter != null) {
        dynamicString = ApexUtils.obtainSearchString(searchFilter);
      }
      if (searchFilter.isEmpty()) {
        searchQuery =
          'FIND {' +
          searchStr1 +
          '*} IN ALL FIELDS RETURNING  Account(Id,Name,mflow__ExternalApplicationNumber__c,FinServ__Status__c,CreatedDate,CreatedBy.Name  ORDER BY CreatedDate Desc)';
      } else {
        searchQuery =
          'FIND {' +
          searchStr1 +
          '*} IN ALL FIELDS RETURNING  Account(Id,Name,mflow__ExternalApplicationNumber__c,FinServ__Status__c,CreatedDate,CreatedBy.Name  WHERE ' +
          dynamicString +
          ' ORDER BY CreatedDate Desc)';
      }
      List<List<sObject>> objectList = new List<List<sObject>>();

      System.debug('searchQuery::' + searchQuery);
      objectList = search.query(searchQuery);

      System.debug('Applications  first' + objectList);
      applicationsList = (List<Account>) objectList[0];
      return applicationsList;
    } else {
      query q = Query.newInstance(Account.SObjectType)
        .addFields()
        .whereNotNull('Name');
      if (!searchFilter.isEmpty()) {
        if (String.isNotBlank(searchFilter.get('AppNumber'))) {
          q.andCon().whereLike('Name', searchFilter.get('AppNumber'));
        }
        if (String.isNotBlank(searchFilter.get('LOSNumber'))) {
          q.andCon()
            .whereLike(
              'mflow__ExternalApplicationNumber__c',
              searchFilter.get('LOSNumber')
            );
        }
      }
      applicationsList = (List<Account>) DatabaseUtils.getRecords(
        q.toString(true)
      );
      System.debug('employeeList second' + applicationsList);
      return applicationsList;
    }
  }
}
