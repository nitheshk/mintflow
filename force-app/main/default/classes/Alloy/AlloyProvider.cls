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

  //ALLOY Constant
  public static final String ALLOY_STATUS_ACCEPT = 'Approved';
  public static final String ALLOY_STATUS_REVIEW = 'Manual Review';
  public static final String ALLOY_STATUS_DECLINE = 'Denied';
  //Internal KYC Status
  public static final String KYC_STATUS_PASSED = 'Passed';
  public static final String KYC_STATUS_UNDER_REVIEW = 'Under Review';
  public static final String KYC_STATUS_FAILED = 'Failed';

  public static final Map<String, String> IDV_STATUS_MAPPING = new Map<String, String>{
    ALLOY_STATUS_ACCEPT => KYC_STATUS_PASSED,
    ALLOY_STATUS_REVIEW => KYC_STATUS_UNDER_REVIEW,
    ALLOY_STATUS_DECLINE => KYC_STATUS_FAILED,
    '' => KYC_STATUS_UNDER_REVIEW,
    null => KYC_STATUS_UNDER_REVIEW
  };

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
   * @param Applicant__c applicant
   * @param Id applicantId
   * @return HttpResponse
   **/
  global virtual Applicant__c doIDVVerification(Id applicantId) {
    try {
      Applicant__c applicant = AlloyRepository.readApplicantWithChild(applicantId);
      if (applicant == null) {
        throw new customException(System.Label.Applicant_InvalidApplicantId);
      }
      Flow.setSubFlow(APINames.AlloyKYC, ApexRequest.getApplicantId());
      HttpBuilder.setAPISetting(APINames.AlloyKYC);
      // Build Request
      String requestBody = this.buildIDVRequest(applicant);
      Flow.setSubFlowRequest(requestBody);
      HttpBuilder.replaceEndpoint('{evaluation}', HttpBuilder.getApiConstant('AlloyEvaluationURL'));
      //set http header
      Map<String, String> header = new Map<String, String>();
      header.put('Alloy-Application-Version', HttpBuilder.getApiConstant(AlloyConstants.IDV_APPLICATION_VERSION));
      header.put('Content-Type', 'application/json');
      header.put('Alloy-Application-Version', HttpBuilder.getApiConstant('Alloy_Application_Version'));
      HttpResponse response = HttpBuilder.httpCallOut(requestBody, header);
      Flow.setSubFlowResponse(response.getBody());

      // Save the Result into file
      try {
        FileService.getInstance()
          .createFile(new FileDTO('AlloyResponse.json', Blob.valueof(response.getBody()), applicantId, 'KYC', 'Alloy'));
      } catch (Exception ex) {
        log?.error(ex);
      }

      /// parse the response
      if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
        Flow.setSubFlowPassed('Passed');
        return this.ParseIDVReponse(applicant, response);
      } else {
        String msg = 'KYC  Status Code :' + response.getStatusCode() + ' , Message : ' + response.getStatus();
        Flow.setSubFlowFailed(msg);
        throw new customException(msg);
      }
    } catch (Exception ex) {
      log?.error(ex);
      throw ex;
    }
  }

  /**
   * @description construct dto for  alloy request
   * @author Digital Align Team | 08-19-2022
   * @param Applicant__c applicant
   * @return String
   **/
  global virtual String buildIDVRequest(Applicant__c applicant) {
    AlloyDTO.IDVRequest idvDTO = new AlloyDTO.IDVRequest();
    mflow__IdentificationDocument__c identificationObj = applicant.mflow__IdentificationDocuments__r.isEmpty()
      ? new mflow__IdentificationDocument__c()
      : applicant.mflow__IdentificationDocuments__r[0];

    Address__c addresses = applicant.mflow__Addresses__r.isEmpty()
      ? new Address__c()
      : applicant.mflow__Addresses__r[0];

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
    idvDTO.address_line_1 = addresses.Street__c;
    idvDTO.address_city = addresses.City__c;
    idvDTO.address_state = addresses.StateCode__c;
    idvDTO.address_postal_code = addresses.PostalCode__c;
    idvDTO.address_country_code = 'US';
    //idvDTO.ip_address_v4 = ApplicationServiceHelper.getinstance().getIpAddress();
    idvDTO.document_license = identificationObj.DocumentNumber__c;
    idvDTO.document_license_state = identificationObj.IssuedStateCode__c;
    return AlloyDTO.generateRequest(idvDTO);
  }

  /**
   * @description To parse the response and check the status and update
   * @param Applicant__c applicant
   * @param HttpResponse response
   * @return Applicant__c
   **/
  public Applicant__c parseIDVReponse(Applicant__c applicant, HttpResponse response) {
    AlloyDTO.IDVResponse idvDTO = AlloyDTO.parseIDVResponse(response.getBody());
    applicant.mflow__KYCStatus__c = IDV_STATUS_MAPPING.get(idvDTO?.summary?.outcome);
    applicant.CreditScore__c = idvDTO.formatted_responses?.QualiFile?.data?.qualifile?.score;
    return (Applicant__c) ApplicantRepository.upsertRecord(applicant);
  }
}
