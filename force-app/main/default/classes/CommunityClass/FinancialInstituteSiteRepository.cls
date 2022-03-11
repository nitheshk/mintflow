/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
public with sharing class FinancialInstituteSiteRepository extends DatabaseUtils {
  /**
   * @description fetch account by account Id
   * @author Digital Align | 07-23-2021
   * @param string accountId
   * @return Account
   **/
  public static Account fetchAccountById(String accountId) {
    return (Account) getRecord(
      Query.newInstance(account.SObjectType).addFields().removeMergedFields().whereEq('Id', accountId).toString(true)
    );
  }
}
