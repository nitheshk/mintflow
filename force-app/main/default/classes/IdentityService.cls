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
    return new Map<String, Object>{ 'County' => 'Idaho' };
  }
  global virtual Object scanDL(Map<String, object> params) {
    dau01__Applicant__c applicant = new dau01__Applicant__c();
    string contentDocumentId = (string) params.get('contentDocumentId');
    ContentVersion cv = FileService.getInstance()
      .fetchContentVersionByCD(contentDocumentId, false);
    if (cv != null) {
      Map<String, object> res = DocumentScanAdapter.invokeAPI(
        new Map<String, Object>{ 'file' => cv.VersionData }
      );
      if (res.get('Status') == 200) {
        IDScanDTO.Response reponse = (IDScanDTO.Response) JSON.deserialize(
          (string) res.get('Data'),
          IDScanDTO.Response.class
        );
      }

      //dau01__Applicant__c.dau01__Birthdate__c
      //dau01__Applicant__c.dau01__FirstName__c
      //dau01__Applicant__c.dau01__MiddleName__c
      //dau01__Applicant__c.dau01__LastName__c
      //FinServ__IdentificationDocument__c.FinServ__ExpirationDate__c
      //FinServ__IdentificationDocument__c.FinServ__DocumentType__c
      //FinServ__IdentificationDocument__c.	FinServ__DocumentNumber__c
      //FinServ__IdentificationDocument__c.FinServ__IssuingCountry__c
      //FinServ__IdentificationDocument__c.FinServ__IssueDate__c
      //FinServ__IdentificationDocument__c.dau01__Nationality__c
      //FinServ__IdentificationDocument__c.FinServ__SourceSystemId__c
      // ContactPointAddress.Street
      // ContactPointAddress.PostalCode
    }
    return 'success';
  }
}
