/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description Repository to fetch account related data
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class UserAccountManagementRepository extends DatabaseUtils {
  /**
   * @description
   * @author Digital Align Team | 07-14-2021
   * @param String profileName
   * @return Profile
   **/
  global static Profile readProfileByName(String profileName) {
    return (Profile) getRecord(
      Query.newInstance(Profile.SObjectType)
        .whereEq('Name', profileName)
        .addLimit(1)
        .toString(true)
    );
  }

  /**
   * @description
   * @author Digital Align Team | 07-14-2021
   * @param List<String> permissionSetNames
   * @return List<PermissionSet>
   **/
  global static List<PermissionSet> readPermissionSetByNames(
    List<String> permissionSetNames
  ) {
    return (List<PermissionSet>) getRecords(
      Query.newInstance(PermissionSet.SObjectType)
        .whereIn('Name', permissionSetNames)
        .toString(true)
    );
  }

  /**
   * @description
   * @author Digital Align Team | 07-14-2021
   * @param Id leadId
   * @return Lead
   **/
  global static Lead fetchLeadById(Id leadId) {
    return (Lead) getRecord(
      Query.newInstance(Lead.SObjectType).addFields().queryById(leadId)
    );
  }

  /**
   * @description
   * @author Digital Align Team | 07-15-2021
   * @return LeadStatus
   **/
  global static LeadStatus fetchLeadStatus() {
    return (LeadStatus) getRecord(
      Query.newInstance(LeadStatus.SObjectType)
        .addFields('MasterLabel')
        .whereEq('IsConverted', true)
        .addLimit(1)
        .toString()
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
