/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Dynamic Data Table Service
 **/

@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class DynamicLWCDataTableService extends AbstractService {
  @TestVisible
  private static DynamicLWCDataTableService serviceInstance;

  public static DynamicDataTable__mdt dynamicDataObj { get; set; }
  public static String QuerySortString { get; set; }
  public static String QueryFilterString { get; set; }

  public static final string profileName = 'System Administrator';

  public DynamicLWCDataTableService() {
    super(DynamicLWCDataTableService.class);
  }

  /**
   * @description Provides a singleton instance of DynamicLWCDataTableService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static DynamicLWCDataTableService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (DynamicLWCDataTableService) getInstance(DynamicLWCDataTableService.class);
    }
    return serviceInstance;
  }
  /**
   * @description Gets the values of table data and columns for metadata
   * @author Digital Align Team | 07-22-2021
   * @return Object  DynamicLWCDataTableResponse
   **/
  public virtual DynamicLWCDataTableResponse getTableDetails(
    String MetaDataName,
    String FilterString,
    String SortString,
    Integer offset,
    Integer limitSize
  ) {
    DynamicLWCDataTableResponse response = new DynamicLWCDataTableResponse();
    String newValue;
    String modifiedValue;
    try {
      if (String.isnotEmpty(MetaDataName)) {
        QuerySortString = SortString;
        QueryFilterString = FilterString;
        List<DynamicDataTable__mdt> dynamicDataList = DynamicLWCDataTableRepository.getTableDetails(
          MetaDataName,
          FilterString,
          SortString
        );
        if (dynamicDataList.size() > 0) {
          dynamicDataObj = dynamicDataList[0];
        }
        response.tableColumns = getTableColumns();
        response.tableData = getTableData(offset, limitSize);
      }
    } catch (exception ex) {
      system.debug(ex.getMessage());
    }
    return response;
  }
  /**
   * @description Gets the values of table columns for displaying dynamic data
   * @author Digital Align Team | 07-22-2021
   * @return Object  DynamicLWCDataTableResponse
   **/
  global virtual String getTableColumns() {
    String returnColumns = '';
    String replacedvalue = '';

    if (dynamicDataObj != null) {
      JSONGenerator gen = JSON.createGenerator(false);
      gen.writeStartArray();

      for (DynamicDataTableItem__mdt column : dynamicDataObj.DynamicDataTableItems__r) {
        gen.writeStartObject();
        gen.writeStringField('label', column.MasterLabel);
        if (String.isBlank(column.ParentObjectAPI__c)) {
          gen.writeStringField('fieldName', column.FieldName__c);
        } else {
          gen.writeStringField('fieldName', column.ParentObjectAPI__c + '.' + column.FieldName__c);
        }

        gen.writeStringField('type', column.Type__c);
        gen.writeBooleanField('sortable', true);
        if (String.isnotEmpty(column.TextAttributes__c)) {
          gen.writeStringField('typeAttributes', column.TextAttributes__c);
        }
        if (String.isnotEmpty(column.CellAttributes__c)) {
          gen.writeStringField('cellAttributes', column.CellAttributes__c);
        }
        gen.writeEndObject();
      }
      gen.writeEndArray();
      returnColumns = gen.getAsString();
      System.debug('columns::' + returnColumns);
    }
    return returnColumns;
  }
  /**
   * @description Method to generate dynamic query based on column
   * @author Digital Align Team | 07-22-2021
   * @return Object  DynamicLWCDataTableResponse
   **/
  global virtual String generateQuery(Integer offset, Integer Limitset) {
    String queryString = '';
    queryString += 'SELECT  ';

    for (DynamicDataTableItem__mdt column : dynamicDataObj.DynamicDataTableItems__r) {
      if (String.isBlank(column.ParentObjectAPI__c)) {
        queryString += column.FieldName__c + ', ';
      } else {
        queryString += column.ParentObjectAPI__c + '.' + column.FieldName__c + ', ';
      }
    }
    queryString = queryString.removeEnd(', ');
    queryString += ' FROM ' + dynamicDataObj.sObject__c;

    if (!String.isBlank(QueryFilterString)) {
      queryString += ' WHERE ' + QueryFilterString;
    }

    if (!String.isBlank(QuerySortString)) {
      queryString += ' Order By ' + QuerySortString + ' LIMIT ' + Limitset + ' OFFSET ' + offset;
    }
    System.debug('queryString::' + queryString);
    return queryString;
  }
  /**
   * @description Gets the values of table data based on dynamic generated query
   * @author Digital Align Team | 07-22-2021
   * @return Object  DynamicLWCDataTableResponse
   **/
  global virtual string getTableData(Integer offset, Integer limitSize) {
    String queryString = generateQuery(offset, limitSize);
    queryString = replaceQueryValues(queryString);
    System.debug('queryString:' + queryString);
    List<SObject> dataList = DatabaseUtils.getRecords(queryString);
    System.debug('dataList:' + dataList);
    String returnData = '';
    JSONGenerator gen = JSON.createGenerator(false);
    gen.writeStartArray();
    for (SObject data : dataList) {
      gen.writeStartObject();
      for (DynamicDataTableItem__mdt column : dynamicDataObj.DynamicDataTableItems__r) {
        SObject target = data;
        if (!String.isBlank(column.ParentObjectAPI__c)) {
          List<String> parents = column.ParentObjectAPI__c.split('\\.');
          for (String parent : parents) {
            target = target.getSobject(parent);
          }
        }

        String elementValue = target != null &&
          target.get(column.FieldName__c) != null
          ? String.valueOf(target.get(column.FieldName__c))
          : '';
        if (String.isnotBlank(column.ParentObjectAPI__c)) {
          gen.writeStringField(column.ParentObjectAPI__c + '.' + column.FieldName__c, check(elementValue));
        } else {
          gen.writeStringField(column.FieldName__c, check(elementValue));
        }
      }
      gen.writeEndObject();
    }
    gen.writeEndArray();
    returnData = gen.getAsString();
    return returnData;
  }
  /**
   * @description method to repl;ace the accountId from the query
   * @author Digital Align Team | 07-22-2021
   * @return Object  DynamicLWCDataTableResponse
   **/
  private static String replaceQueryValues(String queryString) {
    if (queryString.Contains('$accountId')) {
      String acntId = getLoggedinUserAccountId();
      queryString = queryString.replace('$accountId', acntId);
    }
    if (queryString.Contains('$userContactId')) {
      queryString = queryString.replace('$userContactId', userutils.getCurrentUser().ContactId);
    }
    return queryString;
  }

  public static String check(String value) {
    if (value == null) {
      return '';
    }
    return value;
  }
  /**
   * @description Method to fetch logged in users account id
   * @author Digital Align Team | 07-22-2021
   * @return Object  DynamicLWCDataTableResponse
   **/
  private static String getLoggedinUserAccountId() {
    User usr = UserUtils.getCurrentUser();
    Account acnt;
    String profileName = 'System Administrator';
    acnt = UserUtils.fetchUserAccountByUserId(usr.Id);
    if (acnt == null) {
      Profile profile = UtilsRepository.fetchProfileByName(profileName);
      if (userInfo.getProfileId().equals(profile.Id)) {
        ApexResponse response = LWCFinancialInstituteSiteController.fetchFinancialInstituteAccount();
        acnt = (Account) response.data;
      } else {
        throw new CustomException(System.Label.FinInst_BusinessAccountHasNotSetup);
      }
    }
    return acnt.id;
  }
}
