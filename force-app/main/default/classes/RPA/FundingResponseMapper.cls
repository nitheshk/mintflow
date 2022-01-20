@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
global with sharing class FundingResponseMapper {
  global String ExternalApplicationNumber;
  global List<FinancialAccount> FinancialApplication;
  global String Application;
  global String Status;
  global String Stage;
  global String Password;
  global FundingResponseMapper() {
    FinancialApplication = new List<FinancialAccount>();
  }
  global class FinancialAccount {
    global String Name;
    global String FinancialProduct;
    global String FinancialAccountType;
    global String PrimaryOwner;
    global String Ownership;
    global List<FinancialAccountTransaction> FinancialApplicationTransaction;
    global FinancialAccount() {
      FinancialApplicationTransaction = new List<FinancialAccountTransaction>();
    }
  }
  global class FinancialAccountTransaction {
    global Date TransactionDate;
    global String AccountNumber;
    global Decimal Amount;
    global String FinancialInstitute;
    global String RoutingNumber;
    global String TransactionType;
    global String TransactionStatus;
    global String AccountHolderName;
  }
}
