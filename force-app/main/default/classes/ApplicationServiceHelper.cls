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

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Application__c application
   * @return Decimal
   **/
  public Decimal calculateLeadScore(Application__c application) {
    Map<String, Object> mapData = new Map<String, Object>();
    Map<String, String> mapFilter = new Map<String, String>();
    String productId;
    Decimal leadScore = 0.00;

    List<financialProduct__c> products = ProductServiceRepository.fetchProductWithFeatures(application.Id);
    System.debug('products::' + products);
    try {
      if (products != null && products.size() > 0) {
        //Calcuate Lead Score based on product and State weightage;
        mapFilter.put('Type', 'State');
        mapFilter.put('Value', application.mflow__FlowState__c);
        mapData = calculateLeadBasedonState(mapfilter, mapData, products);
        system.debug('mapData::' + mapData);

        if (mapData.containsKey('Product State') && (Decimal) mapData.get('Product State') > 0) {
          //Calculate the lead score based on eligibility
          mapFilter = new Map<String, String>();
          mapFilter.put('Type', 'Eligibility');
          mapFilter.put('Value', application.IsCountyEligible__c ? 'True' : 'False');
          mapData = calculateLeadBasedonEligibility(mapfilter, mapData);
          //Calculate the lead score based on KYC
          mapFilter = new Map<String, String>();
          mapFilter.put('Type', 'KYC');
          mapFilter.put('Value', application.mflow__KYCStatus__c == 'Passed' ? 'True' : 'False');
          mapData = calculateLeadBasedonKYC(mapfilter, mapData);

          mapFilter = new Map<String, String>();
          mapFilter.put('Type', 'KYCLeadScore');
          mapData = calculateLeadBasedonKYCScore(mapfilter, mapData, application);

          mapFilter = new Map<String, String>();
          mapfilter.put('Type', 'Employment');
          mapData = calculateLeadBasedonEmployment(mapfilter, mapData, application);
          mapData = calculateLeadBasedonCustomerInterest(mapData, application);
          leadscore = calculateTotalLeadScore(mapData);
        }
      }
    } catch (exception ex) {
      log?.error(ex);
    }
    return leadScore;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String String> mapFilter
   * @param Map<String Object> mapData
   * @param financialProduct__c product
   * @return Map<String, Object>
   **/
  private Map<String, Object> calculateLeadBasedonState(
    Map<String, String> mapFilter,
    Map<String, Object> mapData,
    List<financialProduct__c> products
  ) {
    try {
      Decimal weightage = 0.00;
      List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
      leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
      for (financialProduct__c product : products) {
        if (leadConfigList != null && leadConfigList.size() > 0) {
          weightage = weightage + leadConfigList[0].Weightage__c * product.Weightage__c;
        }
      }
      mapData.put('Product State', weightage);
    } catch (Exception ex) {
      log?.error(ex);
    }
    return mapData;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String String> mapFilter
   * @param Map<String Object> mapData
   * @return Map<String, Object>
   **/
  private Map<String, Object> calculateLeadBasedonEligibility(
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

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String String> mapFilter
   * @param Map<String Object> mapData
   * @return Map<String, object>
   **/
  private Map<String, object> calculateLeadBasedonKYC(Map<String, String> mapFilter, Map<String, Object> mapData) {
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
    leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
    if (leadConfigList.size() > 0) {
      mapData.put('KYC Status Score', (Object) (leadConfigList[0].Weightage__c));
    }
    return mapdata;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String String> mapFilter
   * @param Map<String Object> mapData
   * @param Application__c application
   * @return Map<String, object>
   **/
  private Map<String, object> calculateLeadBasedonKYCScore(
    Map<String, String> mapFilter,
    Map<String, Object> mapData,
    Application__c application
  ) {
    Decimal creditScore = 0,
      leadScore = 0,
      calculatedLeadScore = 0,
      totalScore = 0,
      totalOOWScore = 0,
      calculatedOOWScores = 0;
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
    List<applicant__c> applicants = application.applicants__r;
    Integer totalApplicants = 0;

    leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
    for (applicant__c applicant : applicants) {
      if (
        applicant.mflow__ApplicantType__c.equalsignorecase('Joint') ||
        applicant.mflow__ApplicantType__c.equalsignorecase('Primary')
      ) {
        creditScore = applicant.CreditScore__c;
        for (LeadConfiguration__c leadConfig : leadConfigList) {
          if (
            leadConfig.Type__c == 'KYCLeadScore' &&
            creditScore >= leadConfig.MinValue__c &&
            creditScore <= leadConfig.MaxValue__c
          ) {
            leadScore = leadConfig.Weightage__c;
            totalApplicants++;
            totalScore = totalScore + leadScore;
          }
        }
      }
    }
    //OOW calculations
    mapFilter = new Map<String, String>();
    mapFilter.put('Type', 'OOW');
    totalApplicants = 0;
    leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
    for (applicant__c applicant : applicants) {
      if (
        applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE ||
        applicant.RecordType.Name == ApplicationConstant.APPLICANT_JOINT_RECORDTYPE
      ) {
        creditScore = applicant.CreditScore__c;
        for (LeadConfiguration__c leadConfig : leadConfigList) {
          if (leadConfig.Type__c == 'OOW' && applicant.OOWVerified__c) {
            if (leadConfig.Value__c == 'Passed' && applicant.mflow__OOWStatus__c == 'Passed') {
              totalOOWScore = totalOOWScore + leadConfig.Weightage__c;
            }
            if (leadConfig.Value__c == 'Failed' && applicant.mflow__OOWStatus__c == 'Failed') {
              totalOOWScore = totalOOWScore + leadConfig.Weightage__c;
            }
            totalApplicants++;
          }
        }
      }
    }

    if (totalApplicants > 0) {
      calculatedLeadScore = totalScore / totalApplicants;
      calculatedOOWScores = totalOOWScore / totalApplicants;

      if (leadConfigList.size() > 0) {
        mapData.put('KYC Score', (Object) (calculatedLeadScore));
        mapData.put('OOW Score', (Object) (calculatedOOWScores));
      }
    }
    return mapdata;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String String> mapFilter
   * @param Map<String Object> mapData
   * @param Application__c application
   * @return Map<String, Object>
   **/
  private Map<String, Object> calculateLeadBasedonEmployment(
    Map<String, String> mapFilter,
    Map<String, Object> mapData,
    Application__c application
  ) {
    Decimal creditScore = 0,
      leadScore = 0,
      calculatedLeadScore = 0,
      totalScore = 0,
      totalOOWScore = 0,
      calculatedOOWScores = 0;
    Boolean employmentVerified = false;
    List<LeadConfiguration__c> leadConfigList = new List<LeadConfiguration__c>();
    List<applicant__c> applicants = application.applicants__r;
    Integer totalApplicants = 0;

    leadConfigList = ApplicationRepository.fetchLeadConfiguration(mapFilter);
    for (applicant__c applicant : applicants) {
      if (!applicant.mflow__ApplicantType__c.equalsignorecase('Emergency Contact')) {
        employmentVerified = applicant.mflow__IsEmploymentVerified__c;
        for (LeadConfiguration__c leadConfig : leadConfigList) {
          if (
            leadConfig.Type__c == 'Employment' &&
            leadConfig.Value__c == String.valueof(applicant.mflow__IsEmploymentVerified__c)
          ) {
            leadScore = leadConfig.Weightage__c;
            totalApplicants++;
            totalScore = totalScore + leadScore;
          }
        }
      }
    }
    calculatedLeadScore = totalScore / totalApplicants;
    mapData.put('Employment', (Object) (calculatedLeadScore));
    return mapData;
  }

  /**
   * @description
   * @author Digital Align Team | 08-02-2022
   * @param Map<String Object> mapData
   * @param Application__c application
   * @return Map<String, Object>
   **/
  private Map<String, Object> calculateLeadBasedonCustomerInterest(
    Map<String, Object> mapData,
    Application__c application
  ) {
    List<mflow__CustomerInterest__c> customerInterests = ApplicationRepository.readCustomerInterestbyApplication(
      application.Id
    );
    if (customerInterests.size() > 0) {
      mapData.put('Customer Interest', (object) 10);
    } else {
      mapData.put('Customer Interest', (object) 5);
    }
    return mapData;
  }

  /**
   * @description
   * @author Digital Align Team | 06-15-2022
   * @param Map<String Object> mapData
   * @return Decimal
   **/
  private Decimal calculateTotalLeadScore(Map<String, Object> mapData) {
    // final mapData {Customer Interest=10, Eligibility Score=10, Employment=5, KYC Score=5, KYC Status Score=10, OOW Score=5, Product State=10}
    Decimal totalLeadScore = 0;
    totalLeadScore =
      totalLeadScore + (mapData.containsKey('Customer Interest') ? (decimal) mapData.get('Customer Interest') : 0.00);
    totalLeadScore =
      totalLeadScore + (mapData.containsKey('Eligibility Score') ? (Decimal) mapData.get('Eligibility Score') : 0.00);
    totalLeadScore = totalLeadScore + (mapData.containsKey('Employment') ? (Decimal) mapData.get('Employment') : 0.00);
    totalLeadScore = totalLeadScore + (mapData.containsKey('KYC Score') ? (Decimal) mapData.get('KYC Score') : 0.00);

    totalLeadScore =
      totalLeadScore + (mapData.containsKey('KYC Status Score') ? (Decimal) mapData.get('KYC Status Score') : 0.00);
    totalLeadScore =
      totalLeadScore + (mapData.containsKey('Product State') ? (Decimal) mapData.get('Product State') : 0.00);

    return totalLeadScore;
  }
}
