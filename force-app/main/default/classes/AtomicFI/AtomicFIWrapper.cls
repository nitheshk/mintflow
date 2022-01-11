/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description Wrappper class for Employtment Verification Report
 **/
public with sharing class AtomicFIWrapper {
  public String borrowerId;
  public PersonalInformation personalInformation { get; set; }
  public EmploymentInformation employmentInformation { get; set; }
  public List<Account> accountList { get; set; }
  public List<W2> w2List { get; set; }
  public List<Statement> statementList { get; set; }
  public List<NetAdjustment> netAdjustmentList { get; set; }
  public String loanNumber { get; set; }
  public DateTime evaluatedDate { get; set; }

  public class PersonalInformation {
    public String firstName { get; set; }
    public String lastName { get; set; }
    public string email { get; set; }
    public DateTime dateOfBirth { get; set; }
    public String address { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String postalCode { get; set; }
    public String ssn { get; set; }
    public String phone { get; set; }
  }

  public class EmploymentInformation {
    public String employerName { get; set; }
    public String employeeType { get; set; }
    public String status { get; set; }
    public Decimal income { get; set; }
    public String incomeType { get; set; }
    public String jobTitle { get; set; }
    public String payCycle { get; set; }
    public DateTime startDate { get; set; }
  }

  public class Statement {
    public List<Deduction> deductions { get; set; }
    public String id { get; set; }
    public DateTime statementdate { get; set; }
    public Decimal grossAmount { get; set; }
    public Decimal netAmount { get; set; }
    public Paystub paystub { get; set; }
  }
  public class NetAdjustment {
    public String id { get; set; }
    public String statementdate { get; set; }
    public Integer grossAmount { get; set; }
    public Integer netAmount { get; set; }
    public Paystub paystub { get; set; }
  }

  public class Account {
    public String id { get; set; }
    public String routingNumber { get; set; }
    public String accountNumber { get; set; }
    public String type { get; set; } // in json: type
    public String distributionType { get; set; }
    public Integer distributionAmount { get; set; }
  }

  public class User {
    public String id;
    public String identifier;
  }

  public class address {
    public String line1;
    public String line2;
    public String city;
    public String state;
    public String zipcode;
  }
  public class Paystub {
    public String id { get; set; }
    public String url { get; set; }
  }
  public class W2 {
    public String id { get; set; }
    public DateTime year { get; set; }
    public decimal totalWages { get; set; }
  }

  public class Logo {
    public String url { get; set; }
  }

  public class Deduction {
    public String category { get; set; }
    public String label { get; set; }
    public Decimal Amount { get; set; }
  }
}
