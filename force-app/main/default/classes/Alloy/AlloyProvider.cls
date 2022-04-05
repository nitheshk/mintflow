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
    header.put('Alloy-Application-Version', HttpBuilder.getApiConstant(AlloyConstants.IDV_APPLICATION_VERSION));
    header.put('Content-Type', 'application/json');
    Applicant__c applicantObj = AlloyRepository.readApplicantWithChild(applicantId);
    HttpBuilder.setAPISetting(APINames.AlloyKYC);
    HttpBuilder.replaceEndpoint('{evaluation}', HttpBuilder.getApiConstant('AlloyEvaluationURL'));
    String idvRequestBody = AlloyServiceHelper.getinstance().buildIDVRequest(applicantObj);
    log?.fine(' Alloy KYC request :' + idvRequestBody);
    HttpResponse response = HttpBuilder.httpCallOut(idvRequestBody, header);
    log?.fine(' Alloy KYC response :' + response.getBody());

    return response;
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
    System.debug('cnv Id::' + cnv.Id);
  }

  /**
   * @description To parse the response and check the status and update
   * @param Applicant__c applicants
   * @param Id applicantId
   * @param HttpResponse response
   * @return void
   **/
  public void ParseIDVReponse(Id applicantId, HttpResponse response) {
    String responseBody = response.getBody();
    AlloyDTO.IDVResponse idvDTO = AlloyDTO.parseIDVResponse(responseBody);
    system.debug('idvDTO::' + idvDTO);
    Applicant__c applicantObj = AlloyRepository.readApplicantWithChild(applicantId);
    if (idvDTO.summary.result.equalsignoreCase('success') && idvDTO.summary.outcome.equalsignorecase('Approved')) {
      applicantObj.mflow__KYCStatus__c = 'Passed';
    } else {
      applicantObj.mflow__KYCStatus__c = 'Under Review';
    }
    ApplicantRepository.upsertRecord(applicantObj);
  }
}
