/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class ApplicantService extends AbstractService {
  @TestVisible
  private static ApplicantService serviceInstance;
  private ApplicantServiceHelper helper = ApplicantServiceHelper.getInstance();

  public ApplicantService() {
    super(ApplicantService.class);
  }

  /**
   * @description Provides a singleton instance of ApplicantService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static ApplicantService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (ApplicantService) getInstance(ApplicantService.class);
    }
    return serviceInstance;
  }

  /**
   * @description Read all applicant by applicant records
   * @author Digital Align Team | 10-26-2021
   * @param List<Applicant__c> applicants
   **/
  global virtual List<Applicant__c> readApplicantsWithChild(List<Applicant__c> applicants) {
    return readApplicantsWithChild(new Map<Id, SObject>(applicants).keySet());
  }

  /**
   * @description Read all applicant by applicant Ids
   * @author Digital Align Team | 10-26-2021
   * @param Set<Id> applicantIds
   **/
  global virtual List<Applicant__c> readApplicantsWithChild(Set<Id> applicantIds) {
    List<Applicant__c> applicants = ApplicantRepository.readApplicantsWithChild(applicantIds);

    for (Integer i = 0; i < applicants.size(); i++) {
      if (!applicants[i].AssetAndLiabilities__r.isEmpty()) {
        SObjectConstructor builder = SObjectConstructor.getInstance(applicants[i]);
        builder.setChildObjects(
          'mflow__AssetAndLiabilities__r',
          ApplicantRepository.readAssetAndLiabilityWithChild(applicants[i].AssetAndLiabilities__r)
        );
        applicants[i] = (Applicant__c) builder.build();
      }
    }
    return applicants;
  }

  /**
   * @description Read applicant by applicant Id
   * @author Digital Align Team | 10-26-2021
   * @param String applicantId
   **/
  global virtual Applicant__c readApplicantWithChild(Id applicantId) {
    Applicant__c applicant = ApplicantRepository.readApplicantWithChild(applicantId);

    if (!applicant.AssetAndLiabilities__r.isEmpty()) {
      SObjectConstructor builder = SObjectConstructor.getInstance(applicant);
      builder.setChildObjects(
        'mflow__AssetAndLiabilities__r',
        ApplicantRepository.readAssetAndLiabilityWithChild(applicant.AssetAndLiabilities__r)
      );
      applicant = (Applicant__c) builder.build();
    }
    return applicant;
  }

  /**
   * @description before saving Applicants
   * @author Digital Align Team | 11-09-2021
   * @param List<Applicant__c> applicants
   * @return List<Applicant__c>
   **/
  global virtual List<Applicant__c> beforeSaveApplicants(List<Applicant__c> applicants) {
    return applicants;
  }

  /**
   * @description Save applicants with child record
   * @author Digital Align Team | 10-25-2021
   * @param String applicationId
   * @param List<Applicant__c> applicants
   * @return virtual
   **/
  global virtual List<Applicant__c> saveApplicants(List<Applicant__c> applicants, String applicationId) {
    //#pending applicationId never used
    //before saving applicants
    applicants = ApplicantService.getInstance().beforeSaveApplicants(applicants);
    //save point count against DML operation
    Savepoint sp = Database.setSavepoint();
    try {
      applicants = ApplicationPersistService.getInstance().saveApplicants(applicants, ApexRequest.getApplicationId());
    } catch (Exception ex) {
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
    //after saving appliants and child records
    return ApplicantService.getInstance().afterSaveApplicants(applicants);
  }
  /**
   * @description after saving applicants
   * @author Digital Align Team | 11-09-2021
   * @param List<Applicant__c> applicants
   * @return virtual
   **/
  global virtual List<Applicant__c> afterSaveApplicants(List<Applicant__c> applicants) {
    String currentPage = ApexRequest.getRequest().currentPage;
    switch on currentPage {
      when 'PersonalInfo' {
        if (ApexRequest.getApplicantType() == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
          helper.notifyFamilyConnectReference(ApexRequest.getApplicationId());
        }
      }
    }
    return applicants;
  }

  /**
   * @description save applicant with child record
   * @author Digital Align Team | 10-27-2021
   * @param Applicant__c applicant
   * @param String applicationId
   * @return Applicant__c
   **/
  global virtual Applicant__c saveApplicant(Applicant__c applicant, String applicationId) {
    return this.saveApplicants(new List<Applicant__c>{ applicant }, applicationId)[0];
  }

  /**
   * @description create Initial Primary Applicant when an empty application has started
   * @author Digital Align Team | 03-08-2022
   * @param Application__c application
   * @return Applicant__c
   **/
  global virtual Applicant__c createInitialPrimaryApplicant(Application__c application) {
    Applicant__c applicant = new Applicant__c();
    applicant.ApplicantType__c = ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE;
    applicant.IsExistingCustomer__c = false;
    applicant.RecordTypeId = SObjectUtils.recordTypeIdByName(
      Applicant__c.SObjectType,
      ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE
    );
    applicant.Status__c = ApplicationConstant.IN_PROGRESS;
    applicant.Application__c = application.Id;
    ApplicationRepository.upsertRecord(applicant);
    return applicant;
  }

  /**
   * @description to verify KYC of the applicant using alloy provider
   * @author Digital Align Team | 03-08-2022
   * @param Application__c application
   * @return Applicant__c
   **/
  global String verifyKYC(Id applicantId) {
    AlloyProvider provider = new AlloyProvider();
    try {
      Flow.initialize(ApexRequest.getApplicationId());
      Flow.setFlow('Alloy KYC');
      Flow.setSubFlow(APINames.AlloyKYC.name(), ApexRequest.getApplicantId());
      HttpResponse response = provider.doIDVVerification(applicantId);
      if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
        Flow.setSubFlowPassed('Passed');
        provider.saveApplicantVerification(applicantId, response);
        provider.ParseIDVReponse(applicantId, response);
      } else {
        Flow.setSubFlowPassed('Failed');
        throw new customException(
          'KYC API returned some error with Status Code:' +
          response.getStatusCode() +
          ' and message =' +
          response.getStatus()
        );
      }
      return 'KYC Verified successfully';
    } catch (exception ex) {
      log?.debug(ex);
      throw new customException('There was sone error encountered to perform KYC of the applicant');
    }
  }

  /**
   * @description
   * @author Digital Align Team | 03-28-2022
   * @param Id applicationId
   * @return Application__c
   **/
  global virtual Application__c validateExistingCustomer(Id applicationId) {
    Application__c application = ApplicantRepository.readApplicationWithPrimary(applicationId);
    Applicant__c primaryApplicant = application.Applicants__r[0];
    Contact existingContact = ApplicantRepository.fetchExistingContact(primaryApplicant);
    FinancialProduct__c baseProduct = FinancialAccountRepository.readBaseProduct();

    Savepoint sp = Database.setSavepoint();
    try {
      Boolean hasBaseProduct = false;
      for (FinancialAccount__c fainancialAccount : application.FinancialAccounts__r) {
        if (fainancialAccount.ProductCode__c == baseProduct.InternalCode__c) {
          hasBaseProduct = true;
        }
      }

      if (hasBaseProduct && existingContact != null) {
        throw new CustomException('You already have Membership Account');
      }

      if (!hasBaseProduct && existingContact == null) {
        List<CustomerInterest__c> customerInterestList = new List<CustomerInterest__c>();
        application.IsExistingCustomer__c = false;
        for (FinancialAccount__c fainancialAccount : application.FinancialAccounts__r) {
          CustomerInterest__c customerInterest = new CustomerInterest__c();
          customerInterest.Application__c = application.Id;
          customerInterest.Name = fainancialAccount.FinancialProduct__r.Name;
          customerInterest.InterestProduct__c = fainancialAccount.FinancialProduct__c;
          customerInterest.Focus__c = ApplicationConstant.CUSTOMER_INTEREST_FOCUS_INITIAL_INTEREST;
          customerInterest.isSelected__c = true;
          customerInterest.mflow__Required__c = true;
          customerInterestList.add(customerInterest);
        }
        FinancialAccountRepository.upsertRecords(customerInterestList);
        FinancialAccountRepository.deleteRecords(application.FinancialAccounts__r);
        // create base product
        FinancialAccountService.getInstance().createInitialFinancialAccount(application);
      } else if (!hasBaseProduct && existingContact != null) {
        application.IsExistingCustomer__c = true;
        ApplicantRepository.upsertRecord(application);

        primaryApplicant.contact__c = existingContact.Id;
        primaryApplicant.IsExistingCustomer__c = true;
        ApplicantRepository.upsertRecord(primaryApplicant);
      }
    } catch (exception ex) {
      Database.rollback(sp);
      throw ex;
    }

    if (ApexRequest.getApplicantType() == 'Primary') {
      return ApplicationService.getInstance().readApplicationWithChild(applicationId);
    } else if (ApexRequest.getApplicantType() == 'Joint') {
      return ApplicationService.getInstance().readApplicationWithChild(applicationId, ApexRequest.getApplicantId());
    } else {
      return null;
    }
  }
}
