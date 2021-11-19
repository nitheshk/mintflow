/**
 * Copyright (c) 2021 Digital Align
 * @group Test
 * @author Digital Align Team
 **/
@isTest
public with sharing class TestData {
  public static Account createAccount() {
    Account acc = new Account();
    acc.Name = 'Account Name';
    return acc;
  }

  public static Opportunity createOpportunity(Account acc) {
    Opportunity opp = new Opportunity();
    if (acc != null) {
      opp.AccountId = acc.id;
    }
    opp.Name = 'Opp Name';
    opp.StageName = 'Closed Won';
    opp.Probability = 95;
    opp.CloseDate = system.today();
    return opp;
  }

  public static contact createContact(Account acc) {
    Contact con = new Contact();
    if (acc != null) {
      con.AccountId = acc.id;
    }
    con.FirstName = 'FirstName';
    con.LastName = 'LastName';
    return con;
  }

  public static OpportunityContactRole createOpportunityContactRole(
    Opportunity opp,
    Contact con
  ) {
    OpportunityContactRole ocr = new OpportunityContactRole();
    ocr.ContactId = con.Id;
    ocr.OpportunityId = opp.Id;
    ocr.IsPrimary = true;
    ocr.Role = 'Decision Maker';
    return ocr;
  }

  public static Applicant__c createApplicant(id accId) {
    Applicant__c applicant = new Applicant__c();
    applicant.Application__c = accId;
    applicant.FirstName__c = 'John';
    applicant.LastName__c = 'Doe';
    applicant.EmailOtp__c = '4567';
    applicant.ApplicantType__c = 'Primary';
    applicant.MembershipAccountNumber__c = '569856';
    applicant.CustomerNumber__c = '578784';
    return applicant;
  }
  public static ContactPointAddress createContactPointAddress() {
    ContactPointAddress address = new ContactPointAddress();
    address.Name = 'Add-001';
    address.IsPrimary = true;
    address.Street = 'street one';
    address.City = 'CA';
    address.State = 'CA';
    address.Country = 'USA';
    address.PostalCode = '10001';
    return address;
  }

  public static ApplicationConfiguration__c createApplicationConfiguration() {
    ApplicationConfiguration__c appConfig = new ApplicationConfiguration__c();
    appConfig.AllowedOtpMode__c = 'SMS';
    appConfig.EmailLinkExpirationTime__c = 2;
    appConfig.OTPExpirationTime__c = 3;
    appConfig.OTPMaxAllowedAttempts__c = 5;
    appConfig.SentiLink__c = true;
    appConfig.SesssionExpirationTime__c = 2;
    return appConfig;
  }
}
