/**
 * Copyright (c) 2021 Digital Align
 * @group helper
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class IdentityServiceHelper extends AbstractService {
  @TestVisible
  private static IdentityServiceHelper serviceInstance;

  public IdentityServiceHelper() {
    super(IdentityServiceHelper.class);
  }
  /**
   * @description Provides a singleton instance of IdentityServiceHelper from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static IdentityServiceHelper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (IdentityServiceHelper) getInstance(
        IdentityServiceHelper.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description Parse document response into applicant object
   * @author Digital Align Team | 11-01-2021
   * @param dau01__Applicant__c applicant
   * @param DocumentScanDTO.Response returnDTO
   * @return Applicant__c
   **/
  global Applicant__c mapIdentityResponse(
    dau01__Applicant__c applicant,
    DocumentScanDTO.Response returnDTO
  ) {
    FinServ__IdentificationDocument__c identity = new FinServ__IdentificationDocument__c();
    ContactPointAddress idAddress = new ContactPointAddress();

    applicant.dau01__FirstName__c = returnDTO.data.firstName;
    applicant.dau01__LastName__c = returnDTO.data.lastName;
    applicant.dau01__Birthdate__c = DateUtils.formatStringToDate1(
      returnDTO.data.dob
    );
    identity.dau01__Height__c = returnDTO.data.height;
    identity.dau01__IssuedRegion__c = returnDTO.data.issuerRegion;
    identity.dau01__Weight__c = returnDTO.data.weight;
    identity.dau01__Gender__c = returnDTO.data.gender;
    identity.FinServ__DocumentType__c = returnDTO.data.documentType;
    identity.FinServ__DocumentNumber__c = returnDTO.data.documentNumber;
    identity.FinServ__IssuingCountry__c = returnDTO.data.issuerCountry;
    identity.dau01__Nationality__c = returnDTO.data.nationality;
    identity.FinServ__ExpirationDate__c = DateUtils.formatStringToDate1(
      returnDTO.data.expiry
    );
    identity.FinServ__IssueDate__c = DateUtils.formatStringToDate1(
      returnDTO.data.issued
    );
    idAddress.Street = returnDTO.data.address1 + ' ' + returnDTO.data.address2;
    idAddress.PostalCode = returnDTO.data.postalCode;

    dau01.SObjectConstructor construct = dau01.SObjectConstructor.getInstance(
      applicant
    );
    construct.setChildObjects(
      'dau01__ContactPointAddresses__r',
      new List<ContactPointAddress>{ idAddress }
    );
    construct.setChildObjects(
      'dau01__IdentificationDocuments__r',
      new List<finServ__IdentificationDocument__c>{ identity }
    );
    applicant = (dau01__Applicant__c) construct.build();
    return applicant;
  }
}
