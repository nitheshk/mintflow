/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class LwcCustomService extends AbstractService {
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
  global virtual ApplicationConfiguration__c updateConfigValues(Map<String, Object> params) {
    ApplicationConfiguration__c configData = (ApplicationConfiguration__c) JSON.deserialize(
      (string) params.get('configData'),
      ApplicationConfiguration__c.class
    );
    log?.debug(' configData : ' + configData);
    return (ApplicationConfiguration__c) LwcCustomRepository.updateRecord(configData);
  }

  /**
   * @description  fetch sobject field detail based on sobject name.
   * @author Digital Align Team | 11-30-2021
   * @param String sObjectName
   * @return List<Map<String, String>>  return all field in sobject
   **/
  public virtual List<Map<String, String>> fetchFieldDetails(String sObjectName) {
    List<Map<String, String>> fieldNames = new List<Map<String, String>>();

    Map<String, Schema.SObjectField> fieldMap = SObjectUtils.getFields(SObjectUtils.getSobjectType(sObjectName));
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
  global virtual Application__c readApplicationWithChild(Id applicationId) {
    Application__c application = LwcCustomRepository.readApplicationWithChild(applicationId);

    List<Applicant__c> applicants = LwcCustomRepository.readApplicantsWithChild(
      new Map<id, SObject>(application.Applicants__r).keyset()
    );
    List<FinancialAccount__c> financialAccounts = LwcCustomRepository.readFinancialAccountsWithChild(
      new Map<id, SObject>(application.mflow__FinancialAccounts__r).keyset()
    );

    //Combine result into single application object
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObjects('mflow__Applicants__r', applicants);
    builder.setChildObjects('mflow__FinancialAccounts__r', financialAccounts);
    return (Application__c) builder.build();
  }

  /**
   * @description read applicants using applicationId
   * @author Digital Align | 12-13-2021
   * @param string applicationId
   * @return list<map<string, string>>
   **/
  global virtual list<map<string, string>> readApplicationWithApplicants(string applicationId) {
    list<map<string, string>> results = new List<map<string, string>>();

    if (string.isBlank(applicationId)) {
      throw new CustomException(System.Label.Application_ApplicationIdCannotBeBlank);
    }
    list<id> ids = new List<id>();
    Application__c application = ApplicationRepository.readApplicationWithApplicants(applicationId);
    if (application != null) {
      for (Applicant__c applicant : application.Applicants__r) {
        if (
          applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE ||
          applicant.RecordType.Name == ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
        ) {
          map<string, string> result = new Map<string, string>();
          ids.add(applicant.Id);
          result.put('label', applicant.ApplicantName__c + ' (' + applicant.ApplicantType__c + ')');
          result.put('value', applicant.Id);
          results.add(result);
        }
      }
      results.add(new Map<string, string>{ 'label' => 'All', 'value' => JSON.serialize(ids) });
    }
    return results;
  }

  /**
   * @description  readApplicationForResume
   * @author Digital Align Team | 04-04-2022
   * @param Map<String Object> params
   * @return Application__c
   **/
  global virtual Application__c readApplicationForResume(Map<String, Object> params) {
    Id recordId = (Id) params.get('recordId');
    string filter = (string) params.get('filter');
    Application__c application = LwcCustomRepository.readApplicationForResume(recordId, filter);
    if (application == null) {
      throw new customException('No Record Found');
    }
    return application;
  }
  /**
   * @description send resume application email to list of applicants
   * @author Digital Align | 12-10-2021
   * @param list<id> applicantIds
   * @return virtual
   **/
  global virtual void sendResumeApplicationEmail(list<id> applicantIds) {
    List<Applicant__c> applicants = ApplicantRepository.readApplicantsById(applicantIds);
    if (CollectionUtils.isListEmpty(applicants)) {
      throw new CustomException(System.Label.Applicant_ApplicantNotFound);
    }
    for (Applicant__c applicant : applicants) {
      CustomerEmailService.getInstance().resumeApplication(applicant);
    }
  }

  /**
   * @description fetch sobject field detail based on sobject name and field set name
   * @author Digital Align Team | 11-30-2021
   * @param String sObjectName
   * @param String fieldSetName
   * @return List<Map<String, String>>
   **/
  public virtual List<Map<String, String>> fetchFieldDetails(String sObjectName, String fieldSetName) {
    List<Map<String, String>> fieldNames = new List<Map<String, String>>();
    //fs -> FiledSet
    Schema.FieldSet fs = SObjectUtils.getFieldSet(SObjectUtils.getSobjectType(sObjectName), fieldSetName);
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
  global virtual Map<String, Map<String, Object>> fetchPickListValues(Map<String, Object> params) {
    Map<String, Map<String, Object>> result = new Map<String, Map<String, Object>>();

    for (String sType : params.keySet()) {
      List<String> fieldNames = (List<String>) JSON.deserialize(JSON.serialize(params.get(sType)), List<String>.class);
      Schema.DescribeSObjectResult sObjectResult = Schema.getGlobalDescribe().get(sType).getDescribe();
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
            new Map<String, String>{ 'label' => picklistEntry.getLabel(), 'value' => picklistEntry.getValue() }
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
  global virtual Sobject updateKycDecision(Map<String, Object> params) {
    log?.fine('inside updateKycDecision');
    id recordID = (Id) params.get('recordId');
    String sobjectType = (String) params.get('objectApiName');
    string status = (string) params.get('status');
    switch on sobjectType {
      when 'mflow__Applicant__c' {
        Applicant__c applicant = LwcCustomRepository.readApplicantById(recordID);
        if (status == ApplicationConstant.KYC_PASSED) {
          applicant.mflow__KYCStatus__c = ApplicationConstant.KYC_PASSED;
        } else if (status == ApplicationConstant.KYC_FAILED) {
          applicant.mflow__KYCStatus__c = ApplicationConstant.KYC_FAILED;
        }
        LwcCustomRepository.upsertRecord(applicant);

        String message = 'Updated - Kyc Status to : ' + status + ' of Applicant : ' + applicant.ApplicantName__c;
        NotificationService.getInstance()
          .dispatchKycNotification(
            'onManualKycAction',
            applicant.mflow__Application__c,
            applicant.mflow__Application__r.Name,
            message
          );
        return applicant;
      }
      when 'mflow__Application__c' {
        Application__c application = LwcCustomRepository.readApplicationWithApplicants(recordID);
        ApexRequest.setApplicationId(application.Id);
        ApexRequest.setApplicationName(application.Name);

        NotificationService.getInstance()
          .dispatchKycNotification(
            'onManualKycAction',
            application.Id,
            application.Name,
            'Updated - Kyc Status to : ' + status
          );

        if (status == ApplicationConstant.KYC_PASSED) {
          application.KYCStatus__c = ApplicationConstant.KYC_PASSED;
          for (Applicant__c applicant : application.Applicants__r) {
            applicant.mflow__KYCStatus__c = ApplicationConstant.KYC_PASSED;
          }
        } else if (status == ApplicationConstant.KYC_FAILED) {
          application.Status__c = ApplicationConstant.CANCELLED;
          application.KYCStatus__c = ApplicationConstant.KYC_FAILED;
          for (Applicant__c applicant : application.Applicants__r) {
            applicant.mflow__Status__c = ApplicationConstant.CANCELLED;
            applicant.mflow__KYCStatus__c = ApplicationConstant.KYC_FAILED;
          }
        }
        LwcCustomRepository.upsertRecords(application.Applicants__r);
        LwcCustomRepository.upsertRecord(application);

        if (application.KYCStatus__c == ApplicationConstant.KYC_PASSED) {
          return SubmitApplicationService.getInstance().validateSubmission(application);
        }
        return application;
      }
      when else {
        throw new CustomException('Incorrect object type');
      }
    }
  }

  /**
   * @description
   * @author Digital Align Team | 04-03-2022
   * @param Map<String Object> params
   * @return Object
   **/
  global virtual Object lwcRecordLevelVisibility(Map<String, Object> params) {
    Id recordId = (Id) params.get('recordId');
    String objectApiName = (String) params.get('objectApiName');
    string filter = (string) params.get('filter');
    SObject record = LwcCustomRepository.readSObjectById(recordId, objectApiName, filter);
    if (record == null) {
      throw new customException('No Record Found');
    }
    return record;
  }

  /**
   * @description send resume application email to list of applicants
   * @author Digital Align | 12-10-2021
   * @param list<id> applicantIds
   * @return virtual
   **/
  global virtual string generateResumeLink(list<id> applicantIds) {
    List<Applicant__c> applicants = ApplicantRepository.readApplicantsById(applicantIds);
    if (CollectionUtils.isListEmpty(applicants)) {
      throw new CustomException(System.Label.Applicant_ApplicantNotFound);
    }
    Map<String, String> params = new Map<String, String>();
    for (Applicant__c applicant : applicants) {
      if (applicant.ApplicantType__c == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        params.put('flw', 'ApplicationFlow');
        params.put('urlSuffix', '/savings/main-app/otp');
        params.put('aplType', ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE);
      } else {
        params.put('flw', 'JointFlow');
        params.put('urlSuffix', '/savings/joint-app/otp');
        params.put('aplType', ApplicationConstant.APPLICANT_JOINT_RECORDTYPE);
      }
      params.put('aplId', applicant.Id);
      params.put('ch', 'Virtual');
    }
    return CustomerEmailService.getInstance().generateUrl(params);
  }

  /**
   * @description
   * @author Digital Align Team | 05-26-2022
   * @param Id applicationId
   * @return List<Map<String, String>>
   **/
  global virtual List<Map<String, String>> fetchApplicantNames(Id applicationId) {
    List<Map<String, String>> applicantNames = new List<Map<String, String>>();
    for (Applicant__c applicant : LwcCustomRepository.readApplicationWithApplicants(applicationId)?.Applicants__r) {
      if (
        applicant.recordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE ||
        applicant.RecordType.Name == ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
      ) {
        applicantNames.add(new Map<String, String>{ 'label' => applicant.ApplicantName__c, 'value' => applicant.Id });
      }
    }
    return applicantNames;
  }

  /**
   * @description
   * @author Digital Align Team | 05-30-2022
   * @param DocumentRequest__c documentRequest
   * @return DocumentRequest__c
   **/
  global virtual DocumentRequest__c createDocumentRequest(DocumentRequest__c documentRequest) {
    LwcCustomRepository.insertRecord(documentRequest);
    Applicant__c applicant = LwcCustomRepository.readApplicantById(documentRequest.Applicant__c);
    CustomerEmailService.getInstance().documentRequestInitiated(applicant, documentRequest);
    return documentRequest;
  }
}
