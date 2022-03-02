/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class BuildApplicationWrapper extends AbstractService {
  @TestVisible
  private static BuildApplicationWrapper serviceInstance;

  public BuildApplicationWrapper() {
    super(BuildApplicationWrapper.class);
  }
  /**
   * @description Provides a singleton instance of BuildApplicationWrapper from which all other class methods can be accessed.
   * @author Digital Align Team | 01/17/2022
   * @return Object  singleton
   **/
  public static BuildApplicationWrapper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (BuildApplicationWrapper) getInstance(
        BuildApplicationWrapper.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align | 11-10-2021
   * @param string applicationId
   * @return ApplicationSubmissionResponse
   **/
  global virtual ApplicationSubmissionResponse obtainApplicationData(
    string applicationNumber
  ) {
    {
      log
        ?.fine(
          'Inside obtainApplicationData -> applicationNumber -> ' +
          applicationNumber
        );
      ApplicationSubmissionResponse mapper = new ApplicationSubmissionResponse();

      if (String.isBlank(applicationNumber)) {
        throw new CustomException(
          System.Label.Application_ApplicationNameCannotBeBlank
        );
      }
      Application__c application = SubmissionRepository.readApplicationByApplicationNumber(
        applicationNumber
      );
      if (application == null) {
        throw new customException(System.Label.Application_ApplicationNotFound);
      }
      application = readApplicationWithChild(application.Id);

      //log?.debug('Full Application Json : ' + json.serialize(application));
      if (application != null) {
        ApplicationSubmissionResponse.Account mapperApplication = new ApplicationSubmissionResponse.Account();
        mapperApplication.ApplicationId = application.Id;
        mapperApplication.ApplicationNumber = application.Name;
        mapperApplication.BranchCode = application.BranchCode__c;
        mapperApplication.BranchName = application.BranchName__c;
        mapperApplication.CountyName = application.CountyName__c;
        mapperApplication.StateName = application.StateName__c;
        mapperApplication.CountyCode = application.CountyZipCode__c;
        mapperApplication.IsCountyEligible = application.IsCountyEligible__c;
        // mapperApplication.CreatedChannel = application.CreatedChannel__c;
        mapperApplication.ExternalApplicationNumber = application.ExternalApplicationNumber__c;
        // mapperApplication.CustomerType = application.ApplicationType__c;
        // mapperApplication.FlowState = application.FlowState__c;
        // mapperApplication.IpAddress = application.IPAddress__c;
        // mapperApplication.IsMemberFlow = application.isMemberFlow__c;
        // mapperApplication.LastUsedChannel = application.LastUsedChannel__c;
        // mapperApplication.Status = application.Status__c;
        // mapperApplication.SubmittedBy = application.SubmittedBy__c;
        // mapperApplication.SubmittedDate = application.SubmittedDate__c;
        // mapperApplication.SubStatus = application.Stage__c;
        // mapperApplication.UserAccountType = application.UserAccountType__c;

        if (!CollectionUtils.isListEmpty(application.Applicants__r)) {
          mapperApplication.Applicants.addAll(
            mapApplicant(application.Applicants__r)
          );
        } else {
          throw new CustomException(
            System.Label.Application_ApplicationHasNoApplicants
          );
        }
        //#removeFSC remove comment
        // if (!CollectionUtils.isListEmpty(application.Surveys__r)) {
        //   mapperApplication.Surveys.addAll(mapSurvey(application.Surveys__r));
        // }
        mapper.Application = mapperApplication;
      } else {
        throw new CustomException(System.Label.Application_ApplicationNotFound);
      }
      log
        ?.info(
          'obtainApplicationData -> ReturnMapper -> ' + Json.serialize(mapper)
        );
      return mapper;
    }
  }
  /**
   * @description
   * @author Digital Align | 11-16-2021
   * @param List<applicant__c> applicantList
   * @return list<ApplicationSubmissionResponse.Applicant>
   **/
  global virtual list<ApplicationSubmissionResponse.Applicant> mapApplicant(
    List<applicant__c> applicantList
  ) {
    list<ApplicationSubmissionResponse.Applicant> mapperApplicantList = new List<ApplicationSubmissionResponse.Applicant>();
    for (applicant__c applicant : applicantList) {
      ApplicationSubmissionResponse.Applicant mapperApplicant = new ApplicationSubmissionResponse.Applicant();
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
      // mapperApplicant.IncomeVerificationStatus = applicant.IncomeVerificationStatus__c;
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
  global virtual list<ApplicationSubmissionResponse.Employment> mapEmployment(
    List<FinServ__Employment__c> employmentList
  ) {
    list<ApplicationSubmissionResponse.Employment> mapperEmploymentList = new List<ApplicationSubmissionResponse.Employment>();
    for (FinServ__Employment__c employment : employmentList) {
      ApplicationSubmissionResponse.Employment mapperEmployment = new ApplicationSubmissionResponse.Employment();
      mapperEmployment.EmploymentId = employment.Id;
      mapperEmployment.EmploymentType = employment.EmploymentType__c;
      mapperEmployment.EmployerName = employment.Name;
      mapperEmployment.EmploymentStatus = getStatusMapping(
        'EmploymentStatus__c',
        employment.EmploymentStatus__c
      );
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
  global virtual list<ApplicationSubmissionResponse.IdentificationDocument> mapIdentity(
    List<IdentificationDocument__c> identityList
  ) {
    list<ApplicationSubmissionResponse.IdentificationDocument> mapperIdentityList = new List<ApplicationSubmissionResponse.IdentificationDocument>();
    for (IdentificationDocument__c identity : identityList) {
      ApplicationSubmissionResponse.IdentificationDocument mapperIdentity = new ApplicationSubmissionResponse.IdentificationDocument();
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
   * @return list<ApplicationSubmissionResponse.Survey>
   **/
  global virtual list<ApplicationSubmissionResponse.Survey> mapSurvey(
    List<mflow__Survey__c> surveyList
  ) {
    list<ApplicationSubmissionResponse.Survey> mapperSurveyList = new List<ApplicationSubmissionResponse.Survey>();
    for (mflow__Survey__c survey : surveyList) {
      ApplicationSubmissionResponse.Survey mapperSurvey = new ApplicationSubmissionResponse.Survey();
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
  global virtual list<ApplicationSubmissionResponse.ContactPointAddress> mapContactAddress(
    List<ContactPointAddress> contactAddressList
  ) {
    list<ApplicationSubmissionResponse.ContactPointAddress> mapperContactAddressList = new List<ApplicationSubmissionResponse.ContactPointAddress>();
    for (ContactPointAddress contactAddress : contactAddressList) {
      ApplicationSubmissionResponse.ContactPointAddress mapperContactAddress = new ApplicationSubmissionResponse.ContactPointAddress();
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
      mapperContactAddress.OccupancyStatus = getStatusMapping(
        'UsageType',
        contactAddress.UsageType
      );
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
    List<Map<string, string>> fileDetails = new List<Map<string, string>>();
    Application__c application = SubmissionRepository.readApplicationByApplicationNumber(
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
    String eligibleFileFormat = ApplicationConfiguration__c.getInstance()
      .SupportedFileTypes__c;
    List<String> eligibleFileFormatList = String.isNotBlank(eligibleFileFormat)
      ? eligibleFileFormat.split(';')
      : new List<String>();
    List<ContentVersion> fileList = FileService.getInstance()
      .fetchContentVersionByEntityIds(reletedEntityIdList, true);

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
    return ApexResponse.OK(fileDetails)
      .addHeader('Content-Type', 'application/json');
  }
  /**
   * @description Read application by parameter passed
   * @author Digital Align Team | 10-21-2021
   * @param Map<String Object> params
   * @return Application__c
   **/
  global virtual Application__c readApplicationWithChild(Id applicationId) {
    Application__c application = SubmissionRepository.readApplicationWithChild(
      applicationId
    );

    List<Applicant__c> applicants = readApplicantsWithChild(
      application.Applicants__r
    );
    List<FinancialAccount__c> financialAccounts = FinancialAccountService.getInstance()
      .readFinancialAccountsWithChild(application.mflow__FinancialAccounts__r);

    //Combine result into single application object
    SObjectConstructor builder = SObjectConstructor.getInstance(application);
    builder.setChildObjects('mflow__Applicants__r', applicants);
    builder.setChildObjects('mflow__FinancialAccounts__r', financialAccounts);
    return (Application__c) builder.build();
  }

  /**
   * @description Read all applicant by applicant records
   * @author Digital Align Team | 10-26-2021
   * @param List<Applicant__c> applicants
   **/
  global virtual List<Applicant__c> readApplicantsWithChild(
    List<Applicant__c> applicants
  ) {
    return SubmissionRepository.readApplicantsWithChild(
      new Map<Id, SObject>(applicants).keySet()
    );
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
