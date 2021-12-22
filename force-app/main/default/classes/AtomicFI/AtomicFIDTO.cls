/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description AtomicFIDTO
 **/

@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
global with sharing class AtomicFIDTO {
  global String eventType { get; set; }
  global DateTime eventTime { get; set; }
  global String product { get; set; }
  global Company company { get; set; }
  global employer employer { get; set; }
  global data data { get; set; }
  global User user { get; set; }
  global String identifier { get; set; }
  global String applicantId { get; set; }

  global String expiry;
  global String task;
  global Identity identity { get; set; }

  global List<name> names;
  global List<account> accounts;
  global List<address> addresses;

  global class name {
    global String firstName;
    global String middleName;
    global String lastName;
  }

  global class outputs {
    global Decimal income;
    global String incomeType;
    global String employeeType;
    global String employmentStatus;
    global String jobTitle;
    global DateTime startDate;
    global Integer weeklyHours;
    global String firstName;
    global String lastName;
    global DateTime dateOfBirth;
    global String email;
    global String phone;
    global String ssn;
    global String address;
    global String city;
    global String state;
    global String postalCode;
    global String payCycle;
    //global String IdentificationNumber;
    global list<statements> statements;
    global list<w2s> w2s;
    global list<account> accounts;
  }

  global class statements {
    global List<Deductions> deductions { get; set; }
    global String id { get; set; }
    global DateTime statementdate { get; set; }
    global Decimal grossAmount { get; set; }
    global Decimal netAmount { get; set; }
    global Paystub paystub { get; set; }
  }

  global class deductions {
    global String category { get; set; }
    global String label { get; set; }
    global Decimal amount { get; set; }
  }
  global class Account {
    global String id { get; set; }
    global String routingNumber { get; set; }
    global String accountNumber { get; set; }
    global String type { get; set; } // in json: type
    global String distributionType { get; set; }
    global Integer distributionAmount { get; set; }
  }
  global class Branding {
    global Logo logo { get; set; }
  }

  global class User {
    global String id;
    global String identifier;
  }

  global class address {
    global String line1;
    global String line2;
    global String city;
    global String state;
    global String zipcode;
    global String country;
  }
  global class Paystub {
    global String id { get; set; }
    global String url { get; set; }
  }
  global class w2s {
    global String id { get; set; }
    global DateTime year { get; set; }
    global Decimal totalWages { get; set; }
    global form form { get; set; }
  }
  global class form {
    global String id { get; set; }
    global String url { get; set; }
  }

  global class Company {
    global String name { get; set; }
    global Branding branding { get; set; }
  }
  global class Data {
    global String previousStatus { get; set; }
    global String status { get; set; }
    global Boolean authenticated { get; set; }
    global Outputs outputs { get; set; }
  }
  global class Identity {
    global String identificationNumber { get; set; }
    global String dateOfBirth { get; set; }
    global String issueDate { get; set; }
    global String expiryDate { get; set; }
    global String stateIssued { get; set; }
    global String countryIssued { get; set; }
  }

  global class employer {
    global String employerName { get; set; }
    global String City { get; set; }
    global String State { get; set; }
  }

  global class Logo {
    global String url { get; set; }
  }
  global static AtomicFIDTO parse(String json) {
    return (AtomicFIDTO) System.JSON.deserialize(json, AtomicFIDTO.class);
  }
}