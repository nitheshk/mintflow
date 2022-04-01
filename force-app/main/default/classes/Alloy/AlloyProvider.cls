/**
 * Copyright (c) 2021 Digital Align
 * @group Service
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
   * @param Map<String Object> params
   * @return Applicant__c
   **/

  public Applicant__c doIDVVerification(Id applicantId) {
    AlloyDTO.IDVRequest idvDTO = new AlloyDTO.IDVRequest();
    Map<String, String> header = new Map<String, String>();
    header.put('Alloy-Application-Version', HttpBuilder.getApiConstant(AlloyConstants.IDV_APPLICATION_VERSION));
    Applicant__c applicantObj = AlloyRepository.readApplicantWithChild(applicantId);
    HttpBuilder.setAPISetting(APINames.AlloyKYC);
    HttpBuilder.replaceEndpoint('{evaluation}', HttpBuilder.getApiConstant('AlloyEvaluationURL'));
    String idvRequestBody = AlloyServiceHelper.getinstance().buildIDVRequest(applicantObj);
    log?.fine(' Alloy KYC request :' + idvRequestBody);

    HttpResponse response = HttpBuilder.httpCallOut(idvRequestBody, header);
    log?.fine(' Alloy KYC response :' + response.getBody());

    return applicantObj;
  }
}
