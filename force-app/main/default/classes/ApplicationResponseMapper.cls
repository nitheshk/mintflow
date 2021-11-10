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
    global String Application;
    global Boolean IsEmailVerified;
    global String LastName;
    global Boolean IsExistingCustomer;
    global String Name;

    global Boolean IsPhoneNumberVerified;
    global Boolean DeleteRecord;
    global String FirstName;
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
    global String AssetsAndLiabilitiesType;
    global String Description;
    global String Applicant;
    global String Name;
    global Double Amount;
    global String Source;
  }

  global class Revenue {
    global Boolean IsDeleted;
    global String SubType;
    global String Type;
    global String Applicant;
    global String Name;
    global Double Amount;
    global String RevenueDate;
  }

  global class ContactPointAddress {
    global String PostalCode;
    global Double Latitude;
    global String UsageType;
    global String Applicant;
    global String Name;
    global Double MonthsLivedAtCurrentAddress;
    global Double YearsLivedAtCurrentAddress;
    global String Street;
    global Boolean IsDefault;
    global Boolean IsDeleted;
    global String City;
    global Double Longitude;
    global String State;
    global Boolean IsPrimary;
    global String Country;
    global String AddressType;
  }

  global class IdentificationDocument {
    global String DocumentType;
    global String ExpirationDate;
    global String IssueDate;
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
    global String Name;
    global String EmploymentStatus;
    global String Position;
  }
}
