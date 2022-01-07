@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
global with sharing class FundingResponseMapper {
  global FinancialAccount FinancialApplication;
  global FundingResponseMapper() {
    FinancialApplication = new FinancialAccount();
  }
  global class FinancialAccount {
    global String ExternalApplicationNumber;
    global String Name;
    global String FinancialProduct;
    global String FinancialAccountType;
    global String PrimaryOwner;
    global String Ownership;
    global String Status;
    global String Stage;
    global String Application;
    global FinancialAccountTransaction FinancialApplicationTransaction;
    global FinancialAccount() {
      FinancialApplicationTransaction = new FinancialAccountTransaction();
    }
  }
  global class FinancialAccountTransaction {
    global String AccountNumber;
    global Decimal Amount;
    global String FinancialInstitute;
    global String RoutingNumber;
    global String TransactionType;
    global String TransactionStatus;
    global String AccountHolderName;
  }
}
