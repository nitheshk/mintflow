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
  global ApplicationResponseMapper getApplicationData(string applicationId) {
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
        if (!CollectionUtils.isListEmpty(application.Applicants__r)) {
          for (applicant__c applicant : application.Applicants__r) {
            ApplicationResponseMapper.Applicant mapperApplicant = new ApplicationResponseMapper.Applicant();
            mapperApplicant = mapApplicant(mapperApplicant, applicant);
            mapper.Applicants.add(mapperApplicant);
          }
        } else {
          throw new CustomException('Application has no applicants');
        }
      } else {
        throw new CustomException('Application not found');
      }
      log?.info('getApplicationData -> ReturnMapper -> ' + mapper);
      return mapper;
    }
  }
  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param ApplicationResponseMapper.Applicant mapperApplicant
   * @param applicant__c applicant
   * @return virtual
   **/
  global virtual ApplicationResponseMapper.Applicant mapApplicant(
    ApplicationResponseMapper.Applicant mapperApplicant,
    applicant__c applicant
  ) {
    //Map Application Data
    mapperApplicant.FirstName = applicant?.dau01__FirstName__c;
    mapperApplicant.LastName = applicant?.dau01__LastName__c;
    mapperApplicant.IsExistingCustomer = applicant
      ?.dau01__IsExistingCustomer__c;

    //Map employment data
    if (!CollectionUtils.isListEmpty(applicant.dau01__Employments__r)) {
      mapperApplicant.Employments.addAll(
        mapEmployment(applicant.dau01__Employments__r)
      );
    }

    //Map Identity Data
    if (
      !CollectionUtils.isListEmpty(applicant.dau01__IdentificationDocuments__r)
    ) {
      mapperApplicant.IdentificationDocuments.addAll(
        mapIdentity(applicant.dau01__IdentificationDocuments__r)
      );
    }

    //Map Revenue Data
    if (!CollectionUtils.isListEmpty(applicant.dau01__Revenues__r)) {
      mapperApplicant.Revenues.addAll(mapRevenue(applicant.dau01__Revenues__r));
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
    return mapperApplicant;
  }
  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param List<FinServ__Employment__c> employmentList
   * @return virtual
   **/
  global virtual list<ApplicationResponseMapper.Employment> mapEmployment(
    List<FinServ__Employment__c> employmentList
  ) {
    list<ApplicationResponseMapper.Employment> mapperEmploymentList = new List<ApplicationResponseMapper.Employment>();
    for (FinServ__Employment__c employment : employmentList) {
      ApplicationResponseMapper.Employment mapperEmployment = new ApplicationResponseMapper.Employment();
      mapperEmployment.EmploymentStatus = employment.FinServ__EmploymentStatus__c;
      mapperEmployment.AnnualIncome = employment.FinServ__AnnualIncome__c;
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
  global virtual list<ApplicationResponseMapper.IdentificationDocument> mapIdentity(
    List<FinServ__IdentificationDocument__c> identityList
  ) {
    list<ApplicationResponseMapper.IdentificationDocument> mapperIdentityList = new List<ApplicationResponseMapper.IdentificationDocument>();
    for (FinServ__IdentificationDocument__c identity : identityList) {
      ApplicationResponseMapper.IdentificationDocument mapperIdentity = new ApplicationResponseMapper.IdentificationDocument();
      mapperIdentity.IssuingCountry = identity.FinServ__IssuingCountry__c;
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
  global virtual list<ApplicationResponseMapper.Revenue> mapRevenue(
    List<FinServ__Revenue__c> revenueList
  ) {
    list<ApplicationResponseMapper.Revenue> mapperRevenueList = new List<ApplicationResponseMapper.Revenue>();
    for (FinServ__Revenue__c revenue : revenueList) {
      ApplicationResponseMapper.Revenue mapperRevenue = new ApplicationResponseMapper.Revenue();
      mapperRevenue.Amount = revenue.FinServ__Amount__c;
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
  global virtual list<ApplicationResponseMapper.ContactPointAddress> mapContactAddress(
    List<ContactPointAddress> contactAddressList
  ) {
    list<ApplicationResponseMapper.ContactPointAddress> mapperContactAddressList = new List<ApplicationResponseMapper.ContactPointAddress>();
    for (ContactPointAddress contactAddress : contactAddressList) {
      ApplicationResponseMapper.ContactPointAddress mapperContactAddress = new ApplicationResponseMapper.ContactPointAddress();
      mapperContactAddress.IsPrimary = contactAddress.IsPrimary;
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
  global virtual list<ApplicationResponseMapper.AssetsAndLiabilities> mapContactAddress(
    List<FinServ__AssetsAndLiabilities__c> assetsAndLiabilitiesList
  ) {
    list<ApplicationResponseMapper.AssetsAndLiabilities> mapperAssetsAndLiabilitiesList = new List<ApplicationResponseMapper.AssetsAndLiabilities>();
    for (
      FinServ__AssetsAndLiabilities__c assetsAndLiabilities : assetsAndLiabilitiesList
    ) {
      ApplicationResponseMapper.AssetsAndLiabilities mapperAssetsAndLiabilities = new ApplicationResponseMapper.AssetsAndLiabilities();
      mapperAssetsAndLiabilities.Amount = assetsAndLiabilities.FinServ__Amount__c;
      mapperAssetsAndLiabilitiesList.add(mapperAssetsAndLiabilities);
    }
    return mapperAssetsAndLiabilitiesList;
  }
}
