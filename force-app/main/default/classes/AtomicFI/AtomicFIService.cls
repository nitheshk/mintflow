/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description AtomicFI service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class AtomicFIService extends AbstractService {
  @TestVisible
  private static AtomicFIService serviceInstance;

  public AtomicFIService() {
    super(AtomicFIService.class);
  }

  /**
   * @description Provides a singleton instance of AtomicFIService from which all other class methods can be accessed.
   * @author Digital Align Team | 11/11/2021
   * @return Object  singleton
   **/
  public static AtomicFIService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (AtomicFIService) getInstance(AtomicFIService.class);
    }
    return serviceInstance;
  }

  /**
   * @description Creates a body json for the applicant to perfomr AtomicFI authentication
   * @author Digital Align Team | 11/11/2021
   * @return Object  AtomicFIDTO
   **/
  global virtual AtomicFIDTO createApplicantRequestJson(
    Applicant__c applicant
  ) {
    return mapApplicant(applicant);
  }

  /**
   * @description Map applicant data
   * @author Digital Align Team | 11/11/2021
   * @return Object  AtomicFIDTO
   **/
  global virtual AtomicFIDTO mapApplicant(Applicant__c applicant) {
    AtomicFIDTO atomObj = new AtomicFIDTO();
    AtomicFIDTO.data data = new AtomicFIDTO.data();
    AtomicFIDTO.outputs output = new AtomicFIDTO.outputs();
    AtomicFIDTO.name name = new AtomicFIDTO.name();
    List<AtomicFIDTO.name> names = new List<AtomicFIDTO.name>();
    String jsonRequest;
    atomObj.identifier = applicant.Id;
    name.firstName = applicant.FirstName__c;
    name.middleName = applicant.MiddleName__c;
    name.lastName = applicant.LastName__c;
    names.add(name);

    output.email = applicant.Email__c;
    output.firstName = applicant.FirstName__c;

    output.lastName = applicant.LastName__c;

    data.outputs = output;
    atomObj.data = data;
    atomObj.names = names;
    atomObj.applicantId = applicant.Id;

    atomObj.addresses = mapApplicantAddress(
      applicant.mflow__ContactPointAddresses__r
    );

    return atomObj;
  }

  /**
   * @description Map applicant address
   * @author Digital Align Team | 11/11/2021
   * @return  List<AtomicFIDTO.Address>
   **/
  global virtual List<AtomicFIDTO.Address> mapApplicantAddress(
    List<ContactPointAddress> applicantAddress
  ) {
    AtomicFIDTO.address address;
    List<AtomicFIDTO.address> addresses = new List<AtomicFIDTO.address>();

    for (ContactPointAddress contactadd : applicantAddress) {
      address = new AtomicFIDTO.address();
      // Address applicantadd = contactadd.Address;
      address.line1 = contactadd.Street;
      address.city = contactadd.City;
      address.state = contactadd.state;
      address.zipcode = contactadd.PostalCode;
      address.country = contactadd.Country;
      addresses.add(address);
    }
    return addresses;
  }
}
