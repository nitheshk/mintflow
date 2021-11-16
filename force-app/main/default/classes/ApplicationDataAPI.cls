/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description
 **/
@RestResource(urlMapping='/ApplicationDataAPI/*')
global with sharing class ApplicationDataAPI {
  private static logger log = logger.getInstance(ApplicationDataAPI.class);
  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param string applicationId
   * @return ApplicationResponseMapper
   **/
  @HttpPost
  global static ApplicationResponseMapper getApplicationData(
    string applicationId
  ) {
    {
      log
        ?.fine(
          'Inside getApplicationData -> applicationId -> ' + applicationId
        );
      ApplicationResponseMapper mapper = new ApplicationResponseMapper();
      if (String.isBlank(applicationId)) {
        throw new CustomException('Application ID cannot be blank');
      }
      Account application = ApplicationService.getInstance()
        .readApplicationWithChild(applicationId);
      log?.debug('Full Application Json : ' + json.serialize(application));
      if (application != null) {
        ApplicationResponseMapper.Account mapperApplication = new ApplicationResponseMapper.Account();
        mapperApplication.ApplicationId = application.Id;
        mapperApplication.ApplicationNumber = application.dau01__ApplicationNumber__c;
        mapperApplication.BranchCode = application.FinServ__BranchCode__c;
        mapperApplication.BranchName = application.FinServ__BranchName__c;
        mapperApplication.County = application.dau01__BillingCounty__c;
        mapperApplication.CreatedChannel = application.dau01__CreatedChannel__c;
        mapperApplication.CustomerType = application.FinServ__CustomerType__c;
        mapperApplication.FlowState = application.dau01__FlowState__c;
        mapperApplication.IpAddress = application.dau01__IPAddress__c;
        mapperApplication.IsMemberFlow = application.dau01__isMemberFlow__c;
        mapperApplication.LastUsedChannel = application.FinServ__LastUsedChannel__c;
        mapperApplication.Status = application.FinServ__Status__c;
        mapperApplication.SubmittedBy = application.dau01__SubmittedBy__c;
        mapperApplication.SubmittedDate = application.dau01__SubmittedDate__c;
        mapperApplication.SubStatus = application.dau01__SubStatus__c;
        mapperApplication.UserAccountType = application.dau01__UserAccountType__c;

        if (!CollectionUtils.isListEmpty(application.Applicants__r)) {
          mapperApplication.Applicants.addAll(
            mapApplicant(application.Applicants__r)
          );
        } else {
          throw new CustomException('Application has no applicants');
        }
        mapper.Application = mapperApplication;
      } else {
        throw new CustomException('Application not found');
      }
      log?.info('getApplicationData -> ReturnMapper -> ' + mapper);
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
      mapperApplicant.Application = applicant.dau01__Application__c;
      mapperApplicant.FirstName = applicant.dau01__FirstName__c;
      mapperApplicant.MiddleName = applicant.dau01__MiddleName__c;
      mapperApplicant.LastName = applicant.dau01__LastName__c;
      mapperApplicant.IsEmailVerified = applicant.dau01__IsEmailVerified__c;
      mapperApplicant.IsExistingCustomer = applicant.dau01__IsExistingCustomer__c;
      mapperApplicant.IsPhoneNumberVerified = applicant.dau01__IsPhoneNumberVerified__c;
      mapperApplicant.ApplicantName = applicant.Name;
      mapperApplicant.ApplicantNumber = applicant.dau01__ApplicantNumber__c;
      mapperApplicant.ApplicantType = applicant.dau01__ApplicantType__c;
      mapperApplicant.Birthdate = applicant.dau01__Birthdate__c;
      mapperApplicant.CreditScore = applicant.dau01__CreditScore__c;
      mapperApplicant.CustomerNumber = applicant.dau01__CustomerNumber__c;
      mapperApplicant.Email = applicant.dau01__Email__c;
      mapperApplicant.EmploymentStatus = applicant.dau01__EmploymentStatus__c;
      mapperApplicant.FraudStatus = applicant.dau01__FraudStatus__c;
      mapperApplicant.IdentityVerificationStatus = applicant.dau01__IdentityVerificationStatus__c;
      mapperApplicant.IncomeVerificationStatus = applicant.dau01__IncomeVerificationStatus__c;
      mapperApplicant.KYCStatus = applicant.dau01__KYCStatus__c;
      mapperApplicant.Order = applicant.dau01__Order__c;
      mapperApplicant.Phone = applicant.dau01__Phone__c;
      mapperApplicant.SentiLinkFraudScore = applicant.dau01__SentiLinkFraudScore__c;
      mapperApplicant.SentiLinkRemarks = applicant.dau01__SentiLinkRemarks__c;
      mapperApplicant.SentiLinkStatus = applicant.dau01__SentiLinkStatus__c;
      mapperApplicant.SSN = applicant.dau01__SSN__c;

      //Map employment data
      if (!CollectionUtils.isListEmpty(applicant.dau01__Employments__r)) {
        mapperApplicant.Employments.addAll(
          mapEmployment(applicant.dau01__Employments__r)
        );
      }

      //Map Identity Data
      if (
        !CollectionUtils.isListEmpty(
          applicant.dau01__IdentificationDocuments__r
        )
      ) {
        mapperApplicant.IdentificationDocuments.addAll(
          mapIdentity(applicant.dau01__IdentificationDocuments__r)
        );
      }

      //Map Revenue Data
      if (!CollectionUtils.isListEmpty(applicant.dau01__Revenues__r)) {
        mapperApplicant.Revenues.addAll(
          mapRevenue(applicant.dau01__Revenues__r)
        );
      }

      //Map ContatcPointAddress Data
      if (
        !CollectionUtils.isListEmpty(applicant.dau01__ContactPointAddresses__r)
      ) {
        mapperApplicant.ContactPointAddresses.addAll(
          mapContactAddress(applicant.dau01__ContactPointAddresses__r)
        );
      }

      //Map Assest and Liabilities Data
      if (
        !CollectionUtils.isListEmpty(applicant.dau01__AssetsAndLiabilities__r)
      ) {
        mapperApplicant.AssetsAndLiabilities.addAll(
          mapContactAddress(applicant.dau01__AssetsAndLiabilities__r)
        );
      }

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
      mapperEmployment.EmploymentType = employment.dau01__EmploymentType__c;
      mapperEmployment.EmployerName = employment.Name;
      mapperEmployment.EmploymentStatus = employment.FinServ__EmploymentStatus__c;
      mapperEmployment.GrossMonthlySalary = employment.dau01__GrossMonthlySalary__c;
      mapperEmployment.EmploymentStatus = employment.FinServ__EmploymentStatus__c;
      mapperEmployment.Name = employment.Name;
      mapperEmployment.Order = employment.dau01__Order__c;
      mapperEmployment.PayGrade = employment.dau01__PayGrade__c;
      mapperEmployment.Position = employment.FinServ__Position__c;
      mapperEmployment.EmploymentDuration = employment.dau01__EmploymentDuration__c;
      mapperEmployment.DocumentType = employment.dau01__DocumentType__c;
      mapperEmployment.EmploymentVerificationType = employment.dau01__EmploymentVerificationType__c;
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
      mapperIdentity.AddressContentDocumentId = identity.Id;
      mapperIdentity.IssuingCountry = identity.FinServ__IssuingCountry__c;
      mapperIdentity.AddressContentDocumentId = identity.dau01__AddressContentDocumentId__c;
      mapperIdentity.DocumentNumber = identity.FinServ__DocumentNumber__c;
      mapperIdentity.DocumentType = identity.FinServ__DocumentType__c;
      mapperIdentity.ExpirationDate = identity.FinServ__ExpirationDate__c;
      mapperIdentity.Gender = identity.dau01__Gender__c;
      mapperIdentity.Height = identity.dau01__Height__c;
      mapperIdentity.IssueDate = identity.FinServ__IssueDate__c;
      mapperIdentity.IssuedRegion = identity.dau01__IssuedRegion__c;
      mapperIdentity.Name = identity.Name;
      mapperIdentity.Nationality = identity.dau01__Nationality__c;
      mapperIdentity.Order = identity.dau01__Order__c;
      mapperIdentity.PrimaryContentDocumentID = identity.dau01__PrimaryContentDocumentID__c;
      mapperIdentity.SecondaryContentDocumentId = identity.dau01__SecondaryContentDocumentId__c;
      mapperIdentity.Weight = identity.dau01__Weight__c;

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
      mapperRevenue.Order = revenue.dau01__Order__c;
      mapperRevenue.RevenueDate = revenue.FinServ__Date__c;
      mapperRevenue.SubType = revenue.FinServ__SubType__c;
      mapperRevenue.Type = revenue.FinServ__Type__c;
      mapperRevenueList.add(mapperRevenue);
    }
    return mapperRevenueList;
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
      mapperContactAddress.Street = contactAddress.Street;
      mapperContactAddress.Order = contactAddress.dau01__Order__c;
      mapperContactAddressList.add(mapperContactAddress);
    }
    return mapperContactAddressList;
  }
  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilitiesList
   * @return virtual
   **/
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
      mapperAssetsAndLiabilities.Description = assetsAndLiabilities.FinServ__Description__c;
      mapperAssetsAndLiabilities.Name = assetsAndLiabilities.Name;
      mapperAssetsAndLiabilities.Order = assetsAndLiabilities.dau01__Order__c;
      mapperAssetsAndLiabilities.Ownership = assetsAndLiabilities.FinServ__Ownership__c;
      mapperAssetsAndLiabilities.OwnerType = assetsAndLiabilities.FinServ__OwnerType__c;
      mapperAssetsAndLiabilities.Source = assetsAndLiabilities.FinServ__AssetsAndLiabilitiesSource__c;
      mapperAssetsAndLiabilitiesList.add(mapperAssetsAndLiabilities);
    }
    return mapperAssetsAndLiabilitiesList;
  }
}
