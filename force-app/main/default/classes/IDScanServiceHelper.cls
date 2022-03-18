/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class IDScanServiceHelper extends AbstractService {
  @TestVisible
  private static IDScanServiceHelper serviceInstance;

  public IDScanServiceHelper() {
    super(IDScanServiceHelper.class);
  }

  /**
   * @description Provides a singleton instance of IDScanServiceHelper from which all other class methods can be accessed.
   * @author Digital Align Team | 03/18/2022
   * @return Object  singleton
   **/
  public static IDScanServiceHelper getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (IDScanServiceHelper) getInstance(IDScanServiceHelper.class);
    }
    return serviceInstance;
  }

  global virtual HttpBuilder.Response ParseImageResponse(HttpResponse response) {
    Map<String, Object> idOldMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

    if ((string) ((Map<String, Object>) idOldMap.get('ParseImageResult')).get('ErrorMessage') != 'OK') {
      throw new CustomException(System.Label.Document_UnableToParseTheDl);
    }

    Map<String, Object> result = (Map<String, Object>) ((Map<String, Object>) idOldMap.get('ParseImageResult'))
      .get('DriverLicense');
    Map<String, Object> newMap = new Map<String, Object>();
    newMap.put('documentNumber', result.get('LicenseNumber'));
    newMap.put('firstName', result.get('FirstName'));
    newMap.put('lastName', result.get('LastName'));
    newMap.put('fullName', result.get('FullName'));
    newMap.put('gender', result.get('Gender'));
    newMap.put('height', result.get('Height'));
    newMap.put('weight', result.get('WeightKG'));
    newMap.put('dob', result.get('Birthdate'));
    newMap.put('expiry', result.get('ExpirationDate'));
    newMap.put('issued', result.get('IssueDate'));
    newMap.put('address1', result.get('Address1'));
    newMap.put('city', result.get('City'));
    newMap.put('postalCode', result.get('PostalCode'));
    newMap.put('documentType', result.get('DocumentType'));
    newMap.put('issuerRegion', result.get('IssuedBy'));
    newMap.put('issuerCountry', GenericUtils.fetchCountryFromCountryCode((string) result.get('CountryCode')));
    newMap.put('state', result.get('IssuedBy'));
    newMap.put('Country', GenericUtils.fetchCountryFromCountryCode((string) result.get('CountryCode')));
    newMap.put('nationality', result.get('CountryCode'));
    system.debug('newMap =' + newMap);
    IdScanDTO.Response returnDTO = (IdScanDTO.Response) JSON.deserialize(
      JSON.serialize(new Map<String, Object>{ 'Data' => newMap, 'status' => response.getStatusCode() }),
      IdScanDTO.Response.class
    );

    return HttpBuilder.buildResponse(
      response.getStatusCode(),
      response.getStatus(),
      mapIdentityResponse(new Applicant__c(), returnDTO)
    );
  }

  /**
   * @description parse identity response into applicant record
   * @author Digital Align Team | 11-01-2021
   * @param Applicant__c applicant
   * @param IdScanDTO.Response returnDTO
   * @return Applicant__c
   **/
  global virtual Applicant__c mapIdentityResponse(Applicant__c applicant, IdScanDTO.Response returnDTO) {
    IdentificationDocument__c identity = new IdentificationDocument__c();
    ContactPointAddress idAddress = new ContactPointAddress();

    applicant.FirstName__c = returnDTO.data.firstName;
    applicant.LastName__c = returnDTO.data.lastName;
    applicant.Birthdate__c = date.valueOf(returnDTO.data.dob);
    applicant.IdentityVerificationStatus__c = 'Passed';
    identity.Height__c = returnDTO.data.height;
    identity.IssuedRegion__c = returnDTO.data.issuerRegion;
    identity.Weight__c = returnDTO.data.weight;
    identity.Gender__c = returnDTO.data.gender;
    identity.DocumentType__c = mapDocumentTypeValue(returnDTO.data.documentType);
    identity.DocumentNumber__c = returnDTO.data.documentNumber;
    identity.IssuingCountry__c = returnDTO.data.issuerCountry;
    identity.Nationality__c = returnDTO.data.country;
    identity.ExpirationDate__c = date.valueOf(returnDTO.data.expiry);
    identity.IssueDate__c = date.valueOf(returnDTO.data.issued);
    idAddress.Street = returnDTO.data.address1;
    idAddress.City = returnDTO.data.city;
    idAddress.PostalCode = returnDTO.data.postalCode;
    idAddress.StateCode__c = returnDTO.data.state;
    idAddress.Country = returnDTO.data.country;

    SObjectConstructor construct = SObjectConstructor.getInstance(applicant);
    construct.setChildObjects('mflow__ContactPointAddresses__r', new List<ContactPointAddress>{ idAddress });
    construct.setChildObjects('mflow__IdentificationDocuments__r', new List<IdentificationDocument__c>{ identity });
    applicant = (Applicant__c) construct.build();
    return applicant;
  }

  /**
   * @description parse identity response into applicant record
   * @author Digital Align Team | 11-01-2021
   * @param Applicant__c applicant
   * @param IdScanDTO.Response returnDTO
   * @return string
   **/
  global string mapDocumentTypeValue(string value) {
    if (value != null) {
      switch on value {
        when 'DL' {
          return 'Drivers License';
        }
        when 'ID' {
          // If Identity card save as state ID
          return 'State Id Card';
        }
        when 'CAC' {
          return 'Military Id';
        }
        when else {
          return 'Other';
        }
      }
    }
    return null;
  }
}
