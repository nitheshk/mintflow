/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description AtomicFI Verification Report Controller
 **/
public with sharing class AtomicVerificationReportController {
  public static AtomicFIDTO atomicResponse { get; set; }
  public static AtomicFIWrapper atomicWrapper { get; set; }
  public static String employerName { get; set; }
  /**
   * @description get Verified employment data
   * @author Digital Align Team | 11/11/2021
   **/
  public static void getVerifiedData() {
    String employerId = Apexpages.currentPage().getparameters().get('id');
    system.debug(' employer id::' + employerId);
    PrefillEmploymentData(employerId);
  }

  /**
   * @description Prefill Employment Data
   * @author Digital Align Team | 11/11/2021
   * @return Object  AtomicFIDTO
   **/
  public static void PrefillEmploymentData(String employerId) {
    atomicResponse = new AtomicFIDTO();
    atomicWrapper = new AtomicFIWrapper();
    Employment__c empObj = EmploymentRepository.readEmployerbyId(employerId);
    employerName = empObj.Name;
    String jsonResponse = AtomicFIProvider.getInstance()
      .getAtomicResponse(empObj.ApplicantTemp__c, employerId);
    String request = jsonResponse.replaceAll('_id', 'id');
    jsonResponse = request;
    request = jsonResponse.replace('\\n', '');
    jsonResponse = request;
    request = jsonResponse.replace('"date"', '"statementdate"');
    jsonResponse = request;
    atomicResponse = AtomicFIDTO.parse(jsonResponse);
    atomicWrapper.evaluatedDate = atomicResponse.eventTime;
    atomicWrapper.loanNumber = empObj.ApplicantTemp__r.Application__r.Name;
    System.debug('loan number' + atomicWrapper.loanNumber);
    prefillPersonalInformationData();
    prefillEmploymentInformationData();
    prefillAccountsInformation();
    prefillW2sInformation();
    prefillStatementsInformation();
  }

  public static void prefillPersonalInformationData() {
    AtomicFIWrapper.PersonalInformation wrapperpersonalInformation = new AtomicFIWrapper.PersonalInformation();
    wrapperpersonalInformation.firstName = atomicResponse.data.outputs.firstName;
    wrapperpersonalInformation.lastName = atomicResponse.data.outputs.lastName;
    wrapperpersonalInformation.email = atomicResponse.data.outputs.email;
    wrapperpersonalInformation.dateOfBirth = atomicResponse.data.outputs.dateOfBirth;
    wrapperpersonalInformation.address = atomicResponse.data.outputs.address;
    wrapperpersonalInformation.city = atomicResponse.data.outputs.city;
    wrapperpersonalInformation.state = atomicResponse.data.outputs.state;
    wrapperpersonalInformation.postalCode = atomicResponse.data.outputs.postalCode;
    wrapperpersonalInformation.phone = atomicResponse.data.outputs.phone;
    wrapperpersonalInformation.ssn = atomicResponse.data.outputs.ssn;
    atomicWrapper.personalInformation = wrapperpersonalInformation;
  }

  public static void prefillEmploymentInformationData() {
    AtomicFIWrapper.EmploymentInformation employmentInformation = new AtomicFIWrapper.EmploymentInformation();
    employmentInformation.employerName = employerName;
    employmentInformation.employeeType = atomicResponse.data.outputs.employeeType;
    employmentInformation.status = atomicResponse.data.outputs.employmentStatus;
    employmentInformation.income = atomicResponse.data.outputs.income;
    employmentInformation.incomeType = atomicResponse.data.outputs.incomeType;
    employmentInformation.jobTitle = atomicResponse.data.outputs.jobTitle;
    employmentInformation.payCycle = atomicResponse.data.outputs.payCycle;
    employmentInformation.startDate = atomicResponse.data.outputs.startDate;
    atomicWrapper.employmentInformation = employmentInformation;
  }

  public static void prefillAccountsInformation() {
    List<AtomicFIWrapper.Account> listAccounts = new List<AtomicFIWrapper.Account>();
    List<AtomicFIDTO.Account> listDTOAccountList = new List<AtomicFIDTO.Account>();
    AtomicFIWrapper.Account wrapperAccoutObj;
    listDTOAccountList = atomicResponse.data.outputs.accounts;
    System.debug('listDTOAccountList::' + listDTOAccountList);
    for (AtomicFIDTO.Account acntObj : listDTOAccountList) {
      wrapperAccoutObj = new AtomicFIWrapper.Account();
      wrapperAccoutObj.accountNumber = acntObj.accountNumber;
      wrapperAccoutObj.routingNumber = acntObj.routingNumber;
      wrapperAccoutObj.type = acntObj.type;
      wrapperAccoutObj.distributionAmount = acntObj.distributionAmount;
      wrapperAccoutObj.distributionType = acntObj.distributionType;
      listAccounts.add(wrapperAccoutObj);
    }
    atomicWrapper.accountList = listAccounts;
  }

  public static void prefillW2sInformation() {
    List<AtomicFIWrapper.W2> listW2s = new List<AtomicFIWrapper.W2>();
    List<AtomicFIDTO.w2s> listDTOW2List = new List<AtomicFIDTO.w2s>();
    AtomicFIWrapper.W2 wrapperW2Obj;
    listDTOW2List = atomicResponse.data.outputs.w2s;
    System.debug('listDTOW2List::' + listDTOW2List);
    for (AtomicFIDTO.w2s w2Obj : listDTOW2List) {
      wrapperW2Obj = new AtomicFIWrapper.W2();
      wrapperW2Obj.year = w2Obj.year;
      wrapperW2Obj.totalWages = w2Obj.totalWages;
      listW2s.add(wrapperW2Obj);
    }
    atomicWrapper.w2List = listW2s;
  }

  public static void prefillStatementsInformation() {
    List<AtomicFIWrapper.Statement> listStatements = new List<AtomicFIWrapper.Statement>();
    List<AtomicFIDTO.statements> listDTOStatementList = new List<AtomicFIDTO.statements>();
    List<AtomicFIWrapper.Deduction> listDeductions = new List<AtomicFIWrapper.Deduction>();
    List<AtomicFIDTO.deductions> listDTODeductionList = new List<AtomicFIDTO.deductions>();

    AtomicFIWrapper.Statement wrapperStatementObj;
    AtomicFIWrapper.Deduction wrapperDeductionObj;

    listDTOStatementList = atomicResponse.data.outputs.statements;
    System.debug('listDTOStatementList::' + listDTOStatementList);
    for (AtomicFIDTO.statements stateObj : listDTOStatementList) {
      wrapperStatementObj = new AtomicFIWrapper.Statement();
      listDeductions = new List<AtomicFIWrapper.Deduction>();

      wrapperStatementObj.grossAmount = stateObj.grossAmount;
      wrapperStatementObj.netAmount = stateObj.netAmount;
      wrapperStatementObj.statementdate = stateObj.statementdate;
      listStatements.add(wrapperStatementObj);

      listDTODeductionList = stateObj.deductions;
      System.debug('listDTODeductionList::' + listDTODeductionList);
      for (AtomicFIDTO.deductions deductObj : listDTODeductionList) {
        wrapperDeductionObj = new AtomicFIWrapper.Deduction();
        wrapperDeductionObj.category = deductObj.category;
        wrapperDeductionObj.amount = deductObj.amount;
        wrapperDeductionObj.label = deductObj.label;
        listDeductions.add(wrapperDeductionObj);
      }
      wrapperStatementObj.deductions = listDeductions;
    }
    atomicWrapper.statementList = listStatements;
  }
}
