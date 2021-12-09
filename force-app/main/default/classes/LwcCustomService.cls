/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class LwcCustomService extends AbstractService {
  @TestVisible
  private static LwcCustomService serviceInstance;

  global LwcCustomService() {
    super(LwcCustomService.class);
  }

  /**
   * @description Provides a singleton instance of LwcCustomService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  global static LwcCustomService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (LwcCustomService) getInstance(LwcCustomService.class);
    }
    return serviceInstance;
  }

  /**
   * @description readflow by entity id
   * @author Digital Align Team | 10-20-2021
   * @param Map<String Object> params
   * @return List<Flow__c>
   **/
  global virtual List<Flow__c> readFlows(Map<String, Object> params) {
    String entityId = String.valueOf(params?.get('recordId'));
    log?.debug(' recordId : ' + entityId);
    return LwcCustomRepository.fetchFlowByEntityId(entityId);
  }
  /**
   * @description
   * @author Digital Align | 11-17-2021
   * @param Map<String Object> params
   * @return ApplicationConfiguration__c
   **/
  global virtual ApplicationConfiguration__c updateConfigValues(
    Map<String, Object> params
  ) {
    ApplicationConfiguration__c configData = (ApplicationConfiguration__c) JSON.deserialize(
      (string) params.get('configData'),
      ApplicationConfiguration__c.class
    );
    log?.debug(' configData : ' + configData);
    return (ApplicationConfiguration__c) LwcCustomRepository.updateRecord(
      configData
    );
  }

  /**
   * @description  fetch sobject field detail based on sobject name.
   * @author Digital Align Team | 11-30-2021
   * @param String sObjectName
   * @return List<Map<String, String>>  return all field in sobject
   **/
  public virtual List<Map<String, String>> fetchFieldDetails(
    String sObjectName
  ) {
    List<Map<String, String>> fieldNames = new List<Map<String, String>>();

    Map<String, Schema.SObjectField> fieldMap = SObjectUtils.getFields(
      SObjectUtils.getSobjectType(sObjectName)
    );
    for (Schema.SObjectField sfield : fieldMap.Values()) {
      //dField -> describe field
      schema.describefieldresult dField = sfield.getDescribe();
      fieldNames.add(
        new Map<String, String>{
          'key' => dField.getName(),
          'value' => dField.getLabel(),
          'type' => String.valueof(dField.getType())
        }
      );
    }
    return fieldNames;
  }

  /**
   * @description
   * @author Digital Align Team | 12-01-2021
   * @param Id applicationId
   * @return virtual
   **/
  global virtual Account readApplicationWithChild(Id applicationId) {
    Account application = LwcCustomRepository.readApplicationWithChild(
      applicationId
    );

    List<Applicant__c> applicants = LwcCustomRepository.readApplicantsWithChild(
      new Map<id, SObject>(application.Applicants__r).keyset()
    );
    List<FinServ__FinancialAccount__c> financialAccounts = LwcCustomRepository.readFinancialAccountsWithChild(
      new Map<id, SObject>(application.FinServ__HouseholdFinancialAccounts__r)
        .keyset()
    );

    //Combine result into single application object
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObjects('mflow__Applicants__r', applicants);
    builder.setChildObjects(
      'FinServ__HouseholdFinancialAccounts__r',
      financialAccounts
    );
    return (Account) builder.build();
  }

  global virtual map<string, id> readApplicationWithApplicants(
    string applicationId
  ) {
    map<string, id> applicants = new Map<string, id>();
    if (string.isBlank(applicationId)) {
      log?.debug('applicationIdwithin if =' + applicationId);
      throw new CustomException(
        System.Label.Application_ApplicationIdCannotBeBlank
      );
    }
    Account application = ApplicationRepository.readApplicationWithApplicants(
      applicationId
    );
    if (application != null) {
      // for (Applicant__c app : application.Applicant__r) {
      //   applicants.put(app.Name, app.Id);
      // }
    }
    return applicants;
  }

  /**
   * @description fetch sobject field detail based on sobject name and field set name
   * @author Digital Align Team | 11-30-2021
   * @param String sObjectName
   * @param String fieldSetName
   * @return List<Map<String, String>>
   **/
  public virtual List<Map<String, String>> fetchFieldDetails(
    String sObjectName,
    String fieldSetName
  ) {
    List<Map<String, String>> fieldNames = new List<Map<String, String>>();
    //fs -> FiledSet
    Schema.FieldSet fs = SObjectUtils.getFieldSet(
      SObjectUtils.getSobjectType(sObjectName),
      fieldSetName
    );
    //fsm -> FieldSetMember
    for (Schema.FieldSetMember fsm : fs.getFields()) {
      fieldNames.add(
        new Map<String, String>{
          'key' => fsm.getFieldPath(),
          'value' => fsm.getLabel(),
          'type' => String.valueof(fsm.getType())
        }
      );
    }
    return fieldNames;
  }
}
