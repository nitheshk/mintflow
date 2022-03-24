/**
 * Copyright (c) Digital Align 2021
 * @reference https://github.com/4an70m/apex-query-builder
 * @reference https://github.com/jpmonette/q
 * @reference https://github.com/apex-enterprise-patterns/fflib-apex-common
 * @description Soql/Sosl builder for salesforce SObjects
 * @group Utils
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount,PMD.ExcessiveParameterList,PMD.AvoidGlobalModifier,PMD.ExcessiveClassLength,PMD.CognitiveComplexity'
)
global inherited sharing class Query {
  private Query parent;
  private SObjectType sType;
  private Set<String> fieldNames;
  private List<String> whereClause;
  private List<String> orderClause;
  private List<String> groupClause;
  private List<String> havingClause;
  private List<String> ignoreFields;

  private Integer limitClause;
  private Integer offsetClause;
  private Relationship relationType;
  private String relationName;
  private Boolean displayQuery;
  private Boolean enforceSecurity;

  private enum Relationship {
    PARENT,
    CHILD,
    LOOKUP
  }
  /**
   * @description Initialize variable for query object
   * @author Digital Align | 05-03-2021
   * @return Query
   **/
  private Query initialize() {
    this.fieldNames = new Set<String>();
    this.whereClause = new List<String>();
    this.orderClause = new List<String>();
    this.groupClause = new List<String>();
    this.havingClause = new List<String>();
    this.ignoreFields = new List<String>();
    this.enforceSecurity = false;
    this.displayQuery = false;
    return this;
  }

  /**
   * @description  Start the query builder
   * @author Digital Align | 05-16-2021
   * @param Schema.SObjectType sType
   * @return Query
   * @example String q = Query.newInstance(Account.SObjectType).toString();
   **/
  global static Query newInstance(Schema.SObjectType sType) {
    Query q = new Query(sType);
    return q;
  }

  /**
   * @description Start the query builder
   * @author Digital Align | 05-03-2021
   * @param Schema.SObjectType sType
   * @example String q = Query.newInstance(Account.SObjectType).toString();
   **/
  global Query(Schema.SObjectType sType) {
    this(sType, null);
    setRelationship(Relationship.PARENT, null);
  }

  /**
   * @description Create a query for lookup and child
   * @author Digital Align | 05-03-2021
   * @param Schema.SObjectType sType
   * @param Query parent
   **/
  private Query(Schema.SObjectType sType, Query parent) {
    //initialize fields
    initialize();
    //Set object type
    SObjectUtils.getDescribeSObjectResult(sType);
    this.sType = sType;
    this.parent = parent;
  }

  /**
   * @description Create a relationship between Query object
   * @author Digital Align | 05-03-2021
   * @param Relationship relationType
   * @param String relationName
   **/
  private Query setRelationship(Relationship relationType, String relationName) {
    this.relationType = relationType;
    this.relationName = this.relationType == Relationship.PARENT ? SObjectUtils.getObjectName(sType) : relationName;
    return this;
  }

  /**
   * @description SQOL lookup object using field name
   * @author Digital Align | 05-02-2021
   * @param String fieldName
   * @param Boolean byName
   * @return Query
   * @example String q = Query.newInstance(Contact.SObjectType)
   *    .queryLookup('AccountID',true)
   *    .run()
   *    .toString(true);
   **/
  global Query queryLookup(String fieldName, Boolean byFieldName) {
    if (!byFieldName) {
      return queryLookup(fieldName);
    }
    Schema.SObjectField field = SObjectUtils.resolveReferenceByFieldName(this.sType, fieldName);

    if (field == null) {
      GenericUtils.customException('Not found for {0}.{1}', new List<String>{ this.relationName, fieldName });
    }

    return new Query(field.getDescribe().getReferenceTo().get(0), this)
      .setRelationship(Relationship.LOOKUP, resolveApiName(field.getDescribe().getRelationshipName()));
  }

  /**
   * @description SQOL lookup object using relation name
   * @author Digital Align | 05-02-2021
   * @param String fieldRelationName
   * @return Query
   * @example String q = Query.newInstance(Contact.SObjectType)
   *   .queryLookup('Account')
   *   .run()
   *   .toString(true);
   **/
  global Query queryLookup(String fieldRelationName) {
    Schema.SObjectField field = SObjectUtils.resolveReferenceByRelationName(this.sType, fieldRelationName);

    if (field == null) {
      GenericUtils.customException('Not found for {0}.{1}', new List<String>{ this.relationName, fieldRelationName });
    }

    return new Query(field.getDescribe().getReferenceTo().get(0), this)
      .setRelationship(Relationship.LOOKUP, resolveApiName(field.getDescribe().getRelationshipName()));
  }

  /**
   * @description soql lookup object by passing relation name, which retrieve all record with all fields
   * @author Digital Align | 05-06-2021
   * @param String fieldRelationName
   * @return Query
   * @example String q = Query.newInstance(Contact.SObjectType)
   *   .addFields(new List<String>{'Name','LastName','FirstName'})
   *   .buildLookUp('Account')
   *   .toString(true);
   **/
  global Query buildLookup(String fieldRelationName) {
    return this.queryLookup(fieldRelationName).addFields().run();
  }

  /**
   * @description SOQL with child recording by passing child relationship name
   * @author Digital Align | 05-03-2021
   * @param String childRelationName
   * @return Query
   * @example String q = Query.newInstance(Account.SObjectType)
   *     .queryChild('Contacts')
   *     .run()
   *     .toString(true);
   **/
  global Query queryChild(String childRelationName) {
    //nested sub query is not allowed in salesforce
    if (this.parent != null) {
      GenericUtils.customException('Not found for {0}.{1}', new List<String>{ this.relationName, childRelationName });
    }

    //cr->ChildRelationship
    ChildRelationship cr = SObjectUtils.resolveChildReferenceByRelationName(this.sType, childRelationName);

    if (cr == null) {
      GenericUtils.customException('Not found for {0}.{1}', new List<String>{ this.relationName, childRelationName });
    }

    return new Query(cr.getChildSObject(), this).setRelationship(Relationship.CHILD, cr.getRelationshipName());
  }

  /**
   * @description soql child objects by passing relation name, which retrieve all record with all fields
   * @author Digital Align | 05-06-2021
   * @param String childRelationName
   * @return Query
   * @example String q = Query.newInstance(Account.SObjectType)
   *   .addFields()
   *   .buildChild('Contacts')
   *   .toString(true);
   **/
  global Query buildChild(String childRelationName) {
    return this.queryChild(childRelationName).addFields().run();
  }

  /**
   * @description Add all the field from SObject Type
   * @author Digital Align | 05-01-2021
   * @return Query
   * @example String q = Query.newInstance(Account.SObjectType)
   *    .addFields()
   *    .toString();
   **/
  global Query addFields() {
    Map<String, Schema.SObjectField> fields = SObjectUtils.getFields(this.sType);

    for (String f : fields.keySet()) {
      if (!ignoreFields.contains(String.valueOf(fields.get(f)))) {
        fieldNames.add(resolveApiName(String.valueOf(fields.get(f))));
      }
    }
    return this;
  }

  /**
   * @description  Remove Person account merged field to avoid insert/update issue for business account
   * @author Digital Align Team | 07-15-2021
   * @return Query
   **/
  global Query removeMergedFields() {
    String relName = '';
    if (this.relationType == Relationship.LOOKUP) {
      relName = this.relationName + '.';
    }

    Set<String> standardPersonAccountField = new Set<String>{
      relName + 'Salutation',
      relName + 'FirstName',
      relName + 'LastName',
      relName + 'PersonAssistantName',
      relName + 'PersonAssistantPhone',
      relName + 'PersonBirthdate',
      relName + 'PersonDepartment',
      relName + 'PersonDoNotCall',
      relName + 'PersonEmail',
      relName + 'PersonHasOptedOutOfEmail',
      relName + 'PersonHasOptedOutOfFax',
      relName + 'PersonHomePhone',
      relName + 'PersonIndividual',
      relName + 'PersonLastCURequestDate',
      relName + 'PersonLastCUUpdateDate',
      relName + 'PersonLeadSource',
      relName + 'PersonMailingAddress',
      relName + 'PersonMobilePhone',
      relName + 'PersonOtherAddress',
      relName + 'PersonOtherPhone',
      relName + 'PersonTitle'
    };

    fieldNames.removeAll(standardPersonAccountField);

    for (String fieldName : fieldNames.clone()) {
      if (fieldName.endsWith('__pc')) {
        fieldNames.remove(fieldName);
      }
    }
    return this;
  }

  /**
   * @description Add field based on the field-set name from SObject Type
   * @author Digital Align | 05-04-2021
   * @param String fieldSetName
   * @return Query
   * @example  String q = Query.newInstance(Account.SObjectType)
   *   .addFieldset('CustomField')
   *   .toString(true);
   **/
  global Query addFieldSet(String fieldSetName) {
    //fs->fieldSet
    FieldSet fs = SObjectUtils.getFieldSet(this.sType, fieldSetName);

    if (fs == null) {
      GenericUtils.customException('Not found for {0}.{1}', new List<String>{ this.relationName, fieldSetName });
    }

    for (FieldSetMember fsm : fs.getFields()) {
      this.fieldNames.add(resolveApiName(fsm.getFieldPath()));
    }
    return this;
  }

  /**
   * @description  add all Custom Field by passing list of field names
   * @author Digital Align | 05-02-2021
   * @param list<String> fieldNames
   * @return Query
   * @example  String q = Query.newInstance(Contact.SObjectType)
   *   .addFields(new list<String>{'Name','LastName'})
   *   .toString(true);
   **/
  global Query addFields(List<String> fieldNames) {
    for (String f : fieldNames) {
      if (!ignoreFields.contains(f)) {
        this.fieldNames.add(resolveApiName(f));
      }
    }
    return this;
  }

  /**
   * @description Pass list of field names as string by comma separated
   * @author Digital Align | 05-03-2021
   * @param String fieldNames
   * @return Query
   * @example  String q = Query.newInstance(Contact.SObjectType)
   *   .addFields('Name,LastName')
   *   .toString(true);
   **/
  global Query addFields(String fieldNames) {
    if (String.isNotBlank(fieldNames)) {
      return this.addFields(fieldNames.split(QueryConstants.SYB_COMMA));
    }
    return this;
  }

  /**
   * @description Remove fields by passing list of field names
   * @author Digital Align | 05-06-2021
   * @param list<String> fieldNames
   * @return Query
   * @example  String q = Query.newInstance(Contact.SObjectType)
   *    .addFields(new List<String>{'Name','LastName','FirstName'})
   *    .removeFields(new List<String>{'LastName','FirstName'})
   *    .toString(true);
   **/
  global Query removeFields(List<String> fieldNames) {
    List<String> resolvedFiledNames = new List<String>();
    for (String name : fieldNames) {
      resolvedFiledNames.add(this.resolveApiName(name));
    }
    this.fieldNames.removeAll(resolvedFiledNames);
    return this;
  }

  /**
   * @description Remove fields by passing string of field names
   * @author Digital Align | 05-06-2021
   * @param String fieldNames
   * @return Query
   * @example  String q = Query.newInstance(Contact.SObjectType)
   *    .addFields('Name,LastName,FirstName')
   *    .removeFields('LastName,FirstName')
   *    .toString(true);
   **/
  global Query removeFields(String fieldNames) {
    if (String.isNotBlank(fieldNames)) {
      return this.removeFields(fieldNames.split(QueryConstants.SYB_COMMA));
    }
    return this;
  }

  /**
   * @description Soql adding custom where condition without escape single quotes for value
   * @author Digital Align | 05-04-2021
   * @param String condition
   * @return query
   * @example String q = Query.newInstance(Contact.SObjectType)
   *  .addFields('Name')
   *  .whereCon('LastName=\'Rogers\'')
   *  .toString(true);
   **/
  global Query whereCon(String condition) {
    this.whereClause.add(condition);
    return this;
  }

  /**
   * @description  Soql adding where condition which resolve field reference and escape single quotes for value (by default true)
   * @author Digital Align | 05-04-2021
   * @param String fieldName
   * @param String value
   * @return Query
   * @example List<Object> parameters = new List<Object> {'Rogers'};
   * String q = Query.newInstance(Contact.SObjectType)
   *  .addFields('Name')
   *  .whereCon('LastName','={0}')
   *  .toString(true);
   *  List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q,parameters);
   **/
  global Query whereCon(String fieldName, String value) {
    return this.whereCon(fieldName, value, true);
  }

  /**
   * @description Soql adding where condition which resolve field reference and pass true to escape single quotes for value
   * @author Digital Align | 05-06-2021
   * @param String fieldName
   * @param String value
   * @param Boolean escapeSingleQuotes
   * @return Query
   * @example String q = Query.newInstance(Contact.SObjectType)
   *  .addFields('Name')
   *  .whereCon('LastName','=\'Rogers\'',false)
   *  .toString(true);
   **/
  global Query whereCon(String fieldName, String value, Boolean escapeSingleQuotes) {
    this.whereClause.add(resolveApiName(fieldName) + (escapeSingleQuotes ? String.escapeSingleQuotes(value) : value));
    return this;
  }

  /**
   * @description SOQL to create custom where condition by passing field-name,operation and value
   * @author Digital Align Team | 12-21-2021
   * @param String fieldName
   * @param String operation
   * @param Object value
   * @return Query
   * @example String FirstName='Tim';
   * String q = Query.newInstance(Contact.SObjectType)
   *  .addFields('Name')
   *  .whereCon('LastName','=','Barr')
   *  .AndCon()
   *  .whereEq('FirstName','=',FirstName)
   *  .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   **/
  global Query whereCon(String fieldName, String operation, Object value) {
    this.whereClause.add(resolveApiName(fieldName) + operation + formatCriteriaInput(value));

    return this;
  }

  /**
   * @description Soql adding where condition which resolve field reference and pass true to escape single quotes for value
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param Object value
   * @return Query
   * @example String FirstName='Tim';
   * String q = Query.newInstance(Contact.SObjectType)
   *  .addFields('Name')
   *  .whereEq('LastName','Barr')
   *  .AndCon()
   *  .whereEq('FirstName',FirstName)
   *  .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   **/
  global Query whereEq(String fieldName, Object value) {
    this.whereClause.add(resolveApiName(fieldName) + QueryConstants.SYB_EQ + formatCriteriaInput(value));
    return this;
  }

  /**
   * @description Soql adding where condition which resolve field reference and pass true to escape single quotes for value
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param Object value
   * @return Query
   * String FirstName='Tim';
   * String q = Query.newInstance(Contact.SObjectType)
   *  .addFields('Name')
   *  .whereNeq('LastName','Barr')
   *  .AndCon()
   *  .whereNeq('FirstName',FirstName)
   *  .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   **/
  global Query whereNeq(String fieldName, Object value) {
    this.whereClause.add(resolveApiName(fieldName) + QueryConstants.SYB_NEQ + formatCriteriaInput(value));
    return this;
  }

  /**
   * @description Soql adding where condition which resolve field reference and pass true to escape single quotes for value
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param Object value
   * @return Query
   * @Example   String q = Query.newInstance(Contact.SObjectType)
   *   .addFields('Name')
   *   .whereGte('CreatedDate', DateTime.now())
   *   .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   **/
  global Query whereGte(String fieldName, Object value) {
    this.whereClause.add(resolveApiName(fieldName) + QueryConstants.SYB_GTE + formatCriteriaInput(value));
    return this;
  }

  /**
   * @description Soql adding where condition which resolve field reference and pass true to escape single quotes for value
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param Object value
   * @return Query
   * @Example   String q = Query.newInstance(Contact.SObjectType)
   *   .addFields('Name')
   *   .whereGt('CreatedDate', DateTime.now())
   *   .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   **/
  global Query whereGt(String fieldName, Object value) {
    this.whereClause.add(resolveApiName(fieldName) + QueryConstants.SYB_GT + formatCriteriaInput(value));
    return this;
  }

  /**
   * @description Soql adding where condition which resolve field reference and pass true to escape single quotes for value
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param Object value
   * @return Query
   * @Example   String q = Query.newInstance(Contact.SObjectType)
   *   .addFields('Name')
   *   .whereLte('CreatedDate', DateTime.now())
   *   .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   **/
  global Query whereLte(String fieldName, Object value) {
    this.whereClause.add(resolveApiName(fieldName) + QueryConstants.SYB_LTE + formatCriteriaInput(value));
    return this;
  }

  /**
   * @description Soql adding where condition which resolve field reference and pass true to escape single quotes for value
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param Object value
   * @return Query
   * @Example   String q = Query.newInstance(Contact.SObjectType)
   *   .addFields('Name')
   *   .whereLt('CreatedDate', DateTime.now())
   *   .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   **/
  global Query whereLt(String fieldName, Object value) {
    this.whereClause.add(resolveApiName(fieldName) + QueryConstants.SYB_LT + formatCriteriaInput(value));
    return this;
  }

  /**
   * @description Soql adding where condition which resolve field reference and pass true to escape single quotes for value
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @return Query
   * @Example   String q = Query.newInstance(Contact.SObjectType)
   *   .addFields('Name')
   *   .whereNull('FirstName')
   *   .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   **/
  global Query whereNull(String fieldName) {
    this.whereClause.add(resolveApiName(fieldName) + QueryConstants.SYB_EQ + null);
    return this;
  }

  /**
   * @description Soql adding where condition which resolve field reference and pass true to escape single quotes for value
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @return Query
   * @Example   String q = Query.newInstance(Contact.SObjectType)
   *   .addFields('Name')
   *   .whereNotNull('FirstName')
   *   .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   **/
  global Query whereNotNull(String fieldName) {
    this.whereClause.add(resolveApiName(fieldName) + QueryConstants.SYB_NEQ + null);
    return this;
  }

  /**
   * @description Soql adding where in condition which resolve field reference
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param String value
   * @return Query
   * @example
   * String q = Query.newInstance(Account.SObjectType)
   *     .addFields('Name')
   *     .whereIn('Id',
   *          Query.newInstance(Contact.SObjectType)
   *          .addFields('AccountId')
   *          .whereEq('FirstName','Tim')
   *          .toString()
   *     )
   *     .toString(true);
   *   List<Account> sl =(List<Account> ) DatabaseUtils.getRecords(q);
   *   system.debug(system.JSON.Serialize(sl));
   **/
  global Query whereIn(String fieldName, String value) {
    this.whereClause.add(
      resolveApiName(fieldName) +
      QueryConstants.CONDITION_IN +
      QueryConstants.SYB_OPEN_BRACKET +
      value +
      QueryConstants.SYB_CLOSE_BRACKET
    );
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param List<SObject> values
   * @return Query
   * @example
   * List<Contact> sl = (List<Contact> )DatabaseUtils.getRecords(Query.newInstance(Contact.SObjectType).addLimit(2).toString());
   * String q = Query.newInstance(Contact.SObjectType)
   *    .addFields('Name')
   *     .whereIn('Id', sl)
   *     .toString(true);
   *     sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   *   system.debug(system.JSON.Serialize(sl));
   **/
  global Query whereIn(String fieldName, List<SObject> values) {
    return this.whereIn(fieldName, new Map<Id, SObject>(values).keySet());
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param Set<Id> values
   * @return Query
   * @example List<Contact> sl = (List<Contact> )DatabaseUtils.getRecords(Query.newInstance(Contact.SObjectType).addLimit(2).toString());
   *   String q = Query.newInstance(Contact.SObjectType)
   *     .addFields('Name')
   *     .whereIn('Id', new Map<id,SObject>(sl).keyset())
   *     .toString(true);
   *     sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   *   system.debug(system.JSON.Serialize(sl));
   **/
  global Query whereIn(String fieldName, Set<Id> values) {
    return this.whereIn(fieldName, new List<Id>(values));
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param set<Object> values
   * @return Query
   * @Example List<Contact> sl = (List<Contact> )DatabaseUtils.getRecords(Query.newInstance(Contact.SObjectType).addLimit(2).toString());
   *   String q = Query.newInstance(Contact.SObjectType)
   *     .addFields('Name')
   *     .whereIn('Id', new Map<id,SObject>(sl).keyset())
   *     .toString(true);
   *     sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   *   system.debug(system.JSON.Serialize(sl));
   **/
  global Query whereIn(String fieldName, Set<Object> values) {
    return this.whereIn(fieldName, new List<Object>(values));
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param List<Object> values
   * @return Query
   * @Example List<Contact> sl = (List<Contact> )DatabaseUtils.getRecords(Query.newInstance(Contact.SObjectType).addLimit(2).toString());
   *   String q = Query.newInstance(Contact.SObjectType)
   *     .addFields('Name')
   *     .whereIn('Id', new List<id>(new Map<id,SObject>(sl).keyset()))
   *     .toString(true);
   *     sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   *   system.debug(system.JSON.Serialize(sl));
   **/
  global Query whereIn(String fieldName, List<Object> values) {
    if (CollectionUtils.isListEmpty(values)) {
      this.whereClause.add(
        resolveApiName(fieldName) +
        QueryConstants.CONDITION_IN +
        QueryConstants.SYB_OPEN_BRACKET +
        'null' +
        QueryConstants.SYB_CLOSE_BRACKET
      );
      return this;
    }

    List<String> criteriaList = new List<String>();
    for (Object obj : values) {
      criteriaList.add(this.formatCriteriaInput(obj));
    }

    String concatValues = criteriaList.isEmpty() ? '' : String.join(criteriaList, QueryConstants.SYB_COMMA);

    this.whereClause.add(
      resolveApiName(fieldName) +
      QueryConstants.CONDITION_IN +
      QueryConstants.SYB_OPEN_BRACKET +
      concatValues +
      QueryConstants.SYB_CLOSE_BRACKET
    );
    return this;
  }

  /**
   * @description Soql adding where in condition which resolve field reference
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param String value
   * @return Query
   * @example
   * String q = Query.newInstance(Account.SObjectType)
   *     .addFields('Name')
   *     .whereNotIn('Id',
   *          Query.newInstance(Contact.SObjectType)
   *          .addFields('AccountId')
   *          .whereEq('FirstName','Tim')
   *          .toString()
   *     )
   *     .toString(true);
   *   List<Account> sl =(List<Account> ) DatabaseUtils.getRecords(q);
   *   system.debug(system.JSON.Serialize(sl));
   **/
  global Query whereNotIn(String fieldName, String value) {
    this.whereClause.add(
      resolveApiName(fieldName) +
      QueryConstants.CONDITION_NOT_IN +
      QueryConstants.SYB_OPEN_BRACKET +
      String.escapeSingleQuotes(value) +
      QueryConstants.SYB_CLOSE_BRACKET
    );
    return this;
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param List<SObject> values
   * @return Query
   * @example
   * List<Contact> sl = (List<Contact> )DatabaseUtils.getRecords(Query.newInstance(Contact.SObjectType).addLimit(2).toString());
   * String q = Query.newInstance(Contact.SObjectType)
   *    .addFields('Name')
   *     .whereNotIn('Id', sl)
   *     .toString(true);
   *     sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   *   system.debug(system.JSON.Serialize(sl));
   **/
  global Query whereNotIn(String fieldName, List<SObject> values) {
    return this.whereNotIn(fieldName, new Map<Id, SObject>(values).keySet());
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param Set<Id> values
   * @return Query
   * @example List<Contact> sl = (List<Contact> )DatabaseUtils.getRecords(Query.newInstance(Contact.SObjectType).addLimit(2).toString());
   *   String q = Query.newInstance(Contact.SObjectType)
   *     .addFields('Name')
   *     .whereNotIn('Id', new Map<id,SObject>(sl).keyset())
   *     .toString(true);
   *     sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   *   system.debug(system.JSON.Serialize(sl));
   **/
  global Query whereNotIn(String fieldName, Set<Id> values) {
    return this.whereNotIn(fieldName, new List<Id>(values));
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param set<Object> values
   * @return Query
   * @Example List<Contact> sl = (List<Contact> )DatabaseUtils.getRecords(Query.newInstance(Contact.SObjectType).addLimit(2).toString());
   *   String q = Query.newInstance(Contact.SObjectType)
   *     .addFields('Name')
   *     .whereNotIn('Id', new Map<id,SObject>(sl).keyset())
   *     .toString(true);
   *     sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   *   system.debug(system.JSON.Serialize(sl));
   **/
  global Query whereNotIn(String fieldName, Set<Object> values) {
    return this.whereNotIn(fieldName, new List<Object>(values));
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param String fieldName
   * @param List<Object> values
   * @return Query
   * @Example List<Contact> sl = (List<Contact> )DatabaseUtils.getRecords(Query.newInstance(Contact.SObjectType).addLimit(2).toString());
   *   String q = Query.newInstance(Contact.SObjectType)
   *     .addFields('Name')
   *     .whereNotIn('Id', new List<id>(new Map<id,SObject>(sl).keyset()))
   *     .toString(true);
   *     sl =(List<Contact> ) DatabaseUtils.getRecords(q);
   *   system.debug(system.JSON.Serialize(sl));
   **/
  global Query whereNotIn(String fieldName, List<Object> values) {
    if (CollectionUtils.isListEmpty(values)) {
      this.whereClause.add(
        resolveApiName(fieldName) +
        QueryConstants.CONDITION_NOT_IN +
        QueryConstants.SYB_OPEN_BRACKET +
        'null' +
        QueryConstants.SYB_CLOSE_BRACKET
      );
      return this;
    }

    List<String> criteriaList = new List<String>();
    for (Object obj : values) {
      criteriaList.add(this.formatCriteriaInput(obj));
    }

    String concatValues = criteriaList.isEmpty() ? '' : String.join(criteriaList, QueryConstants.SYB_COMMA);

    this.whereClause.add(
      resolveApiName(fieldName) +
      QueryConstants.CONDITION_NOT_IN +
      QueryConstants.SYB_OPEN_BRACKET +
      concatValues +
      QueryConstants.SYB_CLOSE_BRACKET
    );
    return this;
  }

  /**
   * @description   Soql adding where condition along with AND, which resolve field reference and escape single quotes for value (by default true)
   * @author Digital Align | 05-04-2021
   * @param String fieldName
   * @param String value
   * @return Query
   * @example  List<Object> parameters = new List<Object> {'Rogers','Jack'};
   * String q = Query.newInstance(Contact.SObjectType)
   *   .addFields('Name')
   *   .whereAnd('LastName','={0}')
   *   .whereCon('FirstName','={1}')
   *   .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q,parameters);
   **/
  global Query whereAnd(String fieldName, String value) {
    return this.whereAnd(fieldName, value, true);
  }

  /**
   * @description Soql adding where condition along with AND, which resolve field reference and pass true to escape single quotes for value
   * @author Digital Align | 05-06-2021
   * @param String fieldName
   * @param String value
   * @param Boolean escapeSingleQuotes
   * @return Query
   * @example  List<Object> parameters = new List<Object> {'Jack'};
   * String q = Query.newInstance(Contact.SObjectType)
   *   .addFields('Name')
   *   .whereAnd('LastName','=\'Rogers\'',false)
   *   .whereCon('FirstName','={0}')
   *   .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q,parameters);
   **/
  global Query whereAnd(String fieldName, String value, Boolean escapeSingleQuotes) {
    this.whereClause.add(resolveApiName(fieldName) + (escapeSingleQuotes ? String.escapeSingleQuotes(value) : value));
    this.whereClause.add(QueryConstants.CONDITION_AND);
    return this;
  }

  /**
   * @description Soql adding where condition along with OR, which resolve field reference and escape single quotes for value (by default true)
   * @author Digital Align | 05-04-2021
   * @param String fieldName
   * @param String value
   * @return Query
   * @example List<Object> parameters = new List<Object> {'Rogers','Jack'};
   *  String q = Query.newInstance(Contact.SObjectType)
   *   .addFields('Name')
   *   .whereOr('LastName','={0}')
   *   .whereCon('FirstName','={1}')
   *   .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q,parameters);
   **/
  global Query whereOr(String fieldName, String value) {
    return this.whereOr(fieldName, value, true);
  }

  /**
   * @description  Soql adding where condition along with OR, which resolve field reference and pass true to escape single quotes for value
   * @author Digital Align | 05-06-2021
   * @param String fieldName
   * @param String value
   * @param Boolean escapeSingleQuotes
   * @return Query
   * @example   List<Object> parameters = new List<Object> {'Jack'};
   * String q = Query.newInstance(Contact.SObjectType)
   *   .addFields('Name')
   *   .whereOr('LastName','=\'Rogers\'',false)
   *   .whereCon('FirstName','={0}')
   *   .toString(true);
   *   List<Contact> sl =(List<Contact> ) DatabaseUtils.getRecords(q,parameters);
   **/
  global Query whereOr(String fieldName, String value, Boolean escapeSingleQuotes) {
    this.whereClause.add(resolveApiName(fieldName) + (escapeSingleQuotes ? String.escapeSingleQuotes(value) : value));
    this.whereClause.add(QueryConstants.CONDITION_OR);
    return this;
  }

  /**
   * @description SOQL for for multiple picklist comparison by passing list as list of values
   * @author Digital Align | 05-07-2021
   * @param String fieldName
   * @param List<String> values
   * @return Query
   * @example String q = Query.newInstance(Opportunity.SObjectType)
   *    .addFields('Name')
   *    .whereIncludes('CustomMultiSelect__c',new list<String> {'one;two','three'})
   *    .toString(true);
   **/
  global Query whereIncludes(String fieldName, List<String> values) {
    String val =
      resolveApiName(fieldName) +
      QueryConstants.CONDITION_INCLUDES +
      QueryConstants.SYB_OPEN_BRACKET +
      CollectionUtils.joinListByComma(values) +
      QueryConstants.SYB_CLOSE_BRACKET;
    this.whereClause.add(val);
    return this;
  }

  /**
   * @description SOQL for for multiple picklist comparison by passing string as list of value
   * @author Digital Align | 05-07-2021
   * @param String fieldName
   * @param String values
   * @return Query
   * @example String q = Query.newInstance(Opportunity.SObjectType)
   *    .addFields('Name')
   *    .whereIncludes('CustomMultiSelect__c','one;two,three')
   *    .toString(true);
   **/
  global Query whereIncludes(String fieldName, String values) {
    return this.whereIncludes(fieldName, values.split(QueryConstants.SYB_COMMA));
  }

  /**
   * @description Soql for using like operator for wildcards matching (eg %like% )
   * @author Digital Align | 05-07-2021
   * @param String fieldName
   * @param String value
   * @return query
   * @example String q = Query.newInstance(Account.SObjectType)
   *       .addFields('Name')
   *       .whereLike('Name','Burlington')
   *       .toString(true);
   **/
  global Query whereLike(String fieldName, String value) {
    String condition =
      resolveApiName(fieldName) +
      QueryConstants.CONDITION_LIKE +
      '\'%' +
      String.escapeSingleQuotes(value) +
      '%\'';
    return this.whereCon(condition);
  }

  /**
   * @description Soql for using left like for wildcards matching (eg %like )
   * @author Digital Align | 05-07-2021
   * @param String fieldName
   * @param String value
   * @return query
   * @example String q = Query.newInstance(Account.SObjectType)
   *       .addFields('Name')
   *       .whereLeftLike('Name','Burlington')
   *       .toString(true);
   **/
  global Query whereLeftLike(String fieldName, String value) {
    String condition =
      resolveApiName(fieldName) +
      QueryConstants.CONDITION_LIKE +
      '\'%' +
      String.escapeSingleQuotes(value) +
      '\'';
    return this.whereCon(condition);
  }

  /**
   * @description Soql for using right  like for wildcards matching (eg like% )
   * @author Digital Align | 05-07-2021
   * @param String fieldName
   * @param String value
   * @return query
   * @example String q = Query.newInstance(Account.SObjectType)
   *       .addFields('Name')
   *       .whereRightLike('Name','Burlington')
   *       .toString(true);
   **/
  global Query whereRightLike(String fieldName, String value) {
    String condition =
      resolveApiName(fieldName) +
      QueryConstants.CONDITION_LIKE +
      '\'' +
      String.escapeSingleQuotes(value) +
      '%\'';
    return this.whereCon(condition);
  }

  /**
   * @description Soql short cut by passing id directly
   * @author Digital Align | 05-07-2021
   * @param Object recordId
   * @return String
   * @example String q = Query.newInstance(Contact.SObjectType)
   *    .addFields()
   *    .queryById('0031y00000CZ0sBAAT');
   **/
  global String queryById(Object recordId) {
    if (this.parent != null) {
      GenericUtils.customException('ById not allowed for inner Query', null);
    }
    this.whereEq('Id', recordId);
    return this.toString();
  }

  /**
   * @description soql for find distance between a location
   * @author Digital Align | 05-07-2021
   * @param String fieldName
   * @param System.Location destinationLocation
   * @param String unit
   * @param String value
   * @return Query
   * @example String q = Query.newInstance(Contact.SObjectType)
   *   .addFields()
   *   .whereDistance('MailingAddress', Location.newInstance(28.635308,77.22496)  , 'mi','<500')
   *   .toString(true);
   **/
  global Query whereDistance(String fieldName, System.Location destinationLocation, String unit, String value) {
    String condition =
      'DISTANCE(' +
      resolveApiName(fieldName) +
      ', GEOLOCATION(' +
      destinationLocation.getLatitude() +
      ',' +
      destinationLocation.getLongitude() +
      '),\'' +
      String.escapeSingleQuotes(unit) +
      '\')';
    this.whereClause.add(condition + QueryConstants.SYB_SPACE + String.escapeSingleQuotes(value));
    return this;
  }

  /**
   * @description   Soql for and condition
   * @author Digital Align | 05-04-2021
   * @return Query
   * @example String q = Query.newInstance(Contact.SObjectType)
   *   .addFields()
   *   .whereCon('LastName','=\'Rogers\'',true)
   *   .andCon()
   *   .whereCon('FirstName','=\'Rogers\'',true)
   *   .toString(true);
   **/
  global Query andCon() {
    this.whereClause.add(QueryConstants.CONDITION_AND);
    return this;
  }

  /**
   * @description Soql for or condition
   * @author Digital Align | 05-04-2021
   * @return Query
   * @example String q = Query.newInstance(Contact.SObjectType)
   *   .addFields()
   *   .whereCon('LastName','=\'Rogers\'',true)
   *   .orCon()
   *   .whereCon('FirstName','=\'Rogers\'',true)
   *   .toString(true);
   **/
  global Query orCon() {
    this.whereClause.add(QueryConstants.CONDITION_OR);
    return this;
  }

  /**
   * @description Soql for grouping the condition
   * @author Digital Align | 05-04-2021
   * @return Query
   * @example  String q = Query.newInstance(Contact.SObjectType)
   * .addFields()
   *   .grpOpen()
   *   .whereCon('LastName','=\'Rogers\'',true)
   *   .orCon()
   *   .whereCon('FirstName','=\'Jack\'',true)
   *   .grpClose()
   *   .andCon()
   *   .whereCon('Name','=\'Jack Rogers\'',true)
   *   .toString(true);
   **/
  global Query grpOpen() {
    this.whereClause.add(QueryConstants.SYB_OPEN_BRACKET);
    return this;
  }

  /**
   * @description Soql for grouping the condition
   * @author Digital Align | 05-04-2021
   * @return Query
   * @example  String q = Query.newInstance(Contact.SObjectType)
   * .addFields()
   *   .grpOpen()
   *   .whereCon('LastName','=\'Rogers\'',true)
   *   .orCon()
   *   .whereCon('FirstName','=\'Jack\'',true)
   *   .grpClose()
   *   .andCon()
   *   .whereCon('Name','=\'Jack Rogers\'',true)
   *   .toString(true);
   **/
  global Query grpClose() {
    this.whereClause.add(QueryConstants.SYB_CLOSE_BRACKET);
    return this;
  }

  /**
   * @description soql for order by ascending by default  ( ORDER BY Name ASC )
   * @author Digital Align | 05-06-2021
   * @param String fieldName
   * @return Query
   * @example
   *  String q = Query.newInstance(Contact.SObjectType)
   *   .addFields()
   *   .orderBy('Name')
   *   .toString(true);
   **/
  global Query orderBy(String fieldName) {
    return this.orderBy(fieldName, false);
  }

  /**
   * @description  soql for order by descending by passing direction true ( ORDER BY Name DESC )
   * @author Digital Align | 05-06-2021
   * @param String fieldName
   * @param Boolean direction
   * @return Query
   * @example
   *  String q = Query.newInstance(Contact.SObjectType)
   *   .addFields()
   *   .orderBy('Name',true)
   *   .toString(true);
   **/
  global Query orderBy(String fieldName, Boolean direction) {
    String orderBy = direction ? 'DESC' : 'ASC';
    this.orderClause.add(resolveApiName(fieldName) + QueryConstants.SYB_SPACE + orderBy);
    return this;
  }

  /**
   * @description  soql for order by descending by passing direction true ( ORDER BY Name DESC NULLS LAST )
   * @author Digital Align | 05-06-2021
   * @param String fieldName
   * @param Boolean direction
   * @return Query
   * @example
   *  String q = Query.newInstance(Contact.SObjectType)
   *   .addFields()
   *   .orderBy('Name',true,true)
   *   .toString(true);
   **/
  global Query orderBy(String fieldName, Boolean direction, Boolean nullsLast) {
    String orderBy = direction ? 'DESC' : 'ASC';
    String nullValueOrder = nullsLast ? ' NULLS LAST ' : ' NULLS FIRST ';
    this.orderClause.add(resolveApiName(fieldName) + QueryConstants.SYB_SPACE + orderBy + nullValueOrder);
    return this;
  }

  /**
   * @description soql order by distance between a location by default ascending
   * @author Digital Align | 05-07-2021
   * @param String fieldName
   * @param System.Location destinationLocation
   * @param String unit
   * @return QueryBuilder
   * @example String q = Query.newInstance(Contact.SObjectType)
   *   .addFields()
   *   .orderByDistance('MailingAddress',Location.newInstance(28.635308,77.22496),  'mi')
   *   .toString(true);
   **/
  global Query orderByDistance(String fieldName, System.Location destinationLocation, String unit) {
    return this.orderByDistance(fieldName, destinationLocation, unit, false);
  }

  /**
   * @description soql order by distance between a location, pass direction true for descending
   * @author Digital Align | 05-07-2021
   * @param String fieldName
   * @param System.Location destinationLocation
   * @param String unit
   * @param Boolean direction
   * @return Query
   * @example String q = Query.newInstance(Contact.SObjectType)
   *   .addFields()
   *   .orderByDistance('MailingAddress',Location.newInstance(28.635308,77.22496),  'mi',true)
   *   .toString(true);
   **/
  global Query orderByDistance(String fieldName, System.Location destinationLocation, String unit, Boolean direction) {
    String condition =
      'DISTANCE(' +
      resolveApiName(fieldName) +
      ',GEOLOCATION(' +
      destinationLocation.getLatitude() +
      ',' +
      destinationLocation.getLongitude() +
      '),\'' +
      String.escapeSingleQuotes(unit) +
      '\')';

    String orderBy = direction ? 'DESC' : 'ASC';
    this.orderClause.add(condition + QueryConstants.SYB_SPACE + orderBy);
    return this;
  }

  /**
   * @description Add group by fieldname
   * @author Digital Align | 05-06-2021
   * @param String groupByFieldName
   * @return Query
   * @example String q = Query.newInstance(Opportunity.SObjectType)
   *  .addFields('CampaignId, AVG(Amount)')
   *  .groupBy('CampaignId')
   *  .toString(true);
   **/
  global Query groupBy(String groupByFieldName) {
    this.groupClause.add(groupByFieldName);
    return this;
  }

  /**
   * @description Add having custom free condition
   * @author Digital Align | 05-06-2021
   * @param String condition
   * @return Query
   * @example String q = Query.newInstance(Opportunity.SObjectType)
   *  .addFields('CampaignId, AVG(Amount)')
   *  .groupBy('CampaignId')
   *  .havingCon(' AVG(Amount) > 100 And  AVG(Amount) <20000000')
   *  .toString(true);
   **/
  global Query havingCon(String condition) {
    this.havingClause.add(condition);
    return this;
  }

  /**
   * @description  Soql to add limit
   * @author Digital Align | 05-02-2021
   * @param Integer limitClause
   * @return Query
   * @example String q = Query.newInstance(Account.SObjectType)
   *   .addLimit(5)
   *   .toString();
   **/
  global Query addLimit(Integer limitClause) {
    this.limitClause = limitClause;
    return this;
  }

  /**
   * @description Soql to add offset
   * @author Digital Align | 05-02-2021
   * @param Integer limitClause
   * @return Query
   * @example String q = Query.newInstance(Account.SObjectType)
   *   .addOffset(5)
   *   .toString();
   **/
  global Query addOffset(Integer limitClause) {
    this.offsetClause = limitClause;
    return this;
  }

  /**
   * @description  soql based on the custom filter
   * Pass filter tag in ApexRequest header
   * By default all the field are compare with equal sign
   * To override logical operator, Prefix $ same filename and pass logic operator
   * Supported logically operator are =, != , < ,> ,<= ,>= , LIKE , INCLUDES
   * INCLUDES Work for MultiPicklist Fields only
   * Filter Array of objects are consider as OR Operator and Inside Object all Fields are consider as AND operator
   * @author Digital Align Team | 12-21-2021
   * @param String filters
   * @return Query
   * @example String jsonString = '[{"Name":"Test12","$Name":"!=", "mflow__test2__c":["test3","test4"],"$mflow__test2__c":"INCLUDES", "mflow__EventIdentifier__c":"","mflow__isActive__c":true,"mflow__test1__c":43, "mflow__Product__c":""},
   *  {"Name":"Test1","mflow__EventIdentifier__c":"","mflow__isActive__c":true}]';
   * List<Object> filters = (List<Object>) JSON.deserializeUntyped(jsonString);
   * List<ConsentLineItem__c> items = (List<ConsentLineItem__c>) EmailNotificationRepository.getRecords(
   *   Query.newInstance(ConsentLineItem__c.SObjectType)
   *     .addFields()
   *     .filter(filters,'mflow__Filter')
   *     .toString(true)
   *  );
   *  system.debug('items :' + items);
   **/
  global Query filter(Object filtersObj, String fieldSetName) {
    List<Object> filters;
    if (filtersObj instanceof List<Object>) {
      filters = (List<Object>) filtersObj;
    } else if (filtersObj instanceof Map<String, Object>) {
      filters = new List<Object>{ filtersObj };
    } else {
      return this;
    }
    // fs-> FieldSet
    FieldSet fs = SObjectUtils.getFieldSet(this.sType, fieldSetName);
    if (fs == null) {
      GenericUtils.customException('{0} Field Set not found ', new List<String>{ fieldSetName });
    }

    Boolean hasMoreFilter = false;
    this.grpOpen();
    for (Object filterObj : filters) {
      if (hasMoreFilter) {
        this.orCon();
      }
      Map<String, Object> filter = (Map<String, Object>) filterObj;
      this.filter(filter, fs);
      hasMoreFilter = true;
    }
    this.grpClose();
    return this;
  }

  /**
   * @description resolve filter criteria
   * @author Digital Align Team | 12-27-2021
   * @param Map<String Object> filter
   * @param FieldSet fs
   * @return Query
   **/
  private Query filter(Map<String, Object> filter, FieldSet fs) {
    this.grpOpen();
    Boolean hasMoreField = false;
    for (FieldSetMember fsm : fs.getFields()) {
      if (hasMoreField) {
        this.andCon();
      }
      if (filter.containsKey(fsm.getFieldPath())) {
        resolveFilterField(fsm, filter.get(fsm.getFieldPath()), String.valueOf(filter.get('$' + fsm.getFieldPath())));
      } else {
        resolveFilterField(fsm, null, null);
      }
      hasMoreField = true;
    }
    this.grpClose();
    return this;
  }

  /**
   * @description resolve dynamic filter for fields
   * @author Digital Align Team | 12-21-2021
   * @param FieldSetMember fsm
   * @param Object fieldValue
   **/
  private void resolveFilterField(FieldSetMember fsm, Object fieldValue, String logic) {
    switch on fsm.getType() {
      when BOOLEAN {
        this.whereEq(fsm.getFieldPath(), fieldValue != null ? Boolean.valueOf(fieldValue) : false);
      }
      when else {
        switch on logic {
          when '=', '!=', '<', '>', '<=', '>=' {
            this.whereCon(fsm.getFieldPath(), logic, fieldValue != null ? fieldValue : null);
          }
          when 'LIKE' {
            this.whereLike(fsm.getFieldPath(), fieldValue != null ? String.valueOf(fieldValue) : null);
          }
          when 'INCLUDES' {
            if (fieldValue == null) {
              this.whereIncludes(fsm.getFieldPath(), '');
            } else if (fieldValue instanceof String) {
              this.whereIncludes(fsm.getFieldPath(), String.valueOf(fieldValue));
            } else if (fieldValue instanceof List<Object>) {
              this.whereIncludes(
                fsm.getFieldPath(),
                (List<String>) JSON.deserialize(JSON.serialize(fieldValue), List<String>.class)
              );
            }
          }
          when else {
            this.whereEq(fsm.getFieldPath(), fieldValue != null ? fieldValue : null);
          }
        }
      }
    }
  }

  /**
   * @description build a soql for child or parent object
   * @author Digital Align | 05-01-2021
   * @return Query
   * @example String q = Query.newInstance(Contact.SObjectType)
   *   .addFields()
   *     .queryLookup('Account')
   *     .addFields()
   *     .run()
   *   .toString(true);
   **/
  global Query run() {
    switch on this.relationType {
      when CHILD {
        this.parent.fieldNames.add(QueryConstants.SYB_OPEN_BRACKET + toString() + QueryConstants.SYB_CLOSE_BRACKET);
      }
      when LOOKUP {
        if (this.fieldNames.isEmpty()) {
          this.fieldNames.add(resolveApiName(QueryConstants.ID_FIELD));
        }
        this.parent.fieldNames.addAll(this.fieldNames);
        this.parent.whereClause.addAll(this.whereClause);
        this.parent.orderClause.addAll(this.orderClause);
      }
      when else {
        return this;
      }
    }
    return this.parent;
  }

  /**
   * @description Resolve field name relationship
   * @author Digital Align | 05-02-2021
   * @param String relationName
   * @return String
   **/
  private String resolveApiName(String relationName) {
    if (this.relationType == Relationship.LOOKUP) {
      return this.relationName + '.' + relationName;
    }
    return relationName;
  }

  /**
   * @description
   * @author Digital Align Team | 07-13-2021
   * @param Object obj
   * @return String
   **/
  private String formatCriteriaInput(Object obj) {
    if (obj == null) {
      return null;
    } else if (obj instanceof Date) {
      return DateUtils.formatDateGMT((Date) obj);
    } else if (obj instanceof Datetime) {
      return DateUtils.formatDateTimeGMT((Datetime) obj);
    } else if (obj instanceof String) {
      return '\'' + String.escapeSingleQuotes((String) obj) + '\'';
    } else {
      return String.escapeSingleQuotes(String.valueOf(obj));
    }
  }

  /**
   * @description Display soql on run time
   * @author Digital Align | 05-01-2021
   * @return Query
   * @example String q = Query.newInstance(Account.SObjectType)
   *   .addFields()
   *   .debug()
   *   .toString();
   **/
  global Query debug() {
    this.displayQuery = true;
    return this;
  }

  /**
   * @description Enforce security level based on the user context
   * @author Digital Align | 05-03-2021
   * @return Query
   * @example String q = Query.newInstance(Account.SObjectType)
   *   .addFields()
   *   .enforceFLS()
   *   .toString();
   **/
  global Query enforceFLS() {
    this.enforceSecurity = true;
    return this;
  }

  /**
   * @description  Generate soql with displaying soql in system.debug
   * @author Digital Align | 05-02-2021
   * @param Boolean showQuery
   * @return String
   * @example String q = Query.newInstance(Account.SObjectType)
   *   .toString(true);
   **/
  global String toString(Boolean showQuery) {
    if (showQuery) {
      this.debug();
    }
    return this.toString();
  }
  /**
   * @description Generate final soql
   * @author Digital Align | 05-01-2021
   * @return String
   * @example String q = Query.newInstance(Account.SObjectType)
   *   .toString();
   **/
  global override String toString() {
    String queryString = '';

    if (this.fieldNames.isEmpty()) {
      queryString +=
        QueryConstants.QUERY_SELECT +
        QueryConstants.ID_FIELD +
        QueryConstants.QUERY_FROM +
        this.relationName;
    } else {
      queryString +=
        QueryConstants.QUERY_SELECT +
        String.join((Iterable<String>) this.fieldNames, QueryConstants.SYB_COMMA) +
        QueryConstants.QUERY_FROM +
        this.relationName;
    }

    if (!this.whereClause.isEmpty()) {
      queryString += QueryConstants.QUERY_WHERE + String.join(this.whereClause, QueryConstants.SYB_SPACE);
    }

    if (this.enforceSecurity) {
      queryString += QueryConstants.ENFORCE_SECURITY;
    }

    if (!this.groupClause.isEmpty()) {
      queryString += QueryConstants.QUERY_GROUP_BY + String.join(this.groupClause, QueryConstants.SYB_COMMA);
    }

    if (!this.havingClause.isEmpty()) {
      queryString += QueryConstants.QUERY_HAVING + String.join(this.havingClause, QueryConstants.SYB_SPACE);
    }

    if (!this.orderClause.isEmpty()) {
      queryString += QueryConstants.QUERY_ORDER_BY + String.join(this.orderClause, QueryConstants.SYB_COMMA);
    }

    if (this.limitClause != null && this.limitClause > 0) {
      queryString += QueryConstants.QUERY_LIMIT + this.limitClause;
    }

    if (this.offsetClause != null && this.offsetClause > 0) {
      queryString += QueryConstants.QUERY_OFFSET + this.offsetClause;
    }

    if (this.relationType == Relationship.PARENT && this.displayQuery) {
      System.debug(LoggingLevel.DEBUG, 'Query : ' + queryString);
    }

    return queryString;
  }
}
