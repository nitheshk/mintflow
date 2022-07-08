/**
 * Copyright (c) 2021 Digital Align
 * @group Repository
 * @author Digital Align Team
 * @reference
 * @description Repository to fetch application object
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global inherited sharing class ApplicationRepository extends DatabaseUtils {
  /**
   * @description Read Application with child record
   * Applicants contains only ids
   * Financial Application__c contains only Ids
   * @author Digital Align Team | 10-26-2021
   * @param Id applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationWithChild(Id applicationId) {
    Query qry = Query.newInstance(Application__c.SObjectType)
      .addFields()
      .queryChild('mflow__Applicants__r')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__FinancialAccounts__r')
      .run()
      .whereEq('Id', applicationId);
    return (Application__c) DatabaseUtils.getRecord(qry.toString());
  }

  /**
   * @description Read Application with child record using application Name
   * Applicants contains only ids
   * Financial Account contains only Ids
   * @author Digital Align | 12-01-2021
   * @param string applicationNumber
   * @return Application__c
   **/
  global static Application__c readApplicationByApplicationNumber(String applicationNumber) {
    return (Application__c) DatabaseUtils.getRecord(
      Query.newInstance(Application__c.SObjectType)
        .addFields()
        .removeFields('mflow__SessionToken__c')
        .whereEq('Name', applicationNumber)
        .toString()
    );
  }

  /**
   * @description Read Application child with specified application Id And applicant Id
   * @author Digital Align Team | 11-19-2021
   * @param Id applicationId
   * @param Id applicantId
   * @return Application__c
   **/
  global static Application__c readApplicationWithChild(Id applicationId, Id applicantId) {
    Query qry = Query.newInstance(Application__c.SObjectType)
      .addFields()
      .removeFields('mflow__SessionToken__c')
      .queryChild('mflow__Applicants__r')
      .whereEq('Id', applicantId)
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__FinancialAccounts__r')
      .run()
      .whereEq('Id', applicationId);
    return (Application__c) DatabaseUtils.getRecord(qry.toString());
  }

  /**
   * @description Read Application for session token verification
   * @author Digital Align Team | 11-17-2021
   * @param Id applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationForToken(Id applicationId) {
    return (Application__c) DatabaseUtils.getRecord(
      Query.newInstance(Application__c.SObjectType)
        .addFields('SessionToken__c,Name')
        .whereEq('Id', applicationId)
        .toString()
    );
  }

  /**
   * @description Read application with Applicants
   * @author Digital Align Team | 11-15-2021
   * @param Id applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationWithApplicants(Id applicationId) {
    return (Application__c) DatabaseUtils.getRecord(
      Query.newInstance(Application__c.SObjectType)
        .addFields()
        .queryChild('mflow__Applicants__r')
        .addFields()
        .addFields('RecordType.Name')
        .orderBy('mflow__Order__c')
        .run()
        .whereEq('Id', applicationId)
        .toString()
    );
  }

  /**
   * @description get auth provider is existing or not
   * @author Digital Align Team | 12-08-2021
   * @param String developerName
   * @return AuthProvider
   **/
  global static AuthProvider readAuthProviderByDevName(String developerName) {
    return (AuthProvider) DatabaseUtils.getRecord(
      Query.newInstance(AuthProvider.SObjectType).whereEq('DeveloperName', developerName).toString()
    );
  }

  /**
   * @description Read Application With Primary
   * @author Digital Align Team | 02-04-2022
   * @param Id applicationId
   * @return Application__c
   **/
  // global static Application__c readApplicationWithPrimary(Id applicationId) {
  //   return (Application__c) DatabaseUtils.getRecord(
  //     Query.newInstance(Application__c.SObjectType)
  //       .addFields()
  //       .queryChild('mflow__Applicants__r')
  //       .addFields()
  //       .addFields('RecordType.Name')
  //       .whereEq('RecordType.Name', ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE)
  //       .run()
  //       .whereEq('Id', applicationId)
  //       .toString()
  //   );
  // }
  /**
   * @description Read Application with child record
   * Applicants contains only ids
   * Financial Account contains only Ids
   * @author Digital Align Team | 10-26-2021
   * @param Id applicationId
   * @return Application__c
   **/
  global static Application__c readApplicationToClone(Id applicationId) {
    Query qry = Query.newInstance(Application__c.SObjectType)
      .addFieldSet('mflow__CloneApplication')
      .whereEq('Id', applicationId);
    return (Application__c) DatabaseUtils.getRecord(qry.toString());
  }

  /**
   * @description read  applicant with child record
   * @author Digital Align Team | 10-26-2021
   * @param Applicant__c applicantId
   **/
  global static List<Applicant__c> readApplicantsToClone(Id applicationId) {
    Query qry = Query.newInstance(Applicant__c.SObjectType)
      .addFieldSet('mflow__CloneApplicant')
      .addFields('RecordType.Name')
      .queryChild('mflow__IdentificationDocuments__r')
      .addFieldSet('mflow__CloneIdentification')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__ContactPointAddresses__r')
      .addFieldSet('mflow__CloneAddress')
      .removeFields('Address')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__Employments__r')
      .addFieldSet('mflow__CloneEmployment')
      .orderBy('mflow__Order__c')
      .run()
      .whereEq('Application__c', applicationId)
      .andCon()
      .whereNeq('RecordType.Name', ApplicationConstant.APPLICANT_FAMILY_MEMBER_RECORDTYPE);
    return (List<Applicant__c>) DatabaseUtils.getRecords(qry.toString());
  }

  /**
   * @description read  applicant with child record
   * @author Digital Align Team | 10-26-2021
   * @param Applicant__c applicantId
   **/
  global static List<Applicant__c> readPrimaryApplicantsToClone(Id applicationId) {
    Query qry = Query.newInstance(Applicant__c.SObjectType)
      .addFieldSet('mflow__CloneApplicant')
      .addFields('RecordType.Name')
      .queryChild('mflow__IdentificationDocuments__r')
      .addFieldSet('mflow__CloneIdentification')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__ContactPointAddresses__r')
      .addFieldSet('mflow__CloneAddress')
      .removeFields('Address')
      .orderBy('mflow__Order__c')
      .run()
      .queryChild('mflow__Employments__r')
      .addFieldSet('mflow__CloneEmployment')
      .orderBy('mflow__Order__c')
      .run()
      .whereEq('Application__c', applicationId)
      .andCon()
      .whereeq('RecordType.Name', ApplicationConstant.APPLICANT_PRIMARY_RECORDTYPE);
    return (List<Applicant__c>) DatabaseUtils.getRecords(qry.toString());
  }

  /**
   * @description To get Lead configuration information
   * @author Digital Align Team | 10-26-2021
   * @param Map<String,String>
   **/
  global static List<LeadConfiguration__c> fetchLeadConfiguration(Map<String, String> filterValue) {
    Query qry = Query.newInstance(LeadConfiguration__c.SObjectType)
      .addFields()
      .whereEq('Type__c', filterValue.get('Type'));
    if (filterValue.get('Value') != null) {
      qry.andCon().whereEq('Value__c', filterValue.get('Value'));
    }
    if (filterValue.containsKey('Category')) {
      qry.andCon().whereEq('ProductCategory__c', filterValue.get('Category'));
    }
    return (List<LeadConfiguration__c>) DatabaseUtils.getRecords(qry.toString(true));
  }

  /**
   * @description To get Customer Interest of an application
   * @author Digital Align Team | 10-26-2021
   * @param Id
   **/
  global static List<mflow__CustomerInterest__c> readCustomerInterestbyApplication(Id applicationId) {
    Query qry = Query.newInstance(mflow__CustomerInterest__c.SObjectType)
      .addFields()
      .queryLookup('mflow__Application__r')
      .run()
      .whereEq('mflow__Application__c', applicationId);
    return (List<mflow__CustomerInterest__c>) DatabaseUtils.getRecords(qry.toString());
  }

  /**
   * @description
   * @author Digital Align Team | 06-29-2022
   * @param String lastName
   * @param String ssn
   * @return Contact
   **/
  global static Contact readMemberContact(String lastName, String ssn) {
    Query qry = Query.newInstance(Contact.SObjectType)
      .addFields()
      .whereEq('LastName', lastName)
      .andCon()
      .whereEq('SSN__c', ssn)
      .andCon()
      .whereNeq('MemberNumber__c', null)
      .addLimit(1)
      .orderBy('CreatedDate', true);
    return (Contact) DatabaseUtils.getRecord(qry.toString());
  }

  /**
   * @description
   * @author Digital Align Team | 06-30-2022
   * @param Id ContactId
   * @return Application__c
   **/
  global static Application__c fetchLastSubmittedApplication(Id contactId) {
    Query qry = Query.newInstance(Application__c.SObjectType)
      .addFields()
      .whereIn(
        'Id',
        Query.newInstance(Applicant__c.SObjectType)
          .addFields('mflow__Application__c')
          .whereEq('mflow__Contact__c', contactId)
          .andCon()
          .whereEq('mflow__Status__c', ApplicationConstant.COMPLETED)
          .toString()
      )
      .andCon()
      .whereEq('mflow__Status__c', ApplicationConstant.COMPLETED)
      .orderBy('CreatedDate', true)
      .addLimit(1);

    return (Application__c) DatabaseUtils.getRecord(qry.toString());
  }
}
