/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ApplicationDataAPI {
  private static logger log = logger.getInstance(ApplicationDataAPI.class);
  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param string applicationId
   * @return ApplicationResponseMapper
   **/
  global static ApplicationResponseMapper obtainApplicationData(
    string applicationNumber
  ) {
    {
      log
        ?.fine(
          'Inside obtainApplicationData -> applicationNumber -> ' +
          applicationNumber
        );
      ApplicationResponseMapper mapper = new ApplicationResponseMapper();

      if (String.isBlank(applicationNumber)) {
        throw new CustomException(
          System.Label.Application_ApplicationNameCannotBeBlank
        );
      }
      Account application = DataAPIRepository.readApplicationByApplicationNumber(
        applicationNumber
      );
      if (application == null) {
        throw new customException(System.Label.Application_ApplicationNotFound);
      }
      application = readApplicationWithChild(application.Id);

      log?.debug('Full Application Json : ' + json.serialize(application));
      if (application != null) {
        ApplicationResponseMapper.Account mapperApplication = new ApplicationResponseMapper.Account();
        mapperApplication.ApplicationId = application.Id;
        mapperApplication.ApplicationNumber = application.ApplicationNumber__c;
        mapperApplication.BranchCode = application.FinServ__BranchCode__c;
        mapperApplication.BranchName = application.FinServ__BranchName__c;
        mapperApplication.CountyName = application.CountyName__c;
        mapperApplication.StateName = application.StateName__c;
        mapperApplication.CountyCode = application.CountyZipCode__c;
        mapperApplication.IsCountyEligible = application.IsCountyEligible__c;
        mapperApplication.CreatedChannel = application.CreatedChannel__c;
        mapperApplication.CustomerType = application.FinServ__CustomerType__c;
        mapperApplication.FlowState = application.FlowState__c;
        mapperApplication.IpAddress = application.IPAddress__c;
        mapperApplication.IsMemberFlow = application.isMemberFlow__c;
        mapperApplication.LastUsedChannel = application.FinServ__LastUsedChannel__c;
        mapperApplication.Status = application.FinServ__Status__c;
        mapperApplication.SubmittedBy = application.SubmittedBy__c;
        mapperApplication.SubmittedDate = application.SubmittedDate__c;
        mapperApplication.SubStatus = application.Stage__c;
        mapperApplication.UserAccountType = application.UserAccountType__c;

        if (!CollectionUtils.isListEmpty(application.Applicants__r)) {
          mapperApplication.Applicants.addAll(
            mapApplicant(application.Applicants__r)
          );
        } else {
          throw new CustomException(
            System.Label.Application_ApplicationHasNoApplicants
          );
        }
        if (!CollectionUtils.isListEmpty(application.Surveys__r)) {
          mapperApplication.Surveys.addAll(mapSurvey(application.Surveys__r));
        }
        mapper.Application = mapperApplication;
      } else {
        throw new CustomException(System.Label.Application_ApplicationNotFound);
      }
      log?.info('obtainApplicationData -> ReturnMapper -> ' + mapper);
      return mapper;
    }
  }
  /**
   * @description
   * @author Digital Align | 11-16-2021
   * @param List<applicant__c> applicantList
   * @return list<ApplicationResponseMapper.Applicant>
   **/
  global static list<ApplicationResponseMapper.Applicant> mapApplicant(
    List<applicant__c> applicantList
  ) {
    list<ApplicationResponseMapper.Applicant> mapperApplicantList = new List<ApplicationResponseMapper.Applicant>();
    for (applicant__c applicant : applicantList) {
      ApplicationResponseMapper.Applicant mapperApplicant = new ApplicationResponseMapper.Applicant();
      mapperApplicant.ApplicantId = applicant.Id;
      mapperApplicant.Application = applicant.Application__c;
      mapperApplicant.FirstName = applicant.FirstName__c;
      mapperApplicant.MiddleName = applicant.MiddleName__c;
      mapperApplicant.LastName = applicant.LastName__c;
      mapperApplicant.IsEmailVerified = applicant.IsEmailVerified__c;
      mapperApplicant.IsExistingCustomer = applicant.IsExistingCustomer__c;
      mapperApplicant.IsPhoneNumberVerified = applicant.IsPhoneNumberVerified__c;
      mapperApplicant.ApplicantName = applicant.Name;
      mapperApplicant.ApplicantNumber = applicant.ApplicantNumber__c;
      mapperApplicant.ApplicantType = applicant.ApplicantType__c;
      mapperApplicant.Birthdate = applicant.Birthdate__c;
      mapperApplicant.CreditScore = applicant.CreditScore__c;
      mapperApplicant.CustomerNumber = applicant.CustomerNumber__c;
      mapperApplicant.Email = applicant.Email__c;
      mapperApplicant.FraudStatus = applicant.FraudStatus__c;
      mapperApplicant.IdentityVerificationStatus = applicant.IdentityVerificationStatus__c;
      mapperApplicant.IncomeVerificationStatus = applicant.IncomeVerificationStatus__c;
      mapperApplicant.KYCStatus = applicant.KYCStatus__c;
      mapperApplicant.Order = applicant.Order__c;
      mapperApplicant.Phone = applicant.Phone__c;
      mapperApplicant.Relationship = applicant.Relationship__c;
      mapperApplicant.SentiLinkFraudScore = applicant.SentiLinkFraudScore__c;
      mapperApplicant.SentiLinkRemarks = applicant.SentiLinkRemarks__c;
      mapperApplicant.SentiLinkStatus = applicant.SentiLinkStatus__c;
      mapperApplicant.SSN = applicant.SSN__c;
      mapperApplicant.Password = applicant.Password__c;

      //Map employment data
      if (!CollectionUtils.isListEmpty(applicant.Employments__r)) {
        mapperApplicant.Employments.addAll(
          mapEmployment(applicant.Employments__r)
        );
      }

      //Map Identity Data
      if (!CollectionUtils.isListEmpty(applicant.IdentificationDocuments__r)) {
        mapperApplicant.IdentificationDocuments.addAll(
          mapIdentity(applicant.IdentificationDocuments__r)
        );
      }

      //Map Revenue Data
      if (!CollectionUtils.isListEmpty(applicant.Revenues__r)) {
        mapperApplicant.Revenues.addAll(mapRevenue(applicant.Revenues__r));
      }
      //Map Survey Data
      if (!CollectionUtils.isListEmpty(applicant.Surveys__r)) {
        mapperApplicant.Surveys.addAll(mapSurvey(applicant.Surveys__r));
      }

      //Map ContatcPointAddress Data
      if (!CollectionUtils.isListEmpty(applicant.ContactPointAddresses__r)) {
        mapperApplicant.ContactPointAddresses.addAll(
          mapContactAddress(applicant.ContactPointAddresses__r)
        );
      }

      //Map Assest and Liabilities Data
      /* Not required for phase 1
      if (
        !CollectionUtils.isListEmpty(applicant.AssetsAndLiabilities__r)
      ) {
        mapperApplicant.AssetsAndLiabilities.addAll(
          mapContactAddress(applicant.AssetsAndLiabilities__r)
        );
      }*/

      mapperApplicantList.add(mapperApplicant);
    }
    return mapperApplicantList;
  }

  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param List<FinServ__Employment__c> employmentList
   * @return virtual
   **/
  global static list<ApplicationResponseMapper.Employment> mapEmployment(
    List<FinServ__Employment__c> employmentList
  ) {
    list<ApplicationResponseMapper.Employment> mapperEmploymentList = new List<ApplicationResponseMapper.Employment>();
    for (FinServ__Employment__c employment : employmentList) {
      ApplicationResponseMapper.Employment mapperEmployment = new ApplicationResponseMapper.Employment();
      mapperEmployment.EmploymentId = employment.Id;
      mapperEmployment.EmploymentType = employment.EmploymentType__c;
      mapperEmployment.EmployerName = employment.Name;
      mapperEmployment.EmploymentStatus = employment.FinServ__EmploymentStatus__c;
      mapperEmployment.GrossMonthlySalary = employment.GrossMonthlySalary__c;
      mapperEmployment.EmploymentStatus = employment.FinServ__EmploymentStatus__c;
      mapperEmployment.Name = employment.Name;
      mapperEmployment.IncomeType = employment.IncomeType__c;
      mapperEmployment.PayCycle = employment.PayCycle__c;
      mapperEmployment.Order = employment.Order__c;
      mapperEmployment.PayGrade = employment.PayGrade__c;
      mapperEmployment.Position = employment.FinServ__Position__c;
      mapperEmployment.EmploymentDuration = employment.EmploymentDuration__c;
      mapperEmployment.DocumentType = employment.DocumentType__c;
      mapperEmployment.EmploymentVerificationType = employment.EmploymentVerificationType__c;
      mapperEmploymentList.add(mapperEmployment);
    }
    return mapperEmploymentList;
  }
  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param List<FinServ__IdentificationDocument__c> identityList
   * @return virtual
   **/
  global static list<ApplicationResponseMapper.IdentificationDocument> mapIdentity(
    List<FinServ__IdentificationDocument__c> identityList
  ) {
    list<ApplicationResponseMapper.IdentificationDocument> mapperIdentityList = new List<ApplicationResponseMapper.IdentificationDocument>();
    for (FinServ__IdentificationDocument__c identity : identityList) {
      ApplicationResponseMapper.IdentificationDocument mapperIdentity = new ApplicationResponseMapper.IdentificationDocument();
      mapperIdentity.IdentificationDocumentId = identity.Id;
      mapperIdentity.IssuingCountry = identity.FinServ__IssuingCountry__c;
      mapperIdentity.DocumentNumber = identity.FinServ__DocumentNumber__c;
      mapperIdentity.DocumentType = identity.FinServ__DocumentType__c;
      mapperIdentity.ExpirationDate = identity.FinServ__ExpirationDate__c;
      mapperIdentity.Gender = identity.Gender__c;
      mapperIdentity.Height = identity.Height__c;
      mapperIdentity.IssueDate = identity.FinServ__IssueDate__c;
      mapperIdentity.IssuedRegion = identity.IssuedRegion__c;
      mapperIdentity.Name = identity.Name;
      mapperIdentity.Nationality = identity.Nationality__c;
      mapperIdentity.Order = identity.Order__c;
      mapperIdentity.PrimaryContentDocumentID = identity.PrimaryContentDocumentID__c;
      mapperIdentity.SecondaryContentDocumentId = identity.SecondaryContentDocumentId__c;
      mapperIdentity.Weight = identity.Weight__c;

      mapperIdentityList.add(mapperIdentity);
    }
    return mapperIdentityList;
  }
  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param List<FinServ__Revenue__c> revenueList
   * @return virtual
   **/
  global static list<ApplicationResponseMapper.Revenue> mapRevenue(
    List<FinServ__Revenue__c> revenueList
  ) {
    list<ApplicationResponseMapper.Revenue> mapperRevenueList = new List<ApplicationResponseMapper.Revenue>();
    for (FinServ__Revenue__c revenue : revenueList) {
      ApplicationResponseMapper.Revenue mapperRevenue = new ApplicationResponseMapper.Revenue();
      mapperRevenue.RevenueId = revenue.Id;
      mapperRevenue.Amount = revenue.FinServ__Amount__c;
      mapperRevenue.Name = revenue.Name;
      mapperRevenue.Order = revenue.Order__c;
      mapperRevenue.RevenueDate = revenue.FinServ__Date__c;
      mapperRevenue.SubType = revenue.FinServ__SubType__c;
      mapperRevenue.Type = revenue.FinServ__Type__c;
      mapperRevenueList.add(mapperRevenue);
    }
    return mapperRevenueList;
  }

  /**
   * @description
   * @author Digital Align | 12-22-2021
   * @param List<mflow__Survey__c> surveyList
   * @return list<ApplicationResponseMapper.Survey>
   **/
  global static list<ApplicationResponseMapper.Survey> mapSurvey(
    List<mflow__Survey__c> surveyList
  ) {
    list<ApplicationResponseMapper.Survey> mapperSurveyList = new List<ApplicationResponseMapper.Survey>();
    for (mflow__Survey__c survey : surveyList) {
      ApplicationResponseMapper.Survey mapperSurvey = new ApplicationResponseMapper.Survey();
      mapperSurvey.SurveyId = survey.Id;
      mapperSurvey.Answer = survey.mflow__Answer__c;
      mapperSurvey.LongDescription = survey.mflow__LongDescription__c;
      mapperSurvey.Name = survey.Name;
      mapperSurvey.OptionType = survey.mflow__OptionType__c;
      mapperSurvey.Order = survey.mflow__Order__c;
      mapperSurvey.ParentQuestionCode = survey.mflow__ParentQuestionCode__c;
      mapperSurvey.QuestionCode = survey.mflow__QuestionCode__c;
      mapperSurvey.QuestionNumber = survey.mflow__QuestionNumber__c;
      mapperSurvey.ShortDescription = survey.mflow__ShortDescription__c;
      mapperSurvey.EventIdentifier = survey.mflow__EventIdentifier__c;
      mapperSurvey.TemplateName = survey.mflow__TemplateName__c;
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
  global static list<ApplicationResponseMapper.ContactPointAddress> mapContactAddress(
    List<ContactPointAddress> contactAddressList
  ) {
    list<ApplicationResponseMapper.ContactPointAddress> mapperContactAddressList = new List<ApplicationResponseMapper.ContactPointAddress>();
    for (ContactPointAddress contactAddress : contactAddressList) {
      ApplicationResponseMapper.ContactPointAddress mapperContactAddress = new ApplicationResponseMapper.ContactPointAddress();
      mapperContactAddress.ContactPointAddressId = contactAddress.Id;
      mapperContactAddress.IsPrimary = contactAddress.IsPrimary;
      mapperContactAddress.AddressType = contactAddress.AddressType;
      mapperContactAddress.City = contactAddress.City;
      mapperContactAddress.Country = contactAddress.Country;
      mapperContactAddress.IsPrimary = contactAddress.IsPrimary;
      mapperContactAddress.PostalCode = contactAddress.PostalCode;
      mapperContactAddress.State = contactAddress.State;
      mapperContactAddress.StateCode = contactAddress.StateCode__c;
      mapperContactAddress.Street = contactAddress.Street;
      mapperContactAddress.Order = contactAddress.Order__c;
      mapperContactAddress.OccupancyStatus = contactAddress.UsageType;
      mapperContactAddress.OccupancyDuration = contactAddress.OccupancyDuration__c;
      mapperContactAddressList.add(mapperContactAddress);
    }
    return mapperContactAddressList;
  }

  /* Not required for phase 1
  global static list<ApplicationResponseMapper.AssetsAndLiabilities> mapContactAddress(
    List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilitiesList
  ) {
    list<ApplicationResponseMapper.AssetsAndLiabilities> mapperAssetsAndLiabilitiesList = new List<ApplicationResponseMapper.AssetsAndLiabilities>();
    for (
      FinServ__AssetsAndLiabilities__c assetsAndLiabilities : assetsAndLiabilitiesList
    ) {
      ApplicationResponseMapper.AssetsAndLiabilities mapperAssetsAndLiabilities = new ApplicationResponseMapper.AssetsAndLiabilities();
      mapperAssetsAndLiabilities.AssetsAndLiabilitieId = assetsAndLiabilities.Id;
      mapperAssetsAndLiabilities.Amount = assetsAndLiabilities.FinServ__Amount__c;
      mapperAssetsAndLiabilities.AssetsAndLiabilitiesType = assetsAndLiabilities.FinServ__AssetsAndLiabilitiesType__c;
      mapperAssetsAndLiabilities.Name = assetsAndLiabilities.Name;
      mapperAssetsAndLiabilities.Order = assetsAndLiabilities.Order__c;
      mapperAssetsAndLiabilities.Ownership = assetsAndLiabilities.FinServ__Ownership__c;
      mapperAssetsAndLiabilities.OwnerType = assetsAndLiabilities.FinServ__OwnerType__c;
      mapperAssetsAndLiabilitiesList.add(mapperAssetsAndLiabilities);
    }
    return mapperAssetsAndLiabilitiesList;
  }
  */
  /**
   * @description fetch all files saved under requested application and its child objects using application Id
   * @author Digital Align | 12-02-2021
   * @param string applicationId
   * @return ApexResponse
   **/
  public static Object obtainApplicationFiles(string applicationNumber) {
    log
      ?.fine(
        'Inside obtainApplicationFiles -> applicationNumber -> ' +
        applicationNumber
      );
    if (string.isBlank(applicationNumber)) {
      throw new CustomException(
        System.Label.Application_ApplicationNameCannotBeBlank
      );
    }

    List<id> reletedEntityIdList = new List<id>();

    Account application = DataAPIRepository.readApplicationByApplicationNumber(
      applicationNumber
    );

    if (application == null) {
      throw new customException(System.Label.Application_ApplicationNotFound);
    }

    application = readApplicationWithChild(application.Id);

    for (Applicant__c applicant : application.Applicants__r) {
      // documents related to applicant
      reletedEntityIdList.add(applicant.Id);
      reletedEntityIdList.addAll(
        new Map<id, SObject>(applicant.Employments__r).keySet()
      );
      reletedEntityIdList.addAll(
        new Map<id, SObject>(applicant.IdentificationDocuments__r).keySet()
      );
    }

    List<ContentVersion> fileList = FileService.getInstance()
      .fetchContentVersionByEntityIds(reletedEntityIdList, true);
    return ApexResponse.OK(new Map<Id, SObject>(fileList).keySet())
      .addHeader('Content-Type', 'application/json');
  }
  /**
   * @description Read application by parameter passed
   * @author Digital Align Team | 10-21-2021
   * @param Map<String Object> params
   * @return Account
   **/
  global static Account readApplicationWithChild(Id applicationId) {
    Account application = DataAPIRepository.readApplicationWithChild(
      applicationId
    );

    List<Applicant__c> applicants = readApplicantsWithChild(
      application.Applicants__r
    );
    List<FinServ__FinancialAccount__c> financialAccounts = FinancialAccountService.getInstance()
      .readFinancialAccountsWithChild(application.mflow__FinancialAccounts__r);

    //Combine result into single application object
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObjects('mflow__Applicants__r', applicants);
    builder.setChildObjects('mflow__FinancialAccounts__r', financialAccounts);
    return (Account) builder.build();
  }

  /**
   * @description Read all applicant by applicant records
   * @author Digital Align Team | 10-26-2021
   * @param List<Applicant__c> applicants
   **/
  global static List<Applicant__c> readApplicantsWithChild(
    List<Applicant__c> applicants
  ) {
    return DataAPIRepository.readApplicantsWithChild(
      new Map<Id, SObject>(applicants).keySet()
    );
  }
}
