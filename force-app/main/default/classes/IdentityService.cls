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
        flow.setSubFlowPassed(response.status);
        flow.setFlowPassed('Completed');
        return (dau01__Applicant__c) response.data;
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
   * @author Digital Align Team | 11-01-2021
   * @param Map<String object> params
   * @return virtual
   **/
  global virtual Object identityVerify(Map<String, object> params) {
    try {
      String applicantId = params.get('applicantId').toString();
      if (String.isBlank('applicantId')) {
        throw new customException('Invalid Applicant Id');
      }
      String apiName = params.get('apiName').toString();
      Applicant__c applicant = IdentityRepository.readApplicantForIdentity(
        (ID) applicantId
      );
      params.put('applicant', applicant);

      HttpBuilder.Response response;
      if (apiName == 'SentiLink') {
        if (HttpBuilder.isActiveApiSetting(APINames.SentiLink)) {
          HttpBuilder.setAPISetting(APINames.SentiLink);
          response = SentiLinkProvider.getInstance().validateSentiLink(params);
        } else {
          return new Applicant__c();
        }
      } else if (apiName == 'SentiLinkIdCompletion') {
        if (HttpBuilder.isActiveApiSetting(APINames.SentiLinkIdCompletion)) {
          HttpBuilder.setAPISetting(APINames.SentiLinkIdCompletion);
          response = SentiLinkProvider.getInstance().validateSentiLink(params);
        } else {
          return new Applicant__c();
        }
      } else {
        throw new CustomException('Check API Configuration');
      }
      //Create Response File
      FileService.getInstance()
        .createFile(
          new FileDTO(
            'customerScore.txt',
            blob.valueof(Json.serialize(params.get('responseBody'))),
            applicantId,
            'Identity',
            'SentiLink'
          )
        );

      return response.data;
    } catch (Exception ex) {
      throw ex;
    }
  }
}
