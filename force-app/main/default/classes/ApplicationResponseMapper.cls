/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description Application Response Mapper class to sum up application data
 **/
@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
global with sharing class ApplicationResponseMapper {
  global Account Application;

  global ApplicationResponseMapper() {
    Application = new Account();
  }
  //global List<FinancialAccount> FinancialAccounts;
  global class Account {
    global List<Applicant> Applicants;
    global String ApplicationId;
    global Boolean IsCountyEligible;
    global String ApplicationNumber;
    global String CountyCode;
    global String CountyName;
    global String BranchCode;
    global String BranchName;
    global String CreatedChannel;
    global String LastUsedChannel;
    global String CustomerType;
    global String FlowState;
    global String IpAddress;
    global Boolean IsMemberFlow;
    global String Status;
    global String SubStatus;
    global String SubmittedBy;
    global Date SubmittedDate;
    global String UserAccountType;
    global Account() {
      Applicants = new List<Applicant>();
    }
  }
  global class Applicant {
    global String ApplicantId;
    global String ApplicantName;
    global String ApplicantNumber;
    global String ApplicantType;
    global String Application;
    global Date Birthdate;
    global Decimal CreditScore;
    global String CustomerNumber;
    global String Email;
    global String FirstName;
    global String FraudStatus;
    global String IdentityVerificationStatus;
    global String IncomeVerificationStatus;
    global Boolean IsEmailVerified;
    global Boolean IsExistingCustomer;
    global Boolean IsPhoneNumberVerified;
    global String KYCStatus;
    global String LastName;
    global String MiddleName;
    global Decimal Order;
    global String Phone;
    global Decimal SentiLinkFraudScore;
    global String SentiLinkRemarks;
    global String SentiLinkStatus;
    global String SSN;
    global List<IdentificationDocument> IdentificationDocuments;
    global List<ContactPointAddress> ContactPointAddresses;
    global List<Revenue> Revenues;
    global List<Employment> Employments;
    // global List<AssetsAndLiabilities> AssetsAndLiabilities;
    global Applicant() {
      Employments = new List<Employment>();
      Revenues = new List<Revenue>();
      ContactPointAddresses = new List<ContactPointAddress>();
      IdentificationDocuments = new List<IdentificationDocument>();
      // AssetsAndLiabilities = new List<AssetsAndLiabilities>();
    }
  }

  // global class AssetsAndLiabilities {
  //   global String AssetsAndLiabilitieId;
  //   global Double Amount;
  //   global String AssetsAndLiabilitiesType;
  //   global Decimal Order;
  //   global String OwnerType;
  //   global String Ownership;
  //   global String Name;
  // }

  global class Revenue {
    global String RevenueId;
    global String SubType;
    global String Type;
    global String Name;
    global Double Amount;
    global Date RevenueDate;
    global Decimal Order;
  }

  global class ContactPointAddress {
    global String ContactPointAddressId;
    global String PostalCode;
    global String Street;
    global String City;
    global String State;
    global Boolean IsPrimary;
    global String Country;
    global String AddressType;
    global Decimal Order;
  }

  global class IdentificationDocument {
    global String IdentificationDocumentId;
    global String Gender;
    global String Height;
    global String IssuedRegion;
    global String Nationality;
    global Decimal Order;
    global String PrimaryContentDocumentID;
    global String SecondaryContentDocumentId;
    global String Weight;
    global String DocumentType;
    global Date ExpirationDate;
    global Date IssueDate;
    global String DocumentNumber;
    global String Name;
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
    global String EmploymentVerificationType;
  }

  /**
   *  ----------------------- KYC Result --------------------
   */

  global class KYCResult {
    global String ApplicationId;
    global String ApplicationNumber;
    global String ExternalApplicationNumber;
    global String ExternalApplicationStatus;
    global Boolean ExistingCustomer;
    global list<KYCApplicantResult> applicants;
  }

  global class KYCApplicantResult {
    global String ApplicantId;
    global String CustomerNumber;
    global String OverallDebitBureauResult;
    global Integer CreditScore;
    global Integer QualifiedScore;
    global Integer CustomerScore;
    global String HighRiskConsumer;
    global String QualifiedDecision;
    global String IdentityVerificationStatus;
    global String OFAC;
    global String SSNValidation;
    global String RunWithoutKIQ;
    global String RunWithKIQ;
  }
}
