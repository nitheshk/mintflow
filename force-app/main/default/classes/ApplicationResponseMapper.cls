/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description Application Response Mapper class to sum up application data
 **/
@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
global with sharing class ApplicationResponseMapper extends AbstractDTO {
  global List<Applicant> Applicants;
  global ApplicationResponseMapper() {
    Applicants = new List<Applicant>();
  }
  //global List<FinancialAccount> FinancialAccounts;

  global class Applicant {
    global String ApplicantName;
    global String ApplicantNumber;
    global String ApplicantType;
    global String Application;
    global Date Birthdate;
    global Decimal CreditScore;
    global String CustomerNumber;
    global Boolean DeleteRecord;
    global String Email;
    global String EmploymentStatus;
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
    global List<AssetsAndLiabilities> AssetsAndLiabilities;
    global Applicant() {
      Employments = new List<Employment>();
      Revenues = new List<Revenue>();
      ContactPointAddresses = new List<ContactPointAddress>();
      IdentificationDocuments = new List<IdentificationDocument>();
      AssetsAndLiabilities = new List<AssetsAndLiabilities>();
    }
  }

  global class AssetsAndLiabilities {
    global Double Amount;
    global String Applicant;
    global String AssetsAndLiabilitiesType;
    global String Description;
    global Boolean DeleteRecord;
    global Decimal Order;
    global String OwnerType;
    global String Ownership;
    global string Source;
    global String Name;
  }

  global class Revenue {
    global Boolean DeleteRecord;
    global String SubType;
    global String Type;
    global String Applicant;
    global String Name;
    global Double Amount;
    global Date RevenueDate;
    global Decimal Order;
  }

  global class ContactPointAddress {
    global Boolean DeleteRecord;
    global String PostalCode;
    global String Applicant;
    global String Name;
    global Double MonthsLivedAtCurrentAddress;
    global Double YearsLivedAtCurrentAddress;
    global String Street;
    global Boolean IsDefault;
    global String City;
    global String State;
    global Boolean IsPrimary;
    global String Country;
    global String AddressType;
    global Decimal Order;
  }

  global class IdentificationDocument {
    global String AddressContentDocumentId;
    global String Gender;
    global String Height;
    global String IssuedRegion;
    global String Nationality;
    global Decimal Order;
    global String PrimaryContentDocumentID;
    global String SecondaryContentDocumentId;
    global string Weight;
    global String DocumentType;
    global Date ExpirationDate;
    global Date IssueDate;
    global String DocumentNumber;
    global String Applicant;
    global String Name;
    global Boolean DeleteRecord;
    global String IssuingCountry;
  }

  global class Employment {
    global String Occupation;
    global Double AnnualIncome;
    global String Applicant;
    global Boolean DeleteRecord;
    global string EmployerPhoneNumber;
    global Date EndDate;
    global Decimal LengthOfEmployment;
    global decimal Order;
    global String PayGrade;
    global string Position;
    global Date StartDate;
    global String Name;
    global String EmploymentStatus;
  }
}
