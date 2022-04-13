/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class AlloyServiceHelper extends AbstractService {
  @TestVisible
  private static AlloyServiceHelper serviceInstance;

  public AlloyServiceHelper() {
    super(AlloyServiceHelper.class);
  }

  /**
   * @description Provides a singleton instance of AlloyServiceHelper from which all other class methods can be accessed.
   * @author Digital Align Team | 03/31/2022
   * @return Object  singleton
   **/
  public static AlloyServiceHelper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (AlloyServiceHelper) getInstance(AlloyServiceHelper.class);
    }
    return serviceInstance;
  }

  public String buildIDVRequest(Applicant__c applicant) {
    AlloyDTO.IDVRequest idvDTO = new AlloyDTO.IDVRequest();
    Boolean isJointApplicant;
    mflow__IdentificationDocument__c identificationObj = applicant.mflow__IdentificationDocuments__r.isEmpty()
      ? new mflow__IdentificationDocument__c()
      : applicant.mflow__IdentificationDocuments__r[0];

    ContactPointAddress addresses = applicant.mflow__ContactPointAddresses__r.isEmpty()
      ? new ContactPointAddress()
      : applicant.mflow__ContactPointAddresses__r[0];

    for (ContactPointAddress add : applicant.mflow__ContactPointAddresses__r) {
      if (add.AddressType.equalsignorecase('Primary')) {
        addresses = add;
      }
    }
    idvDTO.name_first = applicant.FirstName__c;
    idvDTO.name_last = applicant.LastName__c;
    idvDTO.document_ssn = applicant.SSN__c;
    idvDTO.birth_date =
      applicant.BirthDate__c.year() +
      '-' +
      String.valueOf(applicant.BirthDate__c.month()).leftpad(2, '0') +
      '-' +
      String.valueOf(applicant.BirthDate__c.day()).leftpad(2, '0');
    idvDTO.phone_number = applicant.Phone__c;
    idvDTO.email_address = applicant.Email__c;

    //mapiing of address
    idvDTO.address_line_1 = addresses.Street;
    idvDTO.address_city = addresses.City;
    idvDTO.address_state = identificationObj.IssuedStateCode__c;
    idvDTO.address_postal_code = addresses.PostalCode;
    idvDTO.address_country_code = 'US';

    isJointApplicant = applicant.mflow__ApplicantType__c.equalsignorecase('Primary') ? false : true;
    idvDTO.ip_address_v4 = ApplicationServiceHelper.getinstance().getIpAddress();
    idvDTO.document_license = identificationObj.DocumentNumber__c;
    idvDTO.document_license_state = identificationObj.IssuedStateCode__c;
    idvDTO.meta = new AlloyDTO.Meta(applicant.IsExistingCustomer__c, isJointApplicant);

    return AlloyDTO.generateRequest(idvDTO);
  }
}
