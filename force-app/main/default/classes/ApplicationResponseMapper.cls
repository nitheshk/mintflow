/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description Application Response Mapper class to sum up application data
 **/
@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
global with sharing class ApplicationResponseMapper extends AbstractDTO {
  global String Description;
  global Double TotalFinancialAccounts;
  global Applicants Applicants;
  global String CleanStatus;
  global String IndividualType;
  global Boolean IsPartner;

  global class ApplicantRecords {
    global String Application;
    global Boolean IsEmailVerified;
    global String LastName;
    global Boolean IsExistingCustomer;
    global String Name;
    global Employments Employments;
    global Boolean IsPhoneNumberVerified;
    global Boolean DeleteRecord;
    global String FirstName;
    global IdentificationDocuments IdentificationDocuments;
    global ContactPointAddresses ContactPointAddresses;
    global Revenues Revenues;
  }

  global class RevenueRecords {
    global Boolean IsDeleted;
    global String SubType;
    global String Type;
    global String Applicant;
    global String Name;
    global Double Amount;
    global String RevenueDate;
  }

  global class Employments {
    global Integer totalSize;
    global Boolean done;
    global List<Records> records;
  }

  global class ContactPointAddressesRecords {
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

  global class IdentificationDocumentsRecords {
    global String DocumentType;
    global String ExpirationDate;
    global String IssueDate;
    global String DocumentNumber;
    global String Applicant;
    global String Name;
    global Boolean DeleteRecord;
    global String IssuingCountry;
  }

  global class Applicants {
    global Boolean done;
    global List<ApplicantRecords> records;
  }

  global class Records {
    global String Occupation;
    global Double AnnualIncome;
    global String Applicant;
    global String Name;
    global String EmploymentStatus;
    global String Position;
  }

  global class Revenues {
    global Integer totalSize;
    global Boolean done;
    global List<RevenueRecords> records;
  }

  global class IdentificationDocuments {
    global Integer totalSize;
    global Boolean done;
    global List<IdentificationDocumentsRecords> records;
  }

  global class ContactPointAddresses {
    global Integer totalSize;
    global Boolean done;
    global List<ContactPointAddressesRecords> records;
  }
}
