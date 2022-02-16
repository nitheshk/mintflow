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
    return verifyCountyUsingConfiguration(params);
  }

  global virtual Object verifyCountyUsingConfiguration(
    Map<String, Object> params
  ) {
    try {
      string zipcode = (string) params.get('zipcode');
      if (string.isBlank(zipcode)) {
        throw new CustomException(System.Label.Identity_ZipcodeValueNotSet);
      }
      Map<String, Object> result = new Map<String, Object>();
      Map<String, Object> matchingResult = new Map<String, Object>();
      EligibleCounty__c county = IdentityRepository.fetchCountyByZipcode(
        zipcode
      );

      if (county != null) {
        matchingResult.put('zipcode', zipcode);
        matchingResult.put('county', county.Name);
        matchingResult.put('state', county.State__c);
        result.put('matchingAddress', new List<Object>{ matchingResult });
        result.put('isCountyEligible', true);
      } else {
        result.put('matchingAddress', new List<Object>());
        result.put('isCountyEligible', false);
      }
      return result;
    } catch (Exception ex) {
      log?.error(ex);
      throw ex;
    }
  }

  /**
   * @description verify county eligibility
   * Pass "zipcode" as parameter
   * @author Digital Align Team | 10-13-2021
   * @param Map<String String> params
   * @return Object
   **/
  global virtual Object verifyCountyUsingGoogleApi(Map<String, Object> params) {
    Flow.initialize(ApexRequest.getApplicationId());
    Flow.setFlow('EligibilityFlow');
    Flow.setSubFlow(APINames.Geocoding.name());
    try {
      String eligibleCountyNames = ApplicationConfiguration__c.getInstance()
        .CountyNames__c;
      List<String> eligibleCountyNameList = String.isNotBlank(
          eligibleCountyNames
        )
        ? eligibleCountyNames.split(';')
        : new List<String>();
      params.put('eligibleCountyNameList', eligibleCountyNameList);
      string zipcode = (string) params.get('zipcode');
      if (string.isBlank(zipcode) && params != null) {
        throw new CustomException(System.Label.Identity_ZipcodeValueNotSet);
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
        throw new CustomException(System.Label.Api_RequestedApiIsDisabled);
      }
    } catch (Exception ex) {
      log?.error(ex);
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
      ContentVersion backCv;
      string frontImage = (string) params.get('frontImageDocumentId');
      string backImage = (string) params.get('backImageDocumentId');
      ContentVersion frontCv = FileService.getInstance()
        .fetchContentVersionByCD(frontImage, false);
      if (String.isNotBlank(backImage)) {
        backCv = FileService.getInstance()
          .fetchContentVersionByCD(backImage, false);
      }
      if (frontCv == null) {
        throw new CustomException(System.Label.Document_DocumentNotFound);
      }
      if (backCv != null) {
        params.put('backContentVersion', backCv);
      }
      params.put('frontContentVersion', frontCv);

      if (HttpBuilder.isActiveApiSetting(APINames.IdScanAnalyzer)) {
        HttpBuilder.setAPISetting(APINames.IdScanAnalyzer);
        HttpBuilder.Response response = DocumentScanProvider.getInstance()
          .idScanAnalyzer(params);
        flow.setSubFlowPassed(response.status);
        flow.setFlowPassed('Completed');
        return (Applicant__c) response.data;
      } else {
        throw new CustomException(System.Label.Api_RequestedApiIsDisabled);
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
  global virtual Applicant__c identityVerify(Map<String, object> params) {
    try {
      String applicantId = params.get('applicantId').toString();
      if (String.isBlank('applicantId')) {
        throw new customException(System.Label.Applicant_InvalidApplicantId);
      }
      String apiName = params.get('apiName').toString();
      Applicant__c applicant = IdentityRepository.readApplicantForIdentity(
        (ID) applicantId
      );

      if (ApplicationConfiguration__c.getInstance().SentiLink__c == false) {
        return applicant;
      }

      params.put('applicant', applicant);

      HttpBuilder.Response response;
      if (apiName == 'SentiLink') {
        if (HttpBuilder.isActiveApiSetting(APINames.SentiLink)) {
          HttpBuilder.setAPISetting(APINames.SentiLink);
          response = SentiLinkProvider.getInstance().validateSentiLink(params);
          applicant = (Applicant__c) response.data;
        }
      } else if (apiName == 'SentiLinkIdCompletion') {
        if (HttpBuilder.isActiveApiSetting(APINames.SentiLinkIdCompletion)) {
          HttpBuilder.setAPISetting(APINames.SentiLinkIdCompletion);
          response = SentiLinkProvider.getInstance().validateSentiLink(params);
          applicant = (Applicant__c) response.data;
        }
      } else {
        throw new CustomException(System.Label.Api_RequestedApiIsDisabled);
      }

      if (response?.statusCode != 200) {
        applicant.SentiLinkStatus__c = 'Under Review';
        applicant.SentiLinkRemarks__c = '';
      }
      IdentityRepository.upsertRecord(Applicant);
      return applicant;
    } catch (Exception ex) {
      throw ex;
    }
  }

  /**
   * @description Generate Url to upload identity Document Via mobile device
   * @author Digital Align Team | 02-08-2022
   * @param Id applicantId
   * @return Object
   **/
  global virtual Object generateUrlForIdentityUpload(Id applicantId) {
    Applicant__c currentApplicant = IdentityRepository.readApplicantWithApplication(
      applicantId
    );

    // Send SMS
    String link = CustomerEmailService.getInstance()
      .generateUrl(
        new Map<String, String>{
          'aplType' => ApexRequest.getApplicantType(),
          'flw' => ApplicationConstant.FLOW_TYPE_IDENTITY_UPLOAD,
          'urlSuffix' => '/membership/upload/document-upload',
          'aplId' => currentApplicant.Id,
          'ch' => 'Virtual',
          'pageName' => '/mflow__IdentityUpload',
          'suffixType' => 'path'
        }
      );
    Map<String, Object> params = new Map<String, Object>();
    String messageBody = System.Label.Identity_SmsBodyForUploadDocument;
    messageBody = messageBody.replace('{url}', link);
    messageBody = messageBody.replace(
      '{applicationNumber}',
      currentApplicant.Application__r.Name
    );
    params.put('messageText', messageBody);
    // #pending remove hardcode mobile number [currentApplicant.Phone__c]
    params.put(
      'toPhone',
      HttpBuilder.getApiConstant('Twillio_Country') + '7892981668'
    );
    params.put('applicantId', currentApplicant.Id);
    NotificationService.getInstance().sendOTPMessage(params);

    // Send Email
    CustomerEmailService.getInstance().uploadIdentityDocument(currentApplicant);
    return true;
  }
}
