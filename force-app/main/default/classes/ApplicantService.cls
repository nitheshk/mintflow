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
    return ApplicantRepository.readApplicantsWithChild(applicantIds);
  }

  /**
   * @description Read applicant by applicant Id
   * @author Digital Align Team | 10-26-2021
   * @param String applicantId
   **/
  global virtual Applicant__c readApplicantWithChild(Id applicantId) {
    return ApplicantRepository.readApplicantWithChild(applicantId);
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
   * @description before saving Applicant
   * @author Digital Align Team | 11-09-2021
   * @param Applicant__c applicant
   * @return virtual
   **/
  global virtual Applicant__c beforeSaveApplicant(Applicant__c applicant) {
    return applicant;
  }

  /**
   * @description save applicant with child record
   * @author Digital Align Team | 10-27-2021
   * @param Applicant__c applicant
   * @param String applicationId
   * @return Applicant__c
   **/
  global virtual Applicant__c saveApplicant(Applicant__c applicant, String applicationId) {
    applicant = beforeSaveApplicant(applicant);
    Savepoint sp = Database.setSavepoint();
    try {
      applicant = ApplicationPersistService.getInstance().saveApplicant(applicant, applicationId);
      ApplicantRepository.upsertRecord(applicant);

      if (!ApexRequest.getParams().containsKey('ApexSkipApplicantChild')) {
        applicant = ApplicationPersistService.getInstance().saveApplicantChild(applicant);
      }
    } catch (Exception ex) {
      log?.error(ex);
      Database.rollback(sp);
      throw ex;
    }
    return afterSaveApplicant(applicant);
  }
  /**
   * @description  after saving applicant
   * @author Digital Align Team | 11-09-2021
   * @param Applicant__c applicant
   * @return virtual
   **/
  global virtual Applicant__c afterSaveApplicant(Applicant__c applicant) {
    String currentPage = ApexRequest.getRequest().currentPage;
    switch on currentPage {
      when 'PersonalInfo' {
        if (ApexRequest.getApplicantType() == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
          helper.notifyFamilyConnectReference(ApexRequest.getApplicationId());
        }
      }
    }
    return applicant;
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
   * @description
   * @author Digital Align Team | 03-28-2022
   * @param Id applicationId
   * @return Application__c
   **/
  global virtual Application__c validateExistingCustomer(Id applicationId) {
    Application__c application = ApplicantRepository.readApplicationWithChild(applicationId);
    Applicant__c primaryApplicant = application.Applicants__r[0];

    Contact existingContact = ApplicantRepository.fetchExistingContact(primaryApplicant);
    FinancialProduct__c baseProduct = FinancialAccountRepository.readBaseProduct();
    FinancialAccount__c primaryAccount = application.FinancialAccounts__r[0];

    if (existingContact != null) {
      primaryApplicant.contact__c = existingContact.Id;
      primaryApplicant.IsExistingCustomer__c = true;
      ApplicantRepository.upsertRecord(primaryApplicant);
    }

    if (primaryAccount.ProductCode__c == baseProduct.InternalCode__c && existingContact != null) {
      throw new CustomException('You already have Membership Account');
    }

    if (primaryAccount.ProductCode__c != baseProduct.InternalCode__c && existingContact == null) {
      FinancialProduct__c selectedProduct = FinancialAccountRepository.readFinancialProductByInternalCode(
        primaryAccount.ProductCode__c
      );

      //Change to Base Product as Customer doesn't have regular saving account yet
      primaryAccount.FinancialProduct__c = baseProduct.Id;
      // Move selected product Customer Interest
      CustomerInterest__c customerInterest = new CustomerInterest__c();
      customerInterest.Application__c = applicationId;
      customerInterest.Name = selectedProduct.Name;
      customerInterest.InterestProduct__c = selectedProduct.id;
      customerInterest.Focus__c = ApplicationConstant.CUSTOMER_INTEREST_FOCUS_INITIAL_INTEREST;
      customerInterest.isSelected__c = true;
      FinancialAccountRepository.upsertRecord(primaryAccount);
      FinancialAccountRepository.upsertRecord(customerInterest);
      FinancialAccountRepository.deleteRecords(application.CustomerInterests__r);

      application.IsExistingCustomer__c = false;
      ApplicantRepository.upsertRecord(application);
    } else if (primaryAccount.ProductCode__c != baseProduct.InternalCode__c && existingContact != null) {
      application.IsExistingCustomer__c = true;
      ApplicantRepository.upsertRecord(application);
    }

    if (ApexRequest.getApplicantType() == 'Primary') {
      return ApplicationService.getInstance().readApplicationWithChild(applicationId);
    } else if (ApexRequest.getApplicantType() == 'Joint') {
      return ApplicationService.getInstance().readApplicationWithChild(applicationId, ApexRequest.getApplicantId());
    }
    return null;
  }
}
