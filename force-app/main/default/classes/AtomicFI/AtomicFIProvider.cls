global with sharing class AtomicFIProvider extends AbstractService {
  /**
   * Copyright (c) 2021 Digital Align
   * @group Provider
   * @author Digital Align Team
   * @reference
   * @description AtomicFI Provider to perform employment verification
   **/
  @TestVisible
  private static AtomicFIProvider serviceInstance;

  public AtomicFIProvider() {
    super(AtomicFIProvider.class);
  }

  public static AtomicFIProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (AtomicFIProvider) getInstance(AtomicFIProvider.class);
    }
    return serviceInstance;
  }
  /**
   * @description authenticate the atomicFI
   * @author Digital Align Team | 11-01-2021
   * @param ApplicantId
   * @return String
   **/
  global virtual String authenticate(String applicantId) {
    String jsonRequest;
    try {
      Applicant__c applicant = ApplicantRepository.readApplicantWithChild(
        applicantId
      );

      AtomicFIDTO atomicObj = AtomicFIService.getInstance()
        .createApplicantRequestJson(applicant);
      jsonRequest = JSON.serialize(atomicObj, true);
      HttpBuilder.setAPISetting(APINames.AtomicFIToken);

      if (HttpBuilder.isActiveApiSetting(APINames.AtomicFIToken)) {
        Map<String, String> header = new Map<String, String>();

        header.put('accept', 'application/json');
        header.put('Content-Type', 'application/json');
        String test = HttpBuilder.getApiConstant('x_api_secret');

        header.put('x-api-key', HttpBuilder.getApiConstant('x_api_key'));
        header.put('x-api-secret', HttpBuilder.getApiConstant('x_api_secret'));
        HttpResponse response = HttpBuilder.httpCallOut(jsonRequest, header);
      } else {
        throw new CustomException('AtomicFI API is disabled');
      }
    } catch (Exception ex) {
      throw ex;
    }
    return jsonRequest;
  }
}
