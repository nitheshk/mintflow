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
    String tokenKey;
    Map<String, Object> objectData;
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
        header.put('x-api-key', HttpBuilder.getApiConstant('x_api_key'));
        header.put('x-api-secret', HttpBuilder.getApiConstant('x_api_secret'));
        HttpResponse response = HttpBuilder.httpCallOut(jsonRequest, header);
        map<string, Object> mapResponse = (Map<String, Object>) JSON.deserializeUntyped(
          response.getBody()
        );
        if (mapResponse.containsKey('data')) {
          objectData = (Map<String, Object>) mapResponse.get('data');
          tokenKey = (String) objectData.get('token');
        } else {
          tokenKey = 'API does not contain token';
        }
      } else {
        throw new CustomException(System.Label.Api_RequestedApiIsDisabled);
      }
    } catch (Exception ex) {
      throw ex;
    }
    return tokenKey;
  }

  /**
   * @description @description Get  AtomicFI response of employment verification
   * @author Digital Align Team | 11-01-2021
   * @param ApplicantId
   * @param EmployerId
   * @return String
   **/
  global virtual String getAtomicResponse(
    String applicantId,
    String employerId
  ) {
    String textValue;
    List<ContentVersion> files = Fileservice.getinstance()
      .fetchContentVersionByFileType(
        employerId,
        'Employment',
        'AtomicFI',
        false
      );
    if (files != null && files.size() > 0) {
      textValue = files[0].VersionData.toString();
      return textValue;
    } else
      return ' No data found for this employer Information';
  }
}
