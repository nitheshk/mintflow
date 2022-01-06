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
  global virtual String authenticate(String applicantId, String employerId) {
    String jsonRequest;
    String tokenKey;
    Map<String, Object> objectData;
    try {
      Applicant__c applicant = ApplicantRepository.readApplicantWithChild(
        applicantId
      );
      AtomicFIDTO atomicObj = AtomicFIService.getInstance()
        .createApplicantRequestJson(applicant, employerId);
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
          tokenKey = (String) objectData.get('publicToken');
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

  /**
   * @description @description Get  AtomicFI response of employment verification
   * @author Digital Align Team | 11-01-2021
   * @param jsonResponse jsonRespomse
   * @param employerId employerId
   
   **/
  global virtual String generatePaySlipsW2(
    String jsonResponse,
    String employerId
  ) {
    // To fetch the file from saved employer Information
    String formURL;

    List<Blob> pdfContentList = new List<Blob>();
    Integer cnt = 0;
    Map<String, String> header = new Map<String, String>();
    APISetting__mdt apiDynamicSetting = new APISetting__mdt();

    AtomicFIDTO atomicObj = AtomicFIDTO.parse(jsonResponse);
    List<AtomicFIDTO.statements> statementList = atomicObj.data.outputs.statements;
    List<AtomicFIDTO.w2s> w2sList = atomicObj.data.outputs.w2s;

    try {
      header.put('x-api-key', HttpBuilder.getApiConstant('x_api_key'));
      header.put('x-api-secret', HttpBuilder.getApiConstant('x_api_secret'));
      for (AtomicFIDTO.statements statementObj : statementList) {
        apiDynamicSetting = new APISetting__mdt();
        formURL = statementObj.paystub.url;
        apiDynamicSetting.EndPoint__c = formURL;
        apiDynamicSetting.Timeout__c = 2000;
        apiDynamicSetting.Method__c = 'GET';
        HttpBuilder.setAPISetting(apiDynamicSetting);
        HttpResponse response = HttpBuilder.httpCallOut(null, null);
        pdfContentList.add(response.getBodyAsBlob());
      }

      for (AtomicFIDTO.w2s w2sObj : w2sList) {
        formURL = w2sObj.form.url;
        apiDynamicSetting.EndPoint__c = formURL;
        apiDynamicSetting.Timeout__c = 2000;
        apiDynamicSetting.Method__c = 'GET';
        HttpBuilder.setAPISetting(apiDynamicSetting);
        HttpResponse response = HttpBuilder.httpCallOut(null, null);
        pdfContentList.add(response.getBodyAsBlob());
      }
      for (Blob pdffile : pdfContentList) {
        cnt++;
        FileService.getInstance()
          .createFile(
            new FileDTO(
              'Income Files -' +
              cnt +
              '.pdf',
              pdffile,
              employerId,
              'PayStubs'
            )
          );
      }
      return 'Files generated successfully';
    } catch (exception ex) {
      return 'There is some issue in generating the payslips and W2';
    }
  }
}
