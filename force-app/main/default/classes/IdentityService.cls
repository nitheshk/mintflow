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
   * @description verify county eligibility
   * Pass "zipcode" as parameter
   * @author Digital Align Team | 10-13-2021
   * @param Map<String String> params
   * @return Object
   **/
  global virtual Object verifyCounty(Map<String, Object> params) {
    Flow.initialize(ApexRequest.getApplicationId());
    Flow.setFlow('EligibilityFlow');
    Flow.setSubFlow(APINames.Geocoding.name());
    try {
      string zipcode = (string) params.get('zipcode');
      if (string.isBlank(zipcode) && params != null) {
        throw new CustomException('Zipcode value not set');
      }
      if (HttpBuilder.isActiveApiSetting(APINames.Geocoding)) {
        HttpBuilder.setAPISetting(APINames.Geocoding);
        HttpBuilder.replaceEndpoint(
          '{APIKey}',
          HttpBuilder.getApiConstant('GeocodingAPIKey')
        );
        HttpBuilder.replaceEndpoint(
          '{Pincode}',
          (string) params.get('zipcode')
        );
        HttpBuilder.Response response = GeocodingProvider.getInstance()
          .validateCountyUsingGoogleApi(params);
        flow.setSubFlowPassed(response.status);
        flow.setFlowPassed('Completed');
        return response.data;
      } else {
        throw new CustomException('Requested API is disabled');
      }
    } catch (Exception ex) {
      flow.setSubFlowFailed(ex.getMessage());
      flow.setFlowFailed('Failed');
      throw ex;
    }
  }
  /**
   * @description Document Scan functionality for identity verify
   * @author Digital Align | 10-26-2021
   * @param Map<String object> params
   * @return  Applicant__c
   **/
  global virtual Applicant__c scanIdentityDocument(Map<String, object> params) {
    Flow.initialize(ApexRequest.getApplicationId());
    Flow.setFlow('IdentityFlow');
    Flow.setSubFlow(APINames.IdScanAnalyzer);
    try {
      string contentDocumentId = (string) params.get('contentDocumentId');
      ContentVersion cv = FileService.getInstance()
        .fetchContentVersionByCD(contentDocumentId, false);
      if (cv == null) {
        throw new CustomException('Document Not Found');
      }
      params.put('frontContentVersion', cv);

      if (HttpBuilder.isActiveApiSetting(APINames.IdScanAnalyzer)) {
        HttpBuilder.setAPISetting(APINames.IdScanAnalyzer);
        HttpBuilder.Response response = DocumentScanProvider.getInstance()
          .idScanAnalyzer(params);

        dau01__Applicant__c applicant = new dau01__Applicant__c();
        FinServ__IdentificationDocument__c identity = new FinServ__IdentificationDocument__c();
        ContactPointAddress idAddress = new ContactPointAddress();
        DocumentScanDTO.Response returnDTO = (DocumentScanDTO.Response) response.data;
        applicant.dau01__FirstName__c = returnDTO.data.firstName;
        applicant.dau01__LastName__c = returnDTO.data.lastName;
        applicant.dau01__Birthdate__c = getDateFromString(returnDTO.data.dob);
        identity.dau01__Height__c = returnDTO.data.height;
        identity.dau01__IssuedRegion__c = returnDTO.data.issuerRegion;
        identity.dau01__Weight__c = returnDTO.data.weight;
        identity.dau01__Gender__c = returnDTO.data.gender;
        identity.FinServ__DocumentType__c = returnDTO.data.documentType;
        identity.FinServ__DocumentNumber__c = returnDTO.data.documentNumber;
        identity.FinServ__IssuingCountry__c = returnDTO.data.issuerCountry;
        identity.dau01__Nationality__c = returnDTO.data.nationality;
        identity.FinServ__ExpirationDate__c = getDateFromString(
          returnDTO.data.expiry
        );
        identity.FinServ__IssueDate__c = getDateFromString(
          returnDTO.data.issued
        );
        idAddress.Street =
          returnDTO.data.address1 +
          ' ' +
          returnDTO.data.address2;
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
        log?.debug('ScanDL Response : ' + Json.Serialize(applicant));

        flow.setSubFlowPassed(response.status);
        flow.setFlowPassed('Completed');
        return applicant;
      } else {
        throw new CustomException('Requested API is disabled');
      }
    } catch (Exception ex) {
      flow.setSubFlowFailed(ex.getMessage());
      flow.setFlowFailed('Failed');
      throw ex;
    }
  }
  /**
   * @description
   * @author Digital Align | 10-30-2021
   * @param string datestring
   * @return virtual
   **/
  global virtual Date getDateFromString(string datestring) {
    if (!string.isblank(datestring)) {
      List<string> dateComp = datestring.split('/');
      Date returnDate = date.parse(
        datecomp[1] +
        '/' +
        dateComp[2] +
        '/' +
        dateComp[0]
      );
      return returnDate;
    }
    return null;
  }
}
