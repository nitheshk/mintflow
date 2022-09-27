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
   * @description Clone Application into new Application
   * @author Digital Align Team | 03-18-2022
   * @param Map<String Object> params
   * @return Application__c
   **/
  global virtual Application__c cloneReferralApplication(Map<String, Object> params) {
    String applicationId = (String) params.get('appId');
    String internalProductCode = (string) params.get('pid');
    String ch = (string) params.get('ch');
    List<String> pIds = internalProductCode.split(',');
    Application__c oldApplication = ApplicationRepository.readApplicationToClone(applicationId);
    List<Applicant__c> oldApplicants = ApplicationRepository.readApplicantsToClone(oldApplication.Id);
    List<FinancialProduct__c> selectedProductList = FinancialAccountRepository.readFinancialProductsByMultipleCodes(
      pIds
    );
    List<FinancialAccount__c> financialAccounts = new List<FinancialAccount__c>();

    if (oldApplication == null || selectedProductList == null) {
      throw new CustomException('Something went wrong! Check application number and product');
    }

    //Application
    Application__c newApplication = oldApplication.clone(false, true, false, false);
    newApplication.ParentApplication__c = oldApplication.Id;
    newApplication.Status__c = ApplicationConstant.IN_PROGRESS;
    newApplication.CreatedChannel__c = oldApplication.LastUsedChannel__c = ch;
    newApplication.ApplicationType__c = selectedProductList[0].Type__c;
    newApplication.UiRouting__c = selectedProductList[0].UiRouting__c;
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
    for (FinancialProduct__c selectedProduct : selectedProductList) {
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
      financialAccounts.add(financialAccount);
    }
    FinancialAccountRepository.upsertRecords(financialAccounts);

    //Applicants
    List<Applicant__c> newApplicants = new List<Applicant__c>();
    Applicant__c newPrimaryApplicant;
    for (Applicant__c oldApplicant : oldApplicants) {
      Applicant__c newApplicant = oldApplicant.clone(false, true, false, false);
      newApplicant.Application__c = newApplication.Id;
      //Primary Applicant
      if (oldApplicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        newPrimaryApplicant = newApplicant;
        newApplicant.IsExistingCustomer__c = true;
        newApplicant.FlowState__c = '';
        newApplicant.FlowType__c = 'ApplicationFlow';
        newApplicant.Status__c = ApplicationConstant.IN_PROGRESS;
      } else {
        newApplicant.FlowType__c = 'ApplicationFlow';
        newApplicant.Status__c = ApplicationConstant.SUBMITTED;
      }
      newApplicants.add(newApplicant);
    }
    ApplicationRepository.upsertRecords(newApplicants);
    ApexRequest.setApplicantId(newPrimaryApplicant.Id);
    //Applicant Child

    List<IdentificationDocument__c> newIdentityDocs = new List<IdentificationDocument__c>();
    List<Employment__c> newEmployments = new List<Employment__c>();
    List<Address__c> newAddreses = new List<Address__c>();
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
      for (Address__c oldAddress : newApplicant.Addresses__r) {
        Address__c newAddress = oldAddress.clone(false, true, false, false);
        newAddress.Applicant__c = newApplicant.Id;
        newAddreses.add(newAddress);
      }
    }
    ApplicationRepository.upsertRecords(newIdentityDocs);
    ApplicationRepository.upsertRecords(newEmployments);
    ApplicationRepository.upsertRecords(newAddreses);

    return newApplication;
  }

  /**
   * @description
   * @author Digital Align Team | 06-30-2022
   * @param Map<String Object> params
   * @return Application__c
   **/
  global virtual Application__c cloneExistingApplication(Map<String, Object> params) {
    String applicationId = (String) params.get('applicationIdToClone');
    String pid = (string) params.get('pid');
    String ch = (string) params.get('ch');
    log?.debug('Product Code::' + pid);

    List<String> productCodes = String.isNotBlank(pid) ? pid?.split(',') : new List<String>();
    Application__c oldApplication = ApplicationRepository.readApplicationToClone(applicationId);
    List<Applicant__c> oldApplicants = ApplicationRepository.readPrimaryApplicantsToClone(oldApplication.Id);
    List<FinancialProduct__c> selectedProducts = FinancialAccountRepository.readFinancialProductsByMultipleCodes(
      productCodes
    );

    if (oldApplication == null || selectedProducts.isEmpty()) {
      throw new CustomException('Something went wrong! Check application number and product');
    }

    //Application
    Application__c newApplication = oldApplication.clone(false, true, false, false);
    newApplication.ParentApplication__c = oldApplication.Id;
    newApplication.Status__c = ApplicationConstant.IN_PROGRESS;
    newApplication.CreatedChannel__c = oldApplication.LastUsedChannel__c = String.isNotBlank(ch)
      ? ch
      : ApplicationConstant.CHANNEL_VIRTUAL;
    newApplication.ApplicationType__c = selectedProducts[0].Type__c;
    newApplication.UiRouting__c = selectedProducts[0].UiRouting__c;
    newApplication.IsExistingCustomer__c = true;
    newApplication.FlowState__c = ApplicationConstant.PERSONAL_INFO;
    newApplication.FlowType__c = 'ApplicationFlow';
    newApplication.Source__c = 'ExistingOnlineFlow';
    newApplication.Version__c = ApplicationConfiguration__c.getInstance().PackageVersion__c;
    newApplication.IPAddress__c = ApplicationServiceHelper.getInstance().getIpAddress();
    newApplication = this.resolveBranchLocation(newApplication);
    ApplicationRepository.upsertRecord(newApplication);

    ApexRequest.setApplicationId(newApplication.Id);
    //Financial Account
    List<FinancialAccount__c> financialAccountList = new List<FinancialAccount__c>();
    for (FinancialProduct__c selectedProduct : selectedProducts) {
      FinancialAccount__c financialAccount = new FinancialAccount__c();
      financialAccount.FinancialProduct__c = selectedProduct.Id;
      financialAccount.Ownership__c = oldApplicants.size() > 1 ? 'Joint' : 'Individual';
      financialAccount.Status__c = ApplicationConstant.IN_PROGRESS;
      financialAccount.Stage__c = 'Active';
      financialAccount.Application__c = newApplication.Id;
      financialAccount.RecordTypeId = SObjectUtils.recordTypeIdByName(
        FinancialAccount__c.SObjectType,
        selectedProduct.Category__c
      );
      financialAccountList.add(financialAccount);
    }
    financialAccountList[0].IsPrimary__c = true;
    ApplicationRepository.upsertRecords(financialAccountList);

    //Applicants
    List<Applicant__c> newApplicants = new List<Applicant__c>();
    Applicant__c newPrimaryApplicant;
    for (Applicant__c oldApplicant : oldApplicants) {
      Applicant__c newApplicant = oldApplicant.clone(false, true, false, false);
      newApplicant.Application__c = newApplication.Id;
      //Primary Applicant
      if (oldApplicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        newPrimaryApplicant = newApplicant;
        newApplicant.IsExistingCustomer__c = true;
        newApplicant.FlowState__c = ApplicationConstant.PERSONAL_INFO;
        newApplicant.FlowType__c = ApplicationConstant.FLOW_TYPE_APPLICATION;
        newApplicant.Status__c = ApplicationConstant.IN_PROGRESS;
      } else {
        newApplicant.FlowType__c = ApplicationConstant.FLOW_TYPE_APPLICATION;
        newApplicant.Status__c = ApplicationConstant.SUBMITTED;
      }
      newApplicants.add(newApplicant);
    }
    ApplicationRepository.upsertRecords(newApplicants);
    ApexRequest.setApplicantId(newPrimaryApplicant.Id);
    //Applicant Child

    List<IdentificationDocument__c> newIdentityDocs = new List<IdentificationDocument__c>();
    List<Employment__c> newEmployments = new List<Employment__c>();
    List<Address__c> newAddreses = new List<Address__c>();
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
      for (Address__c oldAddress : newApplicant.Addresses__r) {
        Address__c newAddress = oldAddress.clone(false, true, false, false);
        newAddress.Applicant__c = newApplicant.Id;
        newAddreses.add(newAddress);
      }
    }
    ApplicationRepository.upsertRecords(newIdentityDocs);
    ApplicationRepository.upsertRecords(newEmployments);
    ApplicationRepository.upsertRecords(newAddreses);

    return newApplication;
  }
}
