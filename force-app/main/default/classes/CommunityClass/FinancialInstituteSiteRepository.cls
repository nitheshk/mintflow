/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description
 **/
global with sharing class FinancialInstituteSiteRepository extends DatabaseUtils {
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

  /**
   * @description
   * @author Digital Align Team | 07-14-2021
   * @param String profileName
   * @return Profile
   **/
  global static Profile readProfileByName(String profileName) {
    return (Profile) getRecord(
      Query.newInstance(Profile.SObjectType).whereEq('Name', profileName).addLimit(1).toString(true)
    );
  }

  /**
   * @description
   * @author Digital Align Team | 07-14-2021
   * @param List<String> permissionSetNames
   * @return List<PermissionSet>
   **/
  global static List<PermissionSet> readPermissionSetByNames(List<String> permissionSetNames) {
    return (List<PermissionSet>) getRecords(
      Query.newInstance(PermissionSet.SObjectType).whereIn('Name', permissionSetNames).toString(true)
    );
  }

  /**
   * @description fetch contact and account by contact id
   * @author Digital Align Team | 07-15-2021
   * @param Id contactId
   * @return Contact
   **/
  global static Contact fetchContactAccountById(Id contactId) {
    return (Contact) getRecordByStrip(
      Query.newInstance(Contact.SObjectType)
        .addFields()
        .QueryLookup('Account')
        .addFields('Name') //.removeMergedFields()
        .run()
        .queryById(contactId)
    );
  }
}
