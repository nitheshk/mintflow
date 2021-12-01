/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description
 **/
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
        throw new CustomException('Application ID cannot be blank');
      }
      Account application = ApplicationService.getInstance()
        .readApplicationWithChildByapplicationNumber(applicationNumber);
      log?.debug('Full Application Json : ' + json.serialize(application));
      if (application != null) {
        ApplicationResponseMapper.Account mapperApplication = new ApplicationResponseMapper.Account();
        mapperApplication.ApplicationId = application.Id;
        mapperApplication.ApplicationNumber = application.mflow__ApplicationNumber__c;
        mapperApplication.BranchCode = application.FinServ__BranchCode__c;
        mapperApplication.BranchName = application.FinServ__BranchName__c;
        mapperApplication.CountyName = application.mflow__CountyName__c;
        mapperApplication.CountyCode = application.mflow__CountyZipCode__c;
        mapperApplication.IsCountyEligible = application.mflow__IsCountyEligible__c;
        mapperApplication.CreatedChannel = application.mflow__CreatedChannel__c;
        mapperApplication.CustomerType = application.FinServ__CustomerType__c;
        mapperApplication.FlowState = application.mflow__FlowState__c;
        mapperApplication.IpAddress = application.mflow__IPAddress__c;
        mapperApplication.IsMemberFlow = application.mflow__isMemberFlow__c;
        mapperApplication.LastUsedChannel = application.FinServ__LastUsedChannel__c;
        mapperApplication.Status = application.FinServ__Status__c;
        mapperApplication.SubmittedBy = application.mflow__SubmittedBy__c;
        mapperApplication.SubmittedDate = application.mflow__SubmittedDate__c;
        mapperApplication.SubStatus = application.mflow__SubStatus__c;
        mapperApplication.UserAccountType = application.mflow__UserAccountType__c;

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
      mapperApplicant.Application = applicant.mflow__Application__c;
      mapperApplicant.FirstName = applicant.mflow__FirstName__c;
      mapperApplicant.MiddleName = applicant.mflow__MiddleName__c;
      mapperApplicant.LastName = applicant.mflow__LastName__c;
      mapperApplicant.IsEmailVerified = applicant.mflow__IsEmailVerified__c;
      mapperApplicant.IsExistingCustomer = applicant.mflow__IsExistingCustomer__c;
      mapperApplicant.IsPhoneNumberVerified = applicant.mflow__IsPhoneNumberVerified__c;
      mapperApplicant.ApplicantName = applicant.Name;
      mapperApplicant.ApplicantNumber = applicant.mflow__ApplicantNumber__c;
      mapperApplicant.ApplicantType = applicant.mflow__ApplicantType__c;
      mapperApplicant.Birthdate = applicant.mflow__Birthdate__c;
      mapperApplicant.CreditScore = applicant.mflow__CreditScore__c;
      mapperApplicant.CustomerNumber = applicant.mflow__CustomerNumber__c;
      mapperApplicant.Email = applicant.mflow__Email__c;
      mapperApplicant.EmploymentStatus = applicant.mflow__EmploymentStatus__c;
      mapperApplicant.FraudStatus = applicant.mflow__FraudStatus__c;
      mapperApplicant.IdentityVerificationStatus = applicant.mflow__IdentityVerificationStatus__c;
      mapperApplicant.IncomeVerificationStatus = applicant.mflow__IncomeVerificationStatus__c;
      mapperApplicant.KYCStatus = applicant.mflow__KYCStatus__c;
      mapperApplicant.Order = applicant.mflow__Order__c;
      mapperApplicant.Phone = applicant.mflow__Phone__c;
      mapperApplicant.SentiLinkFraudScore = applicant.mflow__SentiLinkFraudScore__c;
      mapperApplicant.SentiLinkRemarks = applicant.mflow__SentiLinkRemarks__c;
      mapperApplicant.SentiLinkStatus = applicant.mflow__SentiLinkStatus__c;
      mapperApplicant.SSN = applicant.mflow__SSN__c;

      //Map employment data
      if (!CollectionUtils.isListEmpty(applicant.mflow__Employments__r)) {
        mapperApplicant.Employments.addAll(
          mapEmployment(applicant.mflow__Employments__r)
        );
      }

      //Map Identity Data
      if (
        !CollectionUtils.isListEmpty(
          applicant.mflow__IdentificationDocuments__r
        )
      ) {
        mapperApplicant.IdentificationDocuments.addAll(
          mapIdentity(applicant.mflow__IdentificationDocuments__r)
        );
      }

      //Map Revenue Data
      if (!CollectionUtils.isListEmpty(applicant.mflow__Revenues__r)) {
        mapperApplicant.Revenues.addAll(
          mapRevenue(applicant.mflow__Revenues__r)
        );
      }

      //Map ContatcPointAddress Data
      if (
        !CollectionUtils.isListEmpty(applicant.mflow__ContactPointAddresses__r)
      ) {
        mapperApplicant.ContactPointAddresses.addAll(
          mapContactAddress(applicant.mflow__ContactPointAddresses__r)
        );
      }

      //Map Assest and Liabilities Data
      if (
        !CollectionUtils.isListEmpty(applicant.mflow__AssetsAndLiabilities__r)
      ) {
        mapperApplicant.AssetsAndLiabilities.addAll(
          mapContactAddress(applicant.mflow__AssetsAndLiabilities__r)
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
      mapperEmployment.EmploymentType = employment.mflow__EmploymentType__c;
      mapperEmployment.EmployerName = employment.Name;
      mapperEmployment.EmploymentStatus = employment.FinServ__EmploymentStatus__c;
      mapperEmployment.GrossMonthlySalary = employment.mflow__GrossMonthlySalary__c;
      mapperEmployment.EmploymentStatus = employment.FinServ__EmploymentStatus__c;
      mapperEmployment.Name = employment.Name;
      mapperEmployment.IncomeType = employment.mflow__IncomeType__c;
      mapperEmployment.PayCycle = employment.mflow__PayCycle__c;
      mapperEmployment.Order = employment.mflow__Order__c;
      mapperEmployment.PayGrade = employment.mflow__PayGrade__c;
      mapperEmployment.Position = employment.FinServ__Position__c;
      mapperEmployment.EmploymentDuration = employment.mflow__EmploymentDuration__c;
      mapperEmployment.DocumentType = employment.mflow__DocumentType__c;
      mapperEmployment.EmploymentVerificationType = employment.mflow__EmploymentVerificationType__c;
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
      mapperIdentity.Gender = identity.mflow__Gender__c;
      mapperIdentity.Height = identity.mflow__Height__c;
      mapperIdentity.IssueDate = identity.FinServ__IssueDate__c;
      mapperIdentity.IssuedRegion = identity.mflow__IssuedRegion__c;
      mapperIdentity.Name = identity.Name;
      mapperIdentity.Nationality = identity.mflow__Nationality__c;
      mapperIdentity.Order = identity.mflow__Order__c;
      mapperIdentity.PrimaryContentDocumentID = identity.mflow__PrimaryContentDocumentID__c;
      mapperIdentity.SecondaryContentDocumentId = identity.mflow__SecondaryContentDocumentId__c;
      mapperIdentity.Weight = identity.mflow__Weight__c;

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
      mapperRevenue.Order = revenue.mflow__Order__c;
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
      mapperContactAddress.Order = contactAddress.mflow__Order__c;
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
      mapperAssetsAndLiabilities.Name = assetsAndLiabilities.Name;
      mapperAssetsAndLiabilities.Order = assetsAndLiabilities.mflow__Order__c;
      mapperAssetsAndLiabilities.Ownership = assetsAndLiabilities.FinServ__Ownership__c;
      mapperAssetsAndLiabilities.OwnerType = assetsAndLiabilities.FinServ__OwnerType__c;
      mapperAssetsAndLiabilitiesList.add(mapperAssetsAndLiabilities);
    }
    return mapperAssetsAndLiabilitiesList;
  }
}
