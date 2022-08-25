/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description Application Response Mapper class to sum up application data
 **/
@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
global with sharing class SubmissionDTO {
  /**
   * To Send contructed Data
   * Request By Rpa
   */
  global class ApplicationData {
    global List<FinancialAccount> FinancialAccounts;
    global List<Applicant> Applicants;
    global List<Survey> Surveys;
    global string FinancialProductType;
    global string FinancialProduct;
    global String ApplicationId;
    global Boolean IsCountyEligible;
    global String ApplicationNumber;
    global String CountyCode;
    global String CountyName;
    global String StateName;
    global String BranchCode;
    global String BranchName;
    global String Password;
    // global String CreatedChannel;
    // global String LastUsedChannel;
    // global String CustomerType;
    // global String FlowState;
    // global String IpAddress;
    global Boolean IsMemberFlow;
    // global String Status;
    // global String SubStatus;
    // global String SubmittedBy;
    // global Date SubmittedDate;
    // global String UserAccountType;
    global string ExternalApplicationNumber;
    global ApplicationData() {
      FinancialAccounts = new List<FinancialAccount>();
      Applicants = new List<Applicant>();
      Surveys = new List<Survey>();
    }
  }

  global class FinancialAccount {
    global String FinancialAccountId;
    global String Purpose;
    global String Comments;
    global Decimal CreditLimit;
    global String ExternalApplicationNumber;
    global String InternalCode;
    global String ExternalCode;
    global String FinancialProduct;
    global String FinancialProductType;
    global String Ownership;
    global FinancialAccountTransaction FinancialApplicationTransaction;
    global FinancialAccount() {
      FinancialApplicationTransaction = new FinancialAccountTransaction();
    }
  }

  global class FinancialAccountTransaction {
    global String FinancialAccountTransactionId;
    global Date TransactionDate;
    global string InstitutionState;
    global String AccountNumber;
    global Decimal Amount;
    global String FinancialInstitute;
    global String RoutingNumber;
    global String TransactionType;
    global String TransactionStatus;
    global String AccountHolderName;
    global String TransactionAccountType;
  }

  global class Applicant {
    global String ApplicantId;
    global String ApplicantName;
    global String ApplicantNumber;
    global String ApplicantType;
    global String Application;
    global Date Birthdate;
    // global Decimal CreditScore;
    global String CustomerNumber;
    global String Email;
    global String FirstName;
    // global String FraudStatus;
    // global String IdentityVerificationStatus;
    // global String IncomeVerificationStatus;
    // global Boolean IsEmailVerified;
    global Boolean IsExistingCustomer;
    // global Boolean IsPhoneNumberVerified;
    // global String KYCStatus;
    global String LastName;
    global String MiddleName;
    global Decimal Order;
    global String Phone;
    global String Relationship;
    // global Decimal SentiLinkFraudScore;
    // global String SentiLinkRemarks;
    // global String SentiLinkStatus;
    global String SSN;
    global List<IdentificationDocument> IdentificationDocuments;
    global List<Address> Addresses;
    global List<Employment> Employments;
    global List<Survey> Surveys;
    global Applicant() {
      Employments = new List<Employment>();
      Addresses = new List<Address>();
      IdentificationDocuments = new List<IdentificationDocument>();
      Surveys = new List<Survey>();
    }
  }

  global class Survey {
    global String SurveyId;
    // global String Name;
    global String Answer;
    global String LongDescription;
    // global String OptionType;
    // global String QuestionCode;
    global Decimal Order;
    global String ShortDescription;
    // global String ParentQuestionCode;
    // global Decimal QuestionNumber;
    // global string EventIdentifier;
    // global string TemplateName;
  }

  global class Address {
    global String AddressId;
    global String PostalCode;
    global String Street;
    global String City;
    global String State;
    global String StateCode;
    global Boolean IsPrimary;
    global String Country;
    global String AddressType;
    global String OccupancyStatus;
    global Decimal OccupancyDuration;
    global Decimal Order;
  }

  global class IdentificationDocument {
    global String IdentificationDocumentId;
    // global String Gender;
    // global String Height;
    global String IssuedRegion;
    global Decimal Order;
    // global String PrimaryContentDocumentID;
    // global String SecondaryContentDocumentId;
    // global String Weight;
    global String DocumentType;
    global Date ExpirationDate;
    global Date IssueDate;
    global String DocumentNumber;
    // global String Name;
    global String IssuingCountry;
  }

  global class Employment {
    global String EmploymentId;
    global String EmploymentType;
    global String DocumentType;
    global String IncomeType;
    global String PayCycle;
    global String EmployerName;
    global Double GrossMonthlySalary;
    global Decimal Order;
    global String PayGrade;
    global String Position;
    global String Name;
    global String EmploymentStatus;
    global Decimal EmploymentDuration;
    global string BranchofService;
    global Date EnlistmentDate;
  }

  /**
   * Application Submission Result
   * Recieved from RPA
   */

  global class ApplicationResult {
    global String ExternalApplicationNumber;
    global String ExternalApplicationStatus;
    global String MemberNumber;
    global String ApplicationId;
    global Boolean IsExistingCustomer;
    global List<FinancialAccountResult> FinancialAccounts;
    global list<ApplicantResult> Applicants;
  }

  global class ApplicantResult {
    global String ApplicantId;
    global String CustomerNumber;
  }

  global class FinancialAccountResult {
    global String FinancialAccountId;
    global String AccountNumber;
    global FinancialTransactionResult FinancialApplicationTransaction;
  }

  global class FinancialTransactionResult {
    global String FinancialAccountTransactionId;
    global String TransactionStatus;
  }
}
