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

  /**
   * @description read applicants using applicationId
   * @author Digital Align | 12-13-2021
   * @param string applicationId
   * @return virtual
   **/
  global virtual list<map<string, string>> readApplicationWithApplicants(
    string applicationId
  ) {
    list<map<string, string>> applicants = new List<map<string, string>>();

    if (string.isBlank(applicationId)) {
      throw new CustomException(
        System.Label.Application_ApplicationIdCannotBeBlank
      );
    }
    list<id> ids = new List<id>();
    Account application = ApplicationRepository.readApplicationWithApplicants(
      applicationId
    );
    if (application != null) {
      for (Applicant__c app : application.Applicants__r) {
        map<string, string> applicant = new Map<string, string>();

        if (
          app.RecordType.Name ==
          ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE ||
          app.RecordType.Name == ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
        ) {
          ids.add(app.Id);
          applicant.put('label', app.Name + ' (' + app.ApplicantType__c + ')');
          applicant.put('value', app.Id);
          applicants.add(applicant);
        }
      }
      applicants.add(
        new Map<string, string>{
          'label' => 'All',
          'value' => JSON.serialize(ids)
        }
      );
    }
    return applicants;
  }
  /**
   * @description send resume application email to list of applicants
   * @author Digital Align | 12-10-2021
   * @param list<id> applicantIds
   * @return virtual
   **/
  global virtual void sendResumeApplicationEmail(list<id> applicantIds) {
    List<Applicant__c> applicants = ApplicantRepository.readApplicantsById(
      applicantIds
    );
    if (CollectionUtils.isListEmpty(applicants)) {
      throw new CustomException(System.Label.Applicant_ApplicantNotFound);
    }
    for (Applicant__c app : applicants) {
      CustomerEmailService.getInstance().resumeApplication(app);
    }
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
  /**
   * @description fetch picklsit value of salesforce field
   * @author Digital Align | 12-13-2021
   * @param Map<String Object> params
   * @return virtual
   * * @example format of parameter
   *  {
        Lead : [
            "LeadSource",
            "Staus" 
        ]
      }
   **/
  global virtual Map<String, Map<String, Object>> fetchPickListValues(
    Map<String, Object> params
  ) {
    Map<String, Map<String, Object>> result = new Map<String, Map<String, Object>>();

    for (String sType : params.keySet()) {
      List<String> fieldNames = (List<String>) JSON.deserialize(
        JSON.serialize(params.get(sType)),
        List<String>.class
      );
      Schema.DescribeSObjectResult sObjectResult = Schema.getGlobalDescribe()
        .get(sType)
        .getDescribe();
      result.put(sType, new Map<String, Object>());
      for (String fieldName : fieldNames) {
        List<Object> picklistValues = new List<Object>();
        for (
          Schema.PicklistEntry picklistEntry : sObjectResult.fields.getMap()
            .get(fieldName)
            .getDescribe()
            .getPicklistValues()
        ) {
          picklistValues.add(
            new Map<String, String>{
              'label' => picklistEntry.getLabel(),
              'value' => picklistEntry.getValue()
            }
          );
        }
        result.get(sType).put(fieldName, picklistValues);
      }
    }
    return result;
  }
  /**
   * @description update status field of application or applicant on kyc decision
   * @author Digital Align | 12-15-2021
   * @param Map<String Object> params
   * @return virtual
   **/
  global virtual void updateKycDecision(Map<String, Object> params) {
    log?.fine('inside updateKycDecision');
    id recordID = (Id) params.get('recordId');
    String sobjectType = (String) params.get('objectApiName');
    string status = (string) params.get('status');
    string approvalType = (string) params.get('approvalType');
    switch on sobjectType {
      when 'mflow__Applicant__c' {
        Applicant__c applicant = ApplicantRepository.readApplicantById(
          recordID
        );
        if (
          applicant.RecordType.Name == 'Primary' &&
          status == ApplicationConstant.APPROVED
        ) {
          applicant.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
        }
        applicant.mflow__Status__c = status;
        ApplicantRepository.upsertRecord(applicant);
      }
      when 'Account' {
        Account application = ApplicationRepository.readApplicationWithApplicants(
          recordID
        );
        if (approvalType == 'UpdateApplication') {
          if (status == ApplicationConstant.APPROVED) {
            application.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
          }
          application.FinServ__Status__c = status;
          ApplicationRepository.upsertRecord(application);
        } else {
          updateApplicationStatus(recordID, sobjectType, status, approvalType);
        }
      }
      when else {
        throw new CustomException('Incorrect object type');
      }
    }
    log?.fine('Completed updateKycDecision');
  }

  /**
   * @description update application status or applicant status based on selected condition
   * @author Digital Align | 12-16-2021
   * @param Id recordID
   * @param string sobjectType
   * @param string status
   * @param String approvalType
   * @return virtual
   **/
  global virtual void updateApplicationStatus(
    Id recordID,
    string sobjectType,
    string status,
    String approvalType
  ) {
    log?.fine('inside updateApplicationStatus');
    Account application = ApplicationRepository.readApplicationWithApplicants(
      recordID
    );
    switch on approvalType {
      when 'updateApplicationAndApplicant' {
        for (Applicant__c app : application.Applicants__r) {
          if (
            status == ApplicationConstant.APPROVED &&
            app.RecordType.Name == 'Primary'
          ) {
            app.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
          }
          app.mflow__Status__c = status;
        }
        application.FinServ__Status__c = status;
        application.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
        ApplicationRepository.upsertRecords(application.Applicants__r);
        ApplicationRepository.upsertRecord(application);
      }
      when 'updateApplicationAndPrimary' {
        for (Applicant__c app : application.Applicants__r) {
          if (app.RecordType.Name == 'Primary') {
            if (status == ApplicationConstant.APPROVED) {
              app.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
            }
            app.mflow__Status__c = status;
          }
        }
        application.FinServ__Status__c = status;
        application.FlowState__c = ApplicationConstant.FUNDING_WELCOME;
        ApplicationRepository.upsertRecords(application.Applicants__r);
        ApplicationRepository.upsertRecord(application);
      }
      when else {
        throw new CustomException('Incorrect kyc approval type');
      }
    }
    log?.fine('Completed updateApplicationStatus');
  }

  /**
   * @description fetch related files for given related ids
   * @author Digital Align | 12-21-2021
   * @param List<String> relatedEntityIds
   * @return list<Object>
   **/
  global list<Object> fetchRelatedFiles(List<String> relatedEntityIds) {
    List<ContentVersion> fileList = FileService.getInstance()
      .fetchContentVersionByEntityIds(relatedEntityIds, true);
    return fileList;
  }
}
