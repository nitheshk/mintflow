/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class IdentityService extends AbstractService {
  @TestVisible
  private static IdentityService serviceInstance;

  public IdentityService() {
    super(IdentityService.class);
  }
  /**
   * @description Provides a singleton instance of IdentityService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static IdentityService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (IdentityService) getInstance(IdentityService.class);
    }
    return serviceInstance;
  }

  /**
   * @description
   * @author Digital Align Team | 10-13-2021
   * @param Map<String String> params
   * @return Object
   **/
  global virtual Object verifyCounty(Map<String, Object> params) {
    string zipcode = (string) params.get('zipcode');
    if (string.isBlank(zipcode) && params != null) {
      throw new CustomException('Zipcode value notset');
    }
    return (GeocodingProvider.getInstance().invokeAPI(params));
  }
  /**
   * @description
   * @author Digital Align | 10-26-2021
   * @param Map<String object> params
   * @return virtual
   **/
  global virtual Object scanDL(Map<String, object> params) {
    dau01__Applicant__c applicant = new dau01__Applicant__c();
    string contentDocumentId = (string) params.get('contentDocumentId');
    ContentVersion cv = FileService.getInstance()
      .fetchContentVersionByCD(contentDocumentId, false);
    if (cv != null) {
      Map<String, object> res = DocumentScanAdapter.invokeAPI(
        new Map<String, Object>{ 'file' => cv.VersionData }
      );
      system.debug('res ==== ' + res);
      if (res.get('Status') == 200) {
        IDScanDTO.Response reponse = (IDScanDTO.Response) JSON.deserialize(
          (string) res.get('Data'),
          IDScanDTO.Response.class
        );
        applicant.dau01__FirstName__c = reponse.result.firstName;
        // applicant.dau01__MiddleName__c = reponse.result.middleName;
        // applicant.dau01__LastName__c = reponse.result.lastName;
        // applicant.dau01__Birthdate__c = reponse.result.dob;
        // applicant.FinServ__IdentificationDocument__r.FinServ__ExpirationDate__c = reponse.result.expiry;
        // applicant.FinServ__IdentificationDocument__r.FinServ__DocumentType__c = reponse.result.documentType;
        // applicant.FinServ__IdentificationDocument__r.FinServ__DocumentNumber__c = reponse.result.documentNumber;
        // applicant.FinServ__IdentificationDocument__r.FinServ__IssuingCountry__c = reponse.result.issuerOrg_iso3;
        // applicant.FinServ__IdentificationDocument__r.FinServ__IssueDate__c = reponse.result.issued;
        // applicant.FinServ__IdentificationDocument__r.dau01__Nationality__c = reponse.result.nationality_full;
        // applicant.FinServ__IdentificationDocument__r.FinServ__SourceSystemId__c = reponse.responseID;
        // applicant.ContactPointAddress.Street =
        //   reponse.result.address1 + reponse.result.address2;
        // applicant.ContactPointAddress.PostalCode = reponse.result.postcode;
      }
    }
    return 'success';
  }
}
