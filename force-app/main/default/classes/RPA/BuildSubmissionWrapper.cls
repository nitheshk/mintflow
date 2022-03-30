/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class BuildSubmissionWrapper extends AbstractService {
  @TestVisible
  private static BuildSubmissionWrapper serviceInstance;

  public BuildSubmissionWrapper() {
    super(BuildSubmissionWrapper.class);
  }
  /**
   * @description Provides a singleton instance of BuildSubmissionWrapper from which all other class methods can be accessed.
   * @author Digital Align Team | 01/17/2022
   * @return Object  singleton
   **/
  public static BuildSubmissionWrapper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (BuildSubmissionWrapper) getInstance(BuildSubmissionWrapper.class);
    }
    return serviceInstance;
  }

  /**
   * @description Read application by parameter passed
   * @author Digital Align Team | 10-21-2021
   * @param Map<String Object> params
   * @return Application__c
   **/
  global virtual Application__c readApplicationWithChild(String applicationNumber) {
    Application__c application;
    if (String.isBlank(applicationNumber)) {
      throw new CustomException(System.Label.Application_ApplicationNameCannotBeBlank);
    }
    application = SubmissionRepository.readApplicationByApplicationNumber(applicationNumber);
    if (application == null) {
      throw new customException(System.Label.Application_ApplicationNotFound);
    }

    List<Applicant__c> applicants = SubmissionRepository.readApplicantsWithChild(
      new Map<Id, SObject>(application.Applicants__r).keySet()
    );
    List<FinancialAccount__c> financialAccounts = SubmissionRepository.readFinancialAccountsWithChild(
      new Map<Id, SObject>(application.mflow__FinancialAccounts__r).keySet()
    );
    //Combine result into single application object
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObjects('mflow__Applicants__r', applicants);
    builder.setChildObjects('mflow__FinancialAccounts__r', financialAccounts);
    system.debug('financialAccounts =' + financialAccounts);
    return (Application__c) builder.build();
  }

  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param string applicationId
   * @return ApplicationSubmissionResponse
   **/
  global virtual SubmissionDTO.ApplicationData obtainApplicationData(string applicationNumber) {
    {
      log?.debug('Inside obtainApplicationData -> applicationNumber -> ' + applicationNumber);

      Application__c application = readApplicationWithChild(applicationNumber);
      ApexRequest.setApplicationId(application.id);
      ApexRequest.setApplicationName(application.Name);

      SubmissionDTO.ApplicationData mapperApplication = new SubmissionDTO.ApplicationData();
      // mapperApplication.Stage = application.mflow__Stage__c;
      // mapperApplication.Status = application.Status__c;
      mapperApplication.ApplicationId = application.Id;
      mapperApplication.ApplicationNumber = application.Name;
      mapperApplication.BranchCode = application.BranchCode__c;
      mapperApplication.BranchName = application.BranchName__c;
      mapperApplication.CountyName = application.CountyName__c;
      mapperApplication.StateName = application.StateName__c;
      mapperApplication.CountyCode = application.CountyZipCode__c;
      mapperApplication.IsCountyEligible = application.IsCountyEligible__c;
      mapperApplication.IsMemberFlow = application.isMemberFlow__c;
      for (Applicant__c applicant : application.Applicants__r) {
        if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
          mapperApplication.Password = applicant.Password__c;
        }
      }
      // mapperApplication.CreatedChannel = application.CreatedChannel__c;
      // mapperApplication.CustomerType = application.ApplicationType__c;
      // mapperApplication.FlowState = application.FlowState__c;
      // mapperApplication.IpAddress = application.IPAddress__c;
      // mapperApplication.LastUsedChannel = application.LastUsedChannel__c;
      // mapperApplication.Status = application.Status__c;
      // mapperApplication.SubmittedBy = application.SubmittedBy__c;
      // mapperApplication.SubmittedDate = application.SubmittedDate__c;
      // mapperApplication.SubStatus = application.Stage__c;

      //Map Finanical Accounts
      mapperApplication = mapFinancialAccounts(mapperApplication, application);

      //applicants
      if (!CollectionUtils.isListEmpty(application.Applicants__r)) {
        mapperApplication = mapApplicants(mapperApplication, application.Applicants__r);
      } else {
        throw new CustomException(System.Label.Application_ApplicationHasNoApplicants);
      }
      //Surveys
      if (!CollectionUtils.isListEmpty(application.Surveys__r)) {
        mapperApplication.Surveys.addAll(mapSurvey(application.Surveys__r));
      }

      log?.info('obtainApplicationData -> ReturnMapper -> ' + Json.serialize(mapperApplication));
      log?.debug('Completed obtainApplicationData -> applicationNumber -> ' + applicationNumber);
      return mapperApplication;
    }
  }

  /**
   * @description
   * @author Digital Align Team | 03-11-2022
   * @param SubmissionDTO.Application mapperApplication
   * @param Application__c application
   * @return SubmissionDTO.Application
   **/
  global virtual SubmissionDTO.ApplicationData mapFinancialAccounts(
    SubmissionDTO.ApplicationData mapperApplication,
    Application__c application
  ) {
    if (CollectionUtils.isListEmpty(application.FinancialAccounts__r)) {
      return mapperApplication;
    }
    mapperApplication.FinancialAccounts = new List<SubmissionDTO.FinancialAccount>();
    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      SubmissionDTO.FinancialAccount mapperFinancialAccount = new SubmissionDTO.FinancialAccount();
      mapperFinancialAccount.FinancialAccountId = financialAccount.Id;
      mapperFinancialAccount.Purpose = financialAccount.Purpose__c;
      mapperFinancialAccount.Comments = financialAccount.Comments__c;
      mapperFinancialAccount.CreditLimit = financialAccount.CreditLimit__c;
      mapperFinancialAccount.FinancialProduct = financialAccount.ProductName__c;
      mapperFinancialAccount.FinancialProductType = financialAccount.ProductCategory__c;
      mapperFinancialAccount.ExternalCode = financialAccount.FinancialProduct__r.ExternalCode__c;
      mapperFinancialAccount.InternalCode = financialAccount.FinancialProduct__r.InternalCode__c;
      mapperFinancialAccount.ExternalApplicationNumber = financialAccount.ExternalApplicationNumber__c;
      mapperFinancialAccount.Ownership = financialAccount.Ownership__c;
      if (!CollectionUtils.isListEmpty(financialAccount.FinancialAccountTransactions__r)) {
        mapperFinancialAccount.FinancialApplicationTransaction = mapFinancialAccountTranslation(
          financialAccount.FinancialAccountTransactions__r
        );
      }
      mapperApplication.FinancialAccounts.add(mapperFinancialAccount);
    }

    //exisitng application and product mapping
    mapperApplication.ExternalApplicationNumber = mapperApplication.FinancialAccounts[0].ExternalApplicationNumber;
    mapperApplication.FinancialProductType = mapperApplication.FinancialAccounts[0].FinancialProductType;
    mapperApplication.FinancialProduct = mapperApplication.FinancialAccounts[0].FinancialProduct;
    return mapperApplication;
  }

  /**
   * @description
   * @author Digital Align Team | 03-11-2022
   * @param SubmissionDTO.ApplicationData mapperApplication
   * @param List<applicant__c> applicantList
   * @return SubmissionDTO.ApplicationData
   **/
  global virtual SubmissionDTO.ApplicationData mapApplicants(
    SubmissionDTO.ApplicationData mapperApplication,
    List<applicant__c> applicantList
  ) {
    list<SubmissionDTO.Applicant> mapperApplicantList = new List<SubmissionDTO.Applicant>();
    for (applicant__c applicant : applicantList) {
      SubmissionDTO.Applicant mapperApplicant = new SubmissionDTO.Applicant();
      mapperApplicant.ApplicantId = applicant.Id;
      mapperApplicant.Application = applicant.Application__c;
      mapperApplicant.FirstName = applicant.FirstName__c;
      mapperApplicant.MiddleName = applicant.MiddleName__c;
      mapperApplicant.LastName = applicant.LastName__c;
      // mapperApplicant.IsEmailVerified = applicant.IsEmailVerified__c;
      // mapperApplicant.IsExistingCustomer = applicant.IsExistingCustomer__c;
      // mapperApplicant.IsPhoneNumberVerified = applicant.IsPhoneNumberVerified__c;
      mapperApplicant.ApplicantName = applicant.ApplicantName__c;
      mapperApplicant.ApplicantNumber = applicant.Name;
      mapperApplicant.ApplicantType = applicant.ApplicantType__c;
      mapperApplicant.Birthdate = applicant.Birthdate__c;
      // mapperApplicant.CreditScore = applicant.CreditScore__c;
      // mapperApplicant.CustomerNumber = applicant.CustomerNumber__c;
      mapperApplicant.Email = applicant.Email__c;
      // mapperApplicant.FraudStatus = applicant.FraudStatus__c;
      // mapperApplicant.IdentityVerificationStatus = applicant.IdentityVerificationStatus__c;
      // mapperApplicant.KYCStatus = applicant.KYCStatus__c;
      mapperApplicant.Order = applicant.Order__c;
      mapperApplicant.Phone = applicant.Phone__c;
      mapperApplicant.Relationship = applicant.Relationship__c;
      // mapperApplicant.SentiLinkFraudScore = applicant.SentiLinkFraudScore__c;
      // mapperApplicant.SentiLinkRemarks = applicant.SentiLinkRemarks__c;
      // mapperApplicant.SentiLinkStatus = applicant.SentiLinkStatus__c;
      mapperApplicant.SSN = applicant.SSN__c;

      //Map employment data
      if (!CollectionUtils.isListEmpty(applicant.Employments__r)) {
        mapperApplicant.Employments.addAll(mapEmployments(applicant.Employments__r));
      }

      //Map Identity Data
      if (!CollectionUtils.isListEmpty(applicant.IdentificationDocuments__r)) {
        mapperApplicant.IdentificationDocuments.addAll(mapIdentities(applicant.IdentificationDocuments__r));
      }

      //Map Survey Data
      if (!CollectionUtils.isListEmpty(applicant.Surveys__r)) {
        mapperApplicant.Surveys.addAll(mapSurvey(applicant.Surveys__r));
      }

      //Map ContatcPointAddress Data
      if (!CollectionUtils.isListEmpty(applicant.ContactPointAddresses__r)) {
        mapperApplicant.ContactPointAddresses.addAll(mapContactAddress(applicant.ContactPointAddresses__r));
      }

      mapperApplicantList.add(mapperApplicant);
    }

    mapperApplication.Applicants.addAll(mapperApplicantList);
    return mapperApplication;
  }

  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param List<Employment__c> employmentList
   * @return virtual
   **/
  global virtual list<SubmissionDTO.Employment> mapEmployments(List<Employment__c> employmentList) {
    list<SubmissionDTO.Employment> mapperEmploymentList = new List<SubmissionDTO.Employment>();
    for (Employment__c employment : employmentList) {
      SubmissionDTO.Employment mapperEmployment = new SubmissionDTO.Employment();
      mapperEmployment.EmploymentId = employment.Id;
      mapperEmployment.EmploymentType = employment.EmploymentType__c;
      mapperEmployment.EmployerName = employment.Name;
      mapperEmployment.EmploymentStatus = getStatusMapping('EmploymentStatus__c', employment.EmploymentStatus__c);
      mapperEmployment.GrossMonthlySalary = employment.GrossMonthlySalary__c;
      mapperEmployment.Name = employment.Name;
      mapperEmployment.IncomeType = employment.IncomeType__c;
      mapperEmployment.PayCycle = employment.PayCycle__c;
      mapperEmployment.Order = employment.Order__c;
      mapperEmployment.PayGrade = employment.PayGrade__c;
      mapperEmployment.Position = employment.Position__c;
      mapperEmployment.EmploymentDuration = employment.EmploymentDuration__c;
      mapperEmployment.DocumentType = employment.DocumentType__c;
      mapperEmployment.BranchofService = employment.BranchofService__c;
      mapperEmployment.EnlistmentDate = employment.EnlistmentDate__c;
      mapperEmploymentList.add(mapperEmployment);
    }
    return mapperEmploymentList;
  }
  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param List<IdentificationDocument__c> identityList
   * @return virtual
   **/
  global virtual list<SubmissionDTO.IdentificationDocument> mapIdentities(
    List<IdentificationDocument__c> identityList
  ) {
    list<SubmissionDTO.IdentificationDocument> mapperIdentityList = new List<SubmissionDTO.IdentificationDocument>();
    for (IdentificationDocument__c identity : identityList) {
      SubmissionDTO.IdentificationDocument mapperIdentity = new SubmissionDTO.IdentificationDocument();
      mapperIdentity.IdentificationDocumentId = identity.Id;
      mapperIdentity.IssuingCountry = identity.IssuingCountry__c;
      mapperIdentity.DocumentNumber = identity.DocumentNumber__c;
      mapperIdentity.DocumentType = identity.DocumentType__c;
      mapperIdentity.ExpirationDate = identity.ExpirationDate__c;
      mapperIdentity.IssueDate = identity.IssueDate__c;
      mapperIdentity.IssuedRegion = identity.IssuedRegion__c;
      // mapperIdentity.Name = identity.Name;
      mapperIdentity.Order = identity.Order__c;
      mapperIdentityList.add(mapperIdentity);
    }
    return mapperIdentityList;
  }

  /**
   * @description
   * @author Digital Align | 12-22-2021
   * @param List<mflow__Survey__c> surveyList
   * @return list<SubmissionDTO.Survey>
   **/
  global virtual list<SubmissionDTO.Survey> mapSurvey(List<mflow__Survey__c> surveyList) {
    list<SubmissionDTO.Survey> mapperSurveyList = new List<SubmissionDTO.Survey>();
    for (mflow__Survey__c survey : surveyList) {
      SubmissionDTO.Survey mapperSurvey = new SubmissionDTO.Survey();
      mapperSurvey.SurveyId = survey.Id;
      mapperSurvey.Answer = survey.mflow__Answer__c;
      mapperSurvey.LongDescription = survey.mflow__LongDescription__c;
      mapperSurvey.Order = survey.mflow__Order__c;
      mapperSurvey.ShortDescription = survey.mflow__ShortDescription__c;
      mapperSurveyList.add(mapperSurvey);
    }
    return mapperSurveyList;
  }
  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param List<ContactPointAddress> contactAddressList
   * @return virtual
   **/
  global virtual list<SubmissionDTO.ContactPointAddress> mapContactAddress(
    List<ContactPointAddress> contactAddressList
  ) {
    list<SubmissionDTO.ContactPointAddress> mapperContactAddressList = new List<SubmissionDTO.ContactPointAddress>();
    for (ContactPointAddress contactAddress : contactAddressList) {
      SubmissionDTO.ContactPointAddress mapperContactAddress = new SubmissionDTO.ContactPointAddress();
      mapperContactAddress.ContactPointAddressId = contactAddress.Id;
      if (contactAddressList.size() == 1) {
        // Uploaded address will be current address
        mapperContactAddress.AddressType = 'Current';
      } else {
        mapperContactAddress.AddressType = contactAddress.AddressType;
      }
      mapperContactAddress.City = contactAddress.City;
      mapperContactAddress.Country = contactAddress.Country;
      mapperContactAddress.IsPrimary = contactAddress.IsPrimary;
      mapperContactAddress.PostalCode = contactAddress.PostalCode;
      mapperContactAddress.State = contactAddress.State;
      mapperContactAddress.StateCode = contactAddress.StateCode__c;
      mapperContactAddress.Street = contactAddress.Street;
      mapperContactAddress.Order = contactAddress.Order__c;
      mapperContactAddress.OccupancyStatus = getStatusMapping('UsageType', contactAddress.UsageType);
      mapperContactAddress.OccupancyDuration = contactAddress.OccupancyDuration__c;
      mapperContactAddressList.add(mapperContactAddress);
    }
    return mapperContactAddressList;
  }

  /**
   * @description fetch all files saved under requested application and its child objects using application Id
   * @author Digital Align | 12-02-2021
   * @param string applicationId
   * @return ApexResponse
   **/
  public virtual Object obtainApplicationFiles(string applicationNumber) {
    log?.fine('Inside obtainApplicationFiles -> applicationNumber -> ' + applicationNumber);

    Application__c application = readApplicationWithChild(applicationNumber);
    ApexRequest.setApplicationId(application.id);
    ApexRequest.setApplicationName(application.Name);

    List<id> reletedEntityIdList = new List<id>();
    List<Map<string, string>> fileDetails = new List<Map<string, string>>();

    for (Applicant__c applicant : application.Applicants__r) {
      // documents related to applicant
      reletedEntityIdList.add(applicant.Id);
      reletedEntityIdList.addAll(new Map<id, SObject>(applicant.Employments__r).keySet());
      reletedEntityIdList.addAll(new Map<id, SObject>(applicant.IdentificationDocuments__r).keySet());
    }
    String eligibleFileFormat = ApplicationConfiguration__c.getInstance().SupportedFileTypes__c;
    List<String> eligibleFileFormatList = String.isNotBlank(eligibleFileFormat)
      ? eligibleFileFormat.split(';')
      : new List<String>();
    List<ContentVersion> fileList = FileService.getInstance().fetchContentVersionByEntityIds(reletedEntityIdList, true);

    for (ContentVersion cv : fileList) {
      Map<string, string> fileDetail = new Map<string, string>();
      if (eligibleFileFormatList.contains(cv.FileExtension)) {
        fileDetail.put('Id', cv.Id);
        fileDetail.put('FileType', cv.FileType);
        fileDetail.put('FileExtension', cv.FileExtension);
        fileDetail.put('Title', cv.Title);
        fileDetail.put('DocumentType', cv.mflow__ContentSubType__c);
        fileDetails.add(fileDetail);
      }
    }
    log?.debug('fileDetails =' + JSON.serialize(fileDetails));
    return ApexResponse.OK(fileDetails).addHeader('Content-Type', 'application/json');
  }
  /**
   * @description
   * @author Digital Align | 01-10-2022
   * @param FinancialAccountTransaction__c accountTransaction
   * @return SubmissionDTO.FinancialAccountTransaction
   **/
  global virtual SubmissionDTO.FinancialAccountTransaction mapFinancialAccountTranslation(
    FinancialAccountTransaction__c accountTransaction
  ) {
    SubmissionDTO.FinancialAccountTransaction mapperTransaction = new SubmissionDTO.FinancialAccountTransaction();
    mapperTransaction.FinancialAccountTransactionId = accountTransaction?.Id;
    mapperTransaction.AccountHolderName = accountTransaction?.mflow__AccountHolderName__c;
    mapperTransaction.AccountNumber = accountTransaction?.mflow__AccountNumber__c;
    mapperTransaction.Amount = accountTransaction?.mflow__Amount__c;
    mapperTransaction.FinancialInstitute = accountTransaction?.mflow__FinancialInstitute__c;
    mapperTransaction.RoutingNumber = accountTransaction?.mflow__RoutingNumber__c;
    mapperTransaction.TransactionStatus = accountTransaction?.TransactionStatus__c;
    mapperTransaction.InstitutionState = accountTransaction?.mflow__TransactionStateCode__c;
    mapperTransaction.TransactionType = accountTransaction?.TransactionSubType__c;
    mapperTransaction.TransactionAccountType = accountTransaction?.TransactionAccountType__c;
    mapperTransaction.TransactionDate = date.newinstance(
      accountTransaction.TransactionDate__c.year(),
      accountTransaction.TransactionDate__c.month(),
      accountTransaction.TransactionDate__c.day()
    );
    return mapperTransaction;
  }

  /**
   * @description
   * @author Digital Align | 01-20-2022
   * @param String fieldName
   * @param String value
   * @return virtual
   **/
  global virtual String getStatusMapping(String fieldName, String value) {
    switch on fieldName {
      when 'UsageType' {
        return (new Map<String, String>{
            'Buying / Own With Mortgage' => 'Buying/Own With Mortgage',
            'Government Quarters' => 'Government Quarters',
            'Live With Parents' => 'Live With Parents',
            'Other' => 'Other',
            'Own-Free and Clear' => 'Own - Free & Clear',
            'Rent' => 'Rent'
          })
          .get(value);
      }
      when 'EmploymentStatus__c' {
        return (new Map<String, String>{
            'Employed' => 'Employed',
            'Self Employed' => 'Self Employed',
            'Home Maker' => 'HomeMaker',
            'Retired' => 'Retired',
            'Student' => 'Student',
            'Active Military' => 'Active Military',
            'Unemployed' => 'Unemployed',
            'Government/ Dod' => 'Government/Dod',
            'Other' => 'Other',
            'Owner' => 'Owner',
            'Retired Military' => 'Retired Military'
          })
          .get(value);
      }
      when else {
        return null;
      }
    }
  }
}
