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
  private static Logger log = Logger.getInstance(SecurityUtils.class);
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
        // dynamicString = ApexUtils.obtainSearchString(searchFilter);
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
      log?.debug('Member search where condition ::' + dynamicString);
      if (searchFilter.isEmpty()) {
        searchQuery =
          'FIND {' +
          searchStr1 +
          '} IN ALL FIELDS RETURNING  mflow__Applicant__c(Id,mflow__FirstName__c,mflow__LastName__c,mflow__Email__c,mflow__Phone__c,mflow__SSN__c,mflow__Application__r.Name,mflow__ApplicantName__c,mflow__KYCStatus__c  ORDER BY CreatedDate Desc)';
      } else {
        searchQuery =
          'FIND {' +
          searchStr1 +
          '} IN ALL FIELDS RETURNING  mflow__Applicant__c(Id,mflow__FirstName__c,mflow__LastName__c,mflow__Email__c,mflow__Phone__c,mflow__SSN__c,mflow__Application__r.Name,mflow__ApplicantName__c,mflow__KYCStatus__c WHERE ' +
          dynamicString +
          ' ORDER BY CreatedDate Desc)';
      }
      log?.debug('Member search query  ::' + searchQuery);
      List<List<sObject>> objectList = new List<List<sObject>>();
      objectList = DatabaseUtils.searchRecords(searchQuery);
      employeeList = (List<Applicant__c>) objectList[0];
      return employeeList;
    } else {
      query q = Query.newInstance(Applicant__c.SObjectType)
        .addFields('mflow__Application__r.Name,mflow__Application__r.Id')
        .addFields()
        .whereNotNull('Name');
      if (!searchFilter.isEmpty()) {
        if (String.isNotBlank(searchFilter.get('mflow__FirstName__c'))) {
          q.andCon()
            .whereLike(
              'mflow__FirstName__c',
              searchFilter.get('mflow__FirstName__c')
            );
        }
        if (String.isNotBlank(searchFilter.get('mflow__LastName__c'))) {
          q.andCon()
            .whereLike(
              'mflow__LastName__c',
              searchFilter.get('mflow__LastName__c')
            );
        }
        if (String.isNotBlank(searchFilter.get('mflow__Email__c'))) {
          q.andCon()
            .whereLike('mflow__Email__c', searchFilter.get('mflow__Email__c'));
        }
        if (String.isNotBlank(searchFilter.get('mflow__Phone__c'))) {
          q.andCon()
            .whereLike('mflow__Phone__c', searchFilter.get('mflow__Phone__c'));
        }
        if (String.isNotBlank(searchFilter.get('mflow__SSN__c'))) {
          q.andCon()
            .whereLike('mflow__SSN__c', searchFilter.get('mflow__SSN__c'));
        }
        if (String.isNotBlank(searchFilter.get('dateRange')))
          q.andCon()
            .whereCon('CreatedDate', '=' + searchFilter.get('dateRange'));
      }
      employeeList = (List<Applicant__c>) DatabaseUtils.getRecords(
        q.toString(true)
      );
      log?.debug('SOQL query ::' + q.toString(true));
      return employeeList;
    }
  }

  /**
   * @description
   * @author Digital Align | 09-23-2021
   * @param String retrieveApplications
   * @param map<string,string> searchFilter
   * @return List<Application__c>
   **/
  public static List<Application__c> retrieveApplications(
    String searchString,
    map<string, string> searchFilter
  ) {
    String searchStr1 = searchString;
    String dynamicString = '';
    String searchQuery;
    Datetime dt;
    DateTime dtAndTime;
    String dateValue;
    String recordTypeName = 'Application';
    List<Application__c> applicationsList = new List<Application__c>();
    Query q;

    if (String.isNotBlank(searchString)) {
      if (searchFilter != null) {
        dynamicString = ApexUtils.obtainSearchString(searchFilter);
        log?.debug('application search sosl filter ::' + dynamicString);
      }
      if (searchFilter.isEmpty()) {
        searchQuery =
          'FIND {' +
          searchStr1 +
          '*} IN ALL FIELDS RETURNING  Application__c(Id,Name,mflow__ExternalApplicationNumber__c,mflow__Status__c,CreatedDate,CreatedBy.Name WHERE RecordType.Name=' +
          '\'' +
          recordTypeName +
          '\'' +
          ' ORDER BY CreatedDate Desc)';
      } else {
        searchQuery =
          'FIND {' +
          searchStr1 +
          '*} IN ALL FIELDS RETURNING  Application__c(Id,Name,mflow__ExternalApplicationNumber__c,mflow__Status__c,CreatedDate,CreatedBy.Name  WHERE RecordType.Name= ' +
          '\'' +
          recordTypeName +
          '\'' +
          ' AND ' +
          dynamicString +
          ' ORDER BY CreatedDate Desc)';
      }
      log?.debug('application sosql  query :' + searchQuery);
      List<List<sObject>> objectList = new List<List<sObject>>();
      objectList = DatabaseUtils.searchRecords(searchQuery);

      applicationsList = (List<Application__c>) objectList[0];
      return applicationsList;
    } else {
      if (searchFilter != null) {
        q = Query.newInstance(Application__c.SObjectType)
          .addFields()
          .addfields('CreatedBy.Name')
          .wherecon('RecordType.Name', recordtypeName);
        if (String.isNotBlank(searchFilter.get('CreatedDateFrom'))) {
          dt = DateUtils.convertJsonStringToDateTime(
            searchFilter.get('CreatedDateFrom')
          );
          dateValue = Dateutils.formatDateTimeGMT(dt);
          q.andCon().whereGte('CreatedDate', dt);
        }
        if (String.isNotBlank(searchFilter.get('CreatedDateTo'))) {
          dt = DateUtils.convertJsonStringToDateTime(
            searchFilter.get('CreatedDateTo')
          );
          dateValue = Dateutils.formatDateTimeGMT(dt);
          q.andCon().wherelte('CreatedDate', dt);
        }
        if (String.isNotBlank(searchFilter.get('dateRange'))) {
          q.andCon()
            .whereCon('CreatedDate', '=' + searchFilter.get('dateRange'));
        }
        if (String.isNotBlank(searchFilter.get('Name'))) {
          q.andCon().whereLike('Name', searchFilter.get('Name'));
        }
        if (
          String.isNotBlank(
            searchFilter.get('mflow__ExternalApplicationNumber__c')
          )
        ) {
          q.andCon()
            .whereLike(
              'mflow__ExternalApplicationNumber__c',
              searchFilter.get('LOSNumber')
            );
        }
        System.debug(' Query is ' + q.toString(true));
        applicationsList = (List<Application__c>) DatabaseUtils.getRecords(
          q.toString(true)
        );

        log?.debug('retrieveApplications Query soql:' + q.toString(true));
        log?.debug('retrieveApplications Filter:' + searchFilter);

        return applicationsList;
      } else {
        return null;
      }
    }
  }
}
