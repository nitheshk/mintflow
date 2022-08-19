/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description Application service
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class AlloyProvider extends AbstractService {
  @TestVisible
  private static AlloyProvider serviceInstance;

  public AlloyProvider() {
    super(AlloyProvider.class);
  }

  /**
   * @description Provides a singleton instance of AlloyProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 03/28/2022
   * @return Object  singleton
   **/
  public static AlloyProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (AlloyProvider) getInstance(AlloyProvider.class);
    }
    return serviceInstance;
  }

  /**
   * @description verify IDV for an applicant
   * @param Applicant__c applicants
   * @param Id applicantId
   * @return HttpResponse
   **/
  public HttpResponse doIDVVerification(Id applicantId) {
    AlloyDTO.IDVRequest idvDTO = new AlloyDTO.IDVRequest();
    Map<String, String> header = new Map<String, String>();
    HttpResponse response;
    try {
      header.put('Alloy-Application-Version', HttpBuilder.getApiConstant(AlloyConstants.IDV_APPLICATION_VERSION));
      header.put('Content-Type', 'application/json');
      header.put('Alloy-Application-Version', HttpBuilder.getApiConstant('Alloy_Application_Version'));
      log?.fine(' Alloy KYC request for doverification' + applicantId);
      Applicant__c applicantObj = AlloyRepository.readApplicantWithChild(applicantId);
      HttpBuilder.setAPISetting(APINames.AlloyKYC);
      HttpBuilder.replaceEndpoint('{evaluation}', HttpBuilder.getApiConstant('AlloyEvaluationURL'));
      String idvRequestBody = this.buildIDVRequest(applicantObj);
      log?.fine(' Alloy KYC request :' + idvRequestBody);
      response = HttpBuilder.httpCallOut(idvRequestBody, header);
      log?.fine(' Alloy KYC response :' + response.getBody());
    } catch (exception ex) {
      system.debug('exceptopn:' + ex.getLineNumber() + '-' + ex.getMessage());
    }
    return response;
  }

  /**
   * @description
   * @author Digital Align Team | 08-19-2022
   * @param Applicant__c applicant
   * @return String
   **/
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

  /**
   * @description Save KYC alloy response against the applicant
   * @param Applicant__c applicants
   * @param Id applicantId
   * @param HttpResponse response
   * @return void
   **/

  public void saveApplicantVerification(Id applicantId, HttpResponse response) {
    FileDTO fileObj = new FileDTO('AlloyResponse.json', Blob.valueof(response.getBody()), applicantId);
    ContentVersion cnv = FileService.getInstance().createFile(fileObj);
  }

  /**
   * @description To parse the response and check the status and update
   * @param Applicant__c applicants
   * @param Id applicantId
   * @param HttpResponse response
   * @return void
   **/
  public void ParseIDVReponse(Id applicantId, HttpResponse response) {
    Applicant__c applicantObj;
    String responseBody = response.getBody();
    AlloyDTO.IDVResponse idvDTO = AlloyDTO.parseIDVResponse(responseBody);
    system.debug('idvDTO::' + responseBody);
    applicantObj = AlloyRepository.readApplicantWithChild(applicantId);
    try {
      if (idvDTO.summary.result.equalsignoreCase('success') && idvDTO.summary.outcome.equalsignorecase('Approved')) {
        applicantObj.mflow__KYCStatus__c = 'Passed';
      } else {
        applicantObj.mflow__KYCStatus__c = 'Under Review';
      }
    } catch (exception ex) {
      applicantObj.mflow__KYCStatus__c = 'Under Review';
    }
    //log?.fine(' Applicant Credit Score :' + idvDTO.formatted_responses.qualifie.data.qualifile_1.Score);
    System.debug('kyc value::' + idvDTO.formatted_responses);

    applicantObj.CreditScore__c = idvDTO.formatted_responses.qualifile.data.qualifile.score;

    ApplicantRepository.upsertRecord(applicantObj);
  }
}
