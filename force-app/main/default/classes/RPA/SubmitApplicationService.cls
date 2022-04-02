/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class SubmitApplicationService extends AbstractService {
  @TestVisible
  private static SubmitApplicationService serviceInstance;

  public SubmitApplicationService() {
    super(SubmitApplicationService.class);
  }

  /**
   * @description Provides a singleton instance of SubmitApplicationService from which all other class methods can be accessed.
   * @author Digital Align Team | 03/29/2022
   * @return Object  singleton
   **/
  public static SubmitApplicationService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (SubmitApplicationService) getInstance(SubmitApplicationService.class);
    }
    return serviceInstance;
  }

  /**
   * @description Submit the application review by Primary/Joint
   * @author Digital Align Team | 11-12-2021
   * @param Id applicationId
   * @return Application__c
   **/
  global virtual Application__c submit(String data) {
    log?.fine('Inside submit');
    Application__c application = (Application__c) SObjectConstructor.deserialize(data, Application__c.class);
    application = ApplicationService.getInstance().saveApplication(application);

    if (application.Status__c == ApplicationConstant.SUBMITTED) {
      throw new CustomException('Application Already Submitted');
    }

    //update kyc and status fields
    this.validateSubmission(application);

    log?.fine('Completed reviewInformationSubmit');
    return application;
  }

  /**
   * @description Primary Review Submit action
   * @author Digital Align Team | 11-12-2021
   * @param Application__c application
   * @return Application__c
   **/
  global virtual Application__c validateSubmission(Application__c application) {
    application = SubmissionRepository.readApplicationForSubmit(application.Id);

    Applicant__c primaryApplicant;
    Applicant__c currentApplicant;
    List<mflow__Applicant__c> jointApplicants = new List<mflow__Applicant__c>();

    Boolean isFlowCompleted = true;
    Boolean isKYCApproved = true;

    //list has only primary and joint applicant by soql
    for (Applicant__c applicant : application.Applicants__r) {
      if (applicant.Id == ApexRequest.getApplicantId()) {
        applicant.Status__c = ApplicationConstant.SUBMITTED;
        currentApplicant = applicant;
      }

      if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        primaryApplicant = applicant;
      } else if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_JOINT_RECORDTYPE) {
        jointApplicants.add(applicant);
      }

      if (applicant.KYCStatus__c != ApplicationConstant.KYC_PASSED) {
        isKYCApproved = false;
      }

      if (applicant.Status__c != ApplicationConstant.SUBMITTED) {
        isFlowCompleted = false;
      }
    }

    // ALL Applicant Submitted
    if (isFlowCompleted && isKYCApproved) {
      application.Status__c = ApplicationConstant.SUBMITTED;
      application.KycStatus__c = ApplicationConstant.KYC_PASSED;
      application.SubmittedDate__c = Datetime.now();
      application.SubmittedBy__c = UserInfo.getUserId();

      if (!CollectionUtils.isListEmpty(application.FinancialAccounts__r)) {
        application.FinancialAccounts__r[0].Status__c = ApplicationConstant.SUBMITTED;
      }

      CustomerEmailService.getInstance()
        .reviewInformationSubmitted(
          new List<mflow__Applicant__c>{ primaryApplicant },
          'PrimaryReviewInformationSubmitted'
        );
    } else if (isFlowCompleted && !isKYCApproved) {
      application.Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
      application.KycStatus__c = ApplicationConstant.KYC_UNDER_REVIEW;
      application.SubmittedDate__c = Datetime.now();
      application.SubmittedBy__c = UserInfo.getUserId();

      if (!CollectionUtils.isListEmpty(application.FinancialAccounts__r)) {
        application.FinancialAccounts__r[0].Status__c = ApplicationConstant.SUBMITTED;
      }

      CustomerEmailService.getInstance()
        .reviewInformationSubmitted(
          new List<mflow__Applicant__c>{ primaryApplicant },
          'PrimaryReviewInformationSubmitted'
        );
    } else {
      if (ApexRequest.getApplicantType() == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        application.Status__c = ApplicationConstant.SAVED;
        //1. send Email to Primary applicant with resume link
        CustomerEmailService.getInstance()
          .reviewInformationSubmitted(
            new List<mflow__Applicant__c>{ primaryApplicant },
            'PrimaryReviewInformationWaiting'
          );

        //2. Send Email to Joint with resume link
        List<applicant__c> notSubmittedJointApplicants = new List<applicant__c>();
        for (applicant__c jointApplicant : jointApplicants) {
          if (jointApplicant.Status__c != ApplicationConstant.SUBMITTED) {
            notSubmittedJointApplicants.add(jointApplicant);
          }
        }

        CustomerEmailService.getInstance()
          .reviewInformationSubmitted(notSubmittedJointApplicants, 'JointStartApplication');
      }
    }

    ApplicationRepository.upsertRecords(application.Applicants__r);
    ApplicationRepository.upsertRecords(application.FinancialAccounts__r);
    ApplicationRepository.upsertRecord(application);
    log?.info('Completed validateSubmission');
    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 03-30-2022
   * @param Id applicationId
   * @return Application__c
   **/
  global virtual Application__c submitToCoreSystem(Id applicationId) {
    log?.fine('Inside submitToCoreSystem');
    Application__c application = SubmissionRepository.readApplicationForSubmit(applicationId);
    if (application.status__c != ApplicationConstant.SUBMITTED) {
      throw new CustomException('Application not completed yet');
    }
    HttpBuilder.Response response = RpaProcessService.getInstance().scheduleApplication(application);
    if (response.statusCode == 201) {
      application.Stage__c = ApplicationConstant.SUBMITTED;
      NotificationService.getInstance()
        .dispatchSubmitNotification('onApplicationSubmitted', application.Id, application.Name, null);
    } else {
      application.Stage__c = 'Exception';
      NotificationService.getInstance()
        .dispatchSubmitNotification('onApplicationFailed', application.Id, application.Name, response.status);
    }
    ApplicationRepository.upsertRecord(application);
    log?.fine('Completed submitToCoreSystem');
    return application;
  }

  /**
   * @description
   * @author Digital Align Team | 03-30-2022
   * @param String resultJson
   * @return Application__c
   **/
  global virtual Application__c updateSubmissionInfo(String resultJson) {
    log?.fine('Inside updateSubmissionInfo');
    SubmissionDTO.ApplicationResult submissionResult = (SubmissionDTO.ApplicationResult) JSON.deserialize(
      resultJson,
      SubmissionDTO.ApplicationResult.class
    );
    // When result is null
    if (submissionResult == null) {
      throw new CustomException('Unable to process the empty request');
    }

    Application__c application = SubmissionRepository.readApplicationForSubmit(submissionResult.ApplicationId);
    ApexRequest.setApplicationId(application.Id);
    ApexRequest.setApplicationName(application.Name);

    //chatter post on record level
    NotificationBuilder.chatterMessagePost(application.Id, 'Funding Response from meridian link  : ' + resultJson);

    // if (application.Status__c == ApplicationConstant.COMPLETED) {
    //   throw new CustomException('Application has already completed');
    // }

    try {
      // Primary is Existing Customer
      if (submissionResult.IsExistingCustomer == true) {
        return this.processExistingMember(application, submissionResult);
      }

      application = this.updateApplicationResult(application, submissionResult);

      if (application.Status__c == ApplicationConstant.COMPLETED) {
        //Create Account and contact
        this.createMemberAccount(application);
        //Send Funding Email Link to primary
        CustomerEmailService.getInstance().accountOpened(application);
        NotificationService.getInstance()
          .dispatchSubmitNotification(
            'onApplicationCompleted',
            ApexRequest.getApplicationId(),
            ApexRequest.getApplicationName(),
            null
          );
        // Send Customer Interest to Primary Applicant
        SubmitApplicationService.notifyProductInterestAsync(application.Id);
      } else {
        NotificationService.getInstance()
          .dispatchSubmitNotification(
            'onApplicationFailed',
            ApexRequest.getApplicationId(),
            ApexRequest.getApplicationName(),
            null
          );
      }
      return application;
    } catch (Exception ex) {
      NotificationService.getInstance()
        .generalExceptionNotification(ApexRequest.getApplicationId(), ApexRequest.getApplicationName(), ex);
      log?.error(ex);
      throw ex;
    } finally {
      log?.fine('Completed updateSubmissionInfo');
    }
  }

  /**
   * @description
   * @author Digital Align Team | 01-27-2022
   * @param Application__c application
   * @param SubmissionDTO.ApplicationResult submissionResult
   * @return Application__c
   **/
  global virtual Application__c updateApplicationResult(
    Application__c application,
    SubmissionDTO.ApplicationResult submissionResult
  ) {
    switch on submissionResult.ExternalApplicationStatus {
      when 'Accept', 'Passed', 'Approved' {
        application.Status__c = ApplicationConstant.COMPLETED;
        application.MemberNumber__c = submissionResult.MemberNumber;

        Map<Id, Applicant__c> applicantMap = new Map<Id, Applicant__c>(application.Applicants__r);
        for (SubmissionDTO.ApplicantResult applicantResult : submissionResult.Applicants) {
          Applicant__c applicant = applicantMap.get(applicantResult.ApplicantId);
          applicant.mflow__CustomerNumber__c = applicantResult.CustomerNumber;
          applicant.mflow__Status__c = ApplicationConstant.COMPLETED;
        }
      }
      when else {
        application.Status__c = ApplicationConstant.REVISION_IN_PROGRESS;
        application.MemberNumber__c = submissionResult.MemberNumber;
      }
    }

    if (!CollectionUtils.isListEmpty(submissionResult?.FinancialAccounts)) {
      SubmissionDTO.FinancialAccountResult financialAccountResult = submissionResult.FinancialAccounts[0];

      if (String.isNotBlank(financialAccountResult.FinancialAccountId)) {
        FinancialAccount__c fa = new FinancialAccount__c(
          Id = financialAccountResult.FinancialAccountId,
          AccountNumber__c = financialAccountResult.AccountNumber
        );
        if (application.Status__c == ApplicationConstant.COMPLETED) {
          fa.Status__c = ApplicationConstant.COMPLETED;
        }
        SubmissionRepository.upsertRecord(fa);
      }

      if (financialAccountResult?.FinancialApplicationTransaction?.FinancialAccountTransactionId != null) {
        //FUNDED
        FinancialAccountTransaction__c fat = new FinancialAccountTransaction__c(
          Id = financialAccountResult.FinancialApplicationTransaction.FinancialAccountTransactionId,
          TransactionStatus__c = 'Posted'
        );
        SubmissionRepository.upsertRecord(fat);
      }
    }

    SubmissionRepository.upsertRecord(application);
    SubmissionRepository.upsertRecords(application.Applicants__r);
    return application;
  }

  /**
   * @description  Primary is Existing Customer
   * Used when kyc result is return from Server
   * @author Digital Align Team | 12-07-2021
   * @param Application__c application
   * @param SubmissionDTO.ApplicationResult submissionResult
   * @return Application__c
   **/
  global virtual Application__c processExistingMember(
    Application__c application,
    SubmissionDTO.ApplicationResult submissionResult
  ) {
    log?.info('Inside processExistingMember');
    application.isMemberFlow__c = false;
    application.Status__c = ApplicationConstant.CANCELLED;
    application.mflow__Stage__c = ApplicationConstant.STAGE_EXISTING_CUSTOMER;
    application.mflow__FlowState__c = ApplicationConstant.FINAL_CONFIRMATION;
    for (Applicant__c applicant : application.Applicants__r) {
      if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        applicant.IsExistingCustomer__c = true;
      }
      applicant.mflow__Status__c = ApplicationConstant.CANCELLED;
      applicant.mflow__FlowState__c = ApplicationConstant.FINAL_CONFIRMATION;
    }
    for (FinancialAccount__c financialAccount : application.FinancialAccounts__r) {
      financialAccount.ExternalApplicationNumber__c = submissionResult.ExternalApplicationNumber;
      financialAccount.ExternalApplicationStatus__c = submissionResult.ExternalApplicationStatus;
    }

    NotificationBuilder.chatterMessagePost(
      application.Id,
      'Application has been cancelled because, Primary member already linked with membership account'
    );
    SubmissionRepository.upsertRecords(application.Applicants__r);
    SubmissionRepository.upsertRecords(application.FinancialAccounts__r);
    SubmissionRepository.upsertRecord(application);
    log?.info('Completed processExistingMember');
    return application;
  }

  /**
   * @description create Membership Account
   * Create Contact and Account in system if contact is not already present
   * @author Digital Align Team | 12-10-2021
   * @param Application__c application
   * @return Application__c
   **/
  global virtual Application__c createMemberAccount(Application__c application) {
    String filter = '';
    Map<Id, Applicant__c> applicantToProcess = new Map<Id, Applicant__c>();

    for (Applicant__c applicant : application.Applicants__r) {
      applicantToProcess.put(applicant.Id, applicant);
      if (String.isNotBlank(filter)) {
        filter += ' OR ';
      }
      filter += '(mflow__SSN__c=\'' + applicant.SSN__c?.trim() + '\' AND ';
      filter += 'LastName=\'' + applicant.LastName__c?.trim() + '\')';
    }

    // #Attribute
    List<Contact> existingContacts = SubmissionRepository.fetchExistingContacts(filter);
    // #Attribute
    Map<String, Contact> ssnVsContact = new Map<String, Contact>();
    for (Contact con : existingContacts) {
      ssnVsContact.put(con.SSN__c, con);
    }

    List<Contact> contactToUpsert = new List<Contact>();
    for (Applicant__c applicant : applicantToProcess.values()) {
      if (ssnVsContact.containsKey(applicant.SSN__c)) {
        Contact memberContact = this.mapApplicantWithContact(applicant, ssnVsContact.get(applicant.SSN__c));
        applicant.Contact__c = memberContact.Id;
        applicant.Contact__r = memberContact;
        contactToUpsert.add(memberContact);
      } else {
        Account memberAccount = this.createAccount(applicant);
        Contact memberContact = new Contact(AccountId = memberAccount.Id);
        memberContact = this.mapApplicantWithContact(applicant, memberContact);
        SubmissionRepository.upsertRecord(memberContact);
        applicant.Contact__c = memberContact.Id;
        applicant.Contact__r = memberContact;
        contactToUpsert.add(memberContact);
      }
    }

    for (Applicant__c applicant : applicantToProcess.values()) {
      if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
        CusomterCommunitySiteService.getInstance().createCustomerCommunityUser(applicant.Contact__r);
        break;
      }
    }

    SubmissionRepository.upsertRecords(contactToUpsert);
    SubmissionRepository.upsertRecords(application.Applicants__r);
    return application;
  }

  /**
   * @description Create Individual Account and Contact in salesforce
   * @author Digital Align Team | 12-10-2021
   * @param Applicant__c applicant
   * @return Account
   **/
  global virtual Account createAccount(Applicant__c applicant) {
    Account individualAccount = new Account();
    individualAccount.Name = applicant.ApplicantName__c;
    // #info
    // Added for customer community user license only
    // Work for Cusotmer Community plus user without owner assingment
    //individualAccount.OwnerId = UserUtils.getCurrentUser().CreatedById;
    if (UserUtils.isGuestUser()) {
      individualAccount.OwnerId = UserUtils.getCurrentGuestDefaultOwnerId();
    } else {
      individualAccount.OwnerId = UserInfo.getUserId();
    }
    individualAccount.UserAccountType__c = 'IndividualCustomer';
    SubmissionRepository.upsertRecord(individualAccount);
    return individualAccount;
  }

  /**
   * @description map applicant data with contact data
   * @author Digital Align Team | 12-10-2021
   * @param Applicant__c applicant
   * @param Contact memberContact
   * @return Contact
   **/
  global virtual Contact mapApplicantWithContact(Applicant__c applicant, Contact memberContact) {
    //Not existing Contact then map new names
    if (String.isBlank(memberContact.Id)) {
      memberContact.FirstName = applicant.FirstName__c;
      memberContact.LastName = applicant.LastName__c;
      memberContact.SSN__c = applicant.SSN__c;
    }
    memberContact.UserContactType__c = 'IndividualCustomer';
    memberContact.Email = applicant.Email__c;
    memberContact.Phone = applicant.Phone__c;
    memberContact.IsEmailVerified__c = applicant.IsEmailVerified__c;
    memberContact.IsPhoneNumberVerified__c = applicant.IsPhoneNumberVerified__c;
    memberContact.RunWithKIQ__c = applicant.RunWithKIQ__c;
    memberContact.RunWithoutKIQ__c = applicant.RunWithoutKIQ__c;
    memberContact.IdentityVerificationStatus__c = applicant.IdentityVerificationStatus__c;
    memberContact.Birthdate = applicant.Birthdate__c;
    memberContact.SSNValidation__c = applicant.SSNValidation__c;
    memberContact.CreditScore__c = applicant.CreditScore__c;
    memberContact.CustomerScore__c = applicant.CustomerScore__c;
    memberContact.HighRiskConsumer__c = applicant.HighRiskConsumer__c;
    memberContact.OFAC__c = applicant.OFAC__c;
    memberContact.OverallDebitBureauResult__c = applicant.OverallDebitBureauResult__c;
    memberContact.QualifiedDecision__c = applicant.QualifiedDecision__c;
    memberContact.QualifiedScore__c = applicant.QualifiedScore__c;
    memberContact.FraudStatus__c = applicant.FraudStatus__c;
    memberContact.KYCStatus__c = applicant.KYCStatus__c;
    memberContact.SentiLinkFraudScore__c = applicant.SentiLinkFraudScore__c;
    memberContact.SentiLinkStatus__c = applicant.SentiLinkStatus__c;
    memberContact.MiddleName__c = applicant.MiddleName__c;
    return memberContact;
  }

  /**
   * @description Notify Product Interest Async
   * @author Digital Align Team | 03-15-2022
   * @param Id applicationId
   **/
  @future
  global static void notifyProductInterestAsync(Id applicationId) {
    SubmitApplicationService.getInstance().notifyProductInterest(applicationId);
  }

  /**
   * @description  Notify Product Interest
   * @author Digital Align Team | 03-15-2022
   * @param applicationId ;
   * @return Application__c
   **/
  global virtual Application__c notifyProductInterest(Id applicationId) {
    log?.fine('Inside notifyProductInterest');
    Application__c application = SubmissionRepository.readApplicationForProductInterest(applicationId);
    if (!CollectionUtils.isListEmpty(application.mflow__CustomerInterests__r)) {
      Map<String, Object> interestedProductParams = new Map<String, Object>();
      for (CustomerInterest__c customerInterest : application.mflow__CustomerInterests__r) {
        Map<String, Object> params = new Map<String, Object>();
        params.put('app', application.Name);
        params.put('ch', application.CreatedChannel__c);
        params.put('pid', customerInterest.InterestProduct__r.InternalCode__c);
        params.put(
          'edt',
          Datetime.now().addHours((Integer) ApplicationConfiguration__c.getInstance().ReferralUrlExpirationTime__c)
        );
        interestedProductParams.put(
          customerInterest.InterestProduct__r.DisplayLabel__c,
          SecurityUtils.encryptUrl(JSON.serialize(params, true))
        );
      }

      for (Applicant__c applicant : application.Applicants__r) {
        if (applicant.RecordType.Name == ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE) {
          CustomerEmailService.getInstance().notifyProductInterest(applicant, interestedProductParams);
          break;
        }
      }
    }
    log?.fine('Completed notifyProductInterest');
    return application;
  }
}
