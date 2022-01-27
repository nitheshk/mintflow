@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
global with sharing class FundingSubmissionResponse {
  global String ExternalApplicationNumber;
  global List<FinancialAccount> FinancialAccount;
  global String Application;
  global String Status;
  global String Stage;
  global String Password;
  global FundingSubmissionResponse() {
    FinancialAccount = new List<FinancialAccount>();
  }
  global class FinancialAccount {
    global String FinancialAccountId;
    global String Name;
    global String FinancialProduct;
    global String FinancialAccountType;
    global String PrimaryOwner;
    global String Ownership;
    global FinancialAccountTransaction FinancialApplicationTransaction;
    global FinancialAccount() {
      FinancialApplicationTransaction = new FinancialAccountTransaction();
    }
  }
  global class FinancialAccountTransaction {
    global String FinancialAccountTransactionId;
    global Date TransactionDate;
    global string InstitutionState;
    global String AccountNumber;
    global Decimal Amount;
    global String FinancialInstitute;
    global String RoutingNumber;
    global String TransactionType;
    global String TransactionStatus;
    global String AccountHolderName;
  }

  /** Funding Response */
  global class FundingResult {
    global String ExternalApplicationNumber;
    global String ExternalApplicationStatus;
    global String MemberNumber;
    global String Application;
    global List<FinancialAccountResult> FinancialAccount;
  }

  global class FinancialAccountResult {
    global String FinancialAccountId;
    global String AccountNumber;
    global FinancialTransactionResult FinancialApplicationTransaction;
  }

  global class FinancialTransactionResult {
    global String FinancialAccountTransactionId;
    global String TransactionStatus;
  }
}
