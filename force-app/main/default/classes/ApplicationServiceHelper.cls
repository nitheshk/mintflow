/**
 * Copyright (c) 2021 Digital Align
 * @group Helper
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class ApplicationServiceHelper extends AbstractService {
  @TestVisible
  private static ApplicationServiceHelper serviceInstance;

  public ApplicationServiceHelper() {
    super(ApplicationServiceHelper.class);
  }

  /**
   * @description Provides a singleton instance of ApplicationServiceHelper from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static ApplicationServiceHelper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicationServiceHelper) getInstance(ApplicationServiceHelper.class);
    }
    return serviceInstance;
  }

  /**
   * @description get current ipaddress
   * @author Digital Align Team | 10-11-2021
   * @return String
   **/
  global virtual String getIpAddress() {
    String ipAddress;
    //System.auth.SessionManagement.getCurrentSession().get('SourceIp');

    if (ApexPages.currentPage() != null && String.isBlank(ipAddress)) {
      ipAddress = ApexPages.currentPage().getHeaders().get('True-Client-IP');
      // X-Salesforce-SIP has the value when no caching integration or via secure URL.
      if (String.isBlank(ipAddress)) {
        ipAddress = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
      }
      // get IP address when no caching (sandbox, dev, secure urls)
      if (String.isBlank(ipAddress)) {
        ipAddress = ApexPages.currentPage().getHeaders().get('X-Forwarded-For');
      }
    }
    log?.info('getIpAddress -> IP address -> ' + ipAddress);
    return ipAddress;
  }

  /**
   * @description resolve branch location
   * @author Digital Align Team | 12-03-2021
   * @param Application__c application
   * @return Application__c
   **/
  global virtual Application__c resolveBranchLocation(Application__c application) {
    //#pending Create a Branch Object to connect application
    application.BranchCode__c = '0001';
    application.BranchName__c = 'Main Branch';
    return application;
  }

  /**
   * @description update application flow state
   * @author Digital Align Team | 01-13-2022
   * @param Application__c application
   * @param Applicant__c applicant
   * @return Application__c
   **/
  global virtual Application__c updateFlowState(Application__c application, List<Applicant__c> applicants) {
    if (ApexRequest.getApplicantType() == 'Primary') {
      for (Applicant__c applicant : applicants) {
        if (applicant.mflow__ApplicantType__c == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
          applicant.FlowState__c = ApexRequest.getRequest().currentPage;
          applicant.FlowType__c = ApexRequest.getFlowType();
          applicant.sessionExpireTime__c = Datetime.now()
            .addMinutes((Integer) ApplicationConfiguration__c.getOrgDefaults().SessionExpirationTime__c);
          ApplicationRepository.UpsertRecord(applicant);
          break;
        }
      }
      application.FlowState__c = ApexRequest.getRequest().currentPage;
      application.FlowType__c = ApexRequest.getFlowType();
      ApplicationRepository.UpsertRecord(application);
    } else if (ApexRequest.getApplicantType() == 'Joint') {
      for (Applicant__c applicant : applicants) {
        if (applicant.Id == ApexRequest.getApplicantId()) {
          applicant.FlowState__c = ApexRequest.getRequest().currentPage;
          applicant.FlowType__c = ApexRequest.getFlowType();
          applicant.sessionExpireTime__c = Datetime.now()
            .addMinutes((Integer) ApplicationConfiguration__c.getOrgDefaults().SessionExpirationTime__c);
          ApplicationRepository.UpsertRecord(applicant);
          break;
        }
      }
    }
    return application;
  }

  /**
   * @description Clone Application into new Application
   * @author Digital Align Team | 03-18-2022
   * @param Map<String Object> params
   * @return Application__c
   **/
  global virtual Application__c cloneApplicationRecord(Map<String, Object> params) {
    String applicationName = (String) params.get('app');
    String internalProductCode = (string) params.get('pid');
    String ch = (string) params.get('ch');

    Application__c oldApplication = ApplicationRepository.readApplicationToClone(applicationName);
    List<Applicant__c> oldApplicants = ApplicationRepository.readApplicantsToClone(oldApplication.Id);
    FinancialProduct__c selectedProduct = FinancialAccountRepository.readFinancialProductByInternalCode(
      internalProductCode
    );

    if (oldApplication == null || selectedProduct == null) {
      throw new CustomException('Something went wrong! Check application number and product');
    }

    //Application
    Application__c newApplication = oldApplication.clone(false, true, false, false);
    newApplication.ParentApplication__c = oldApplication.Id;
    newApplication.Status__c = ApplicationConstant.IN_PROGRESS;
    newApplication.CreatedChannel__c = oldApplication.LastUsedChannel__c = ch;
    newApplication.ApplicationType__c = selectedProduct.Type__c;
    newApplication.IsExistingCustomer__c = true;
    newApplication.FlowState__c = 'Review';
    newApplication.FlowType__c = 'ApplicationFlow';
    newApplication.Source__c = 'Additional Product';
    newApplication.Version__c = ApplicationConfiguration__c.getInstance().PackageVersion__c;
    newApplication.IPAddress__c = ApplicationServiceHelper.getInstance().getIpAddress();
    newApplication = this.resolveBranchLocation(newApplication);
    ApplicationRepository.upsertRecord(newApplication);

    ApexRequest.setApplicationId(newApplication.Id);
    //Financial Account
    FinancialAccount__c financialAccount = new FinancialAccount__c();
    financialAccount.FinancialProduct__c = selectedProduct.Id;
    financialAccount.Ownership__c = oldApplicants.size() > 1 ? 'Joint' : 'Individual';
    financialAccount.Status__c = ApplicationConstant.IN_PROGRESS;
    financialAccount.Stage__c = 'Active';
    financialAccount.isPrimary__c = true;
    financialAccount.Application__c = newApplication.Id;
    financialAccount.RecordTypeId = SObjectUtils.recordTypeIdByName(
      FinancialAccount__c.SObjectType,
      selectedProduct.Category__c
    );
    FinancialAccountRepository.upsertRecord(financialAccount);

    //Applicants
    List<Applicant__c> newApplicants = new List<Applicant__c>();
    Applicant__c newPrimaryApplicant;
    for (Applicant__c oldApplicant : oldApplicants) {
      Applicant__c newApplicant = oldApplicant.clone(false, true, false, false);
      newApplicant.Application__c = newApplication.Id;
      newApplicant.FlowState__c = '';
      newApplicant.FlowType__c = 'ApplicationFlow';
      newApplicant.Status__c = ApplicationConstant.IN_PROGRESS;
      //Primary Applicant
      if (oldApplicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        newPrimaryApplicant = newApplicant;
        newApplicant.IsExistingCustomer__c = true;
      }
      newApplicants.add(newApplicant);
    }
    ApplicationRepository.upsertRecords(newApplicants);
    ApexRequest.setApplicantId(newPrimaryApplicant.Id);
    //Applicant Child

    List<IdentificationDocument__c> newIdentityDocs = new List<IdentificationDocument__c>();
    List<Employment__c> newEmployments = new List<Employment__c>();
    List<ContactPointAddress> newAddreses = new List<ContactPointAddress>();
    for (Applicant__c newApplicant : newApplicants) {
      //Identification Document
      for (IdentificationDocument__c oldIdentityDoc : newApplicant.IdentificationDocuments__r) {
        IdentificationDocument__c newIdentityDoc = oldIdentityDoc.clone(false, true, false, false);
        newIdentityDoc.Applicant__c = newApplicant.Id;
        newIdentityDocs.add(newIdentityDoc);
      }
      //Employment
      for (Employment__c oldEmployment : newApplicant.Employments__r) {
        Employment__c newEmployment = oldEmployment.clone(false, true, false, false);
        newEmployment.Applicant__c = newApplicant.Id;
        newEmployments.add(newEmployment);
      }
      // //Contact Point Address
      for (ContactPointAddress oldAddress : newApplicant.ContactPointAddresses__r) {
        ContactPointAddress newAddress = oldAddress.clone(false, true, false, false);
        newAddress.Applicant__c = newApplicant.Id;
        newAddreses.add(newAddress);
      }
    }
    ApplicationRepository.upsertRecords(newIdentityDocs);
    ApplicationRepository.upsertRecords(newEmployments);
    ApplicationRepository.upsertRecords(newAddreses);

    return newApplication;
  }

  public Map<String, Object> calculateLeadScore(Application__c application) {
    Map<String, Object> mapData = new Map<String, Object>();
    Map<String, String> mapFilter = new Map<String, String>();
    String productId;

    List<financialProduct__c> products = ProductServiceRepository.fetchProductWithFeatures(application.Id);
    try {
      if (products != null && products.size() > 0) {
        //Calcuate Lead Score based on product and State weightage;
        mapFilter.put('Type', 'State');
        mapFilter.put('Category', products[0].Category__c);
        mapFilter.put('Value', application.mflow__FlowState__c);
        mapData = calculateLeadBasedonState(mapfilter, mapData, products[0]);

        //Calculate the lead score based on eligibility
        mapFilter = new Map<String, String>();
        mapFilter.put('Type', 'Eligibility');
        mapFilter.put('Value', application.IsCountyEligible__c ? 'True' : 'False');
        mapData = calculateLeadBasedonEligibility(mapfilter, mapData);
        //Calculate the lead score based on KYC
        mapFilter = new Map<String, String>();
        mapFilter.put('Type', 'KYC');
        mapFilter.put('Value', application.mflow__KYCStatus__c == 'Passed' ? 'True' : 'False');
        System.debug('  mapData filter kyc::' + mapFilter);
        mapData = calculateLeadBasedonKYC(mapfilter, mapData);

        System.debug('  mapData Final::' + mapData);
      }
    } catch (exception ex) {
      system.debug(' exception at : ' + ex.getLineNumber() + ex.getMessage());
    }

    return null;
  }

  public Map<String, Object> calculateLeadBasedonState(
    Map<String, String> mapFilter,
    Map<String, Object> mapData,
    financialProduct__c product
  ) {
    Decimal weightage;
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
    leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
    if (leadConfigList != null && leadConfigList.size() > 0) {
      weightage = leadConfigList[0].Weightage__c * product.Weightage__c;
      mapData.put(
        'Product : ' +
        product.Name +
        ', Completion State  : ' +
        mapFilter.get('Value') +
        ', State Score  ',
        weightage
      );
    }
    return mapData;
  }

  public Map<String, Object> calculateLeadBasedonEligibility(
    Map<String, String> mapFilter,
    Map<String, Object> mapData
  ) {
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
    leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
    if (leadConfigList.size() > 0) {
      mapData.put('Eligibility Score', (Object) (leadConfigList[0].Weightage__c));
    }
    return mapdata;
  }

  public Map<String, object> calculateLeadBasedonKYC(Map<String, String> mapFilter, Map<String, Object> mapData) {
    system.debug('leadConfigList::');
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
    leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
    if (leadConfigList.size() > 0) {
      system.debug('leadConfigList::' + leadConfigList);
      mapData.put('KYC Score', (Object) (leadConfigList[0].Weightage__c));
    }
    return mapdata;
  }
}
