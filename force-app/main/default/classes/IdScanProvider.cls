/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description IdScanProvider to perform customer due diligence
 **/
global virtual with sharing class IdScanProvider extends AbstractService {
  @TestVisible
  private static IdScanProvider serviceInstance;

  public IdScanProvider() {
    super(IdScanProvider.class);
  }

  /**
   * @description Provides a singleton instance of IdScanProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 12/28/2021
   * @return Object  singleton
   **/
  public static IdScanProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (IdScanProvider) getInstance(IdScanProvider.class);
    }
    return serviceInstance;
  }

  /**
   * @description Provides a singleton instance of PlaidProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 12/28/2021
   * @return HttpBuilder.HttpResponse
   **/
  public static HttpBuilder.Response idScanCheck(IdScanDueDiligenceDTO.Request customer) {
    HttpBuilder.setAPISetting(APINames.DueDiligence);
    //body
    String requestBody = JSON.serialize(customer, true);
    Flow.setSubFlow(APINames.DueDiligence);
    Flow.setSubFlowRequest(requestBody);
    system.debug('requestbody::' + requestBody);
    //header
    Map<String, String> header = new Map<String, String>();
    header.put('Content-Type', 'application/json');
    header.put('Authorization', 'Bearer ' + '{!$Credential.Password}');
    header.put('api-version', '1.0');
    //APi Call
    HttpResponse response = HttpBuilder.httpCallOut(requestBody, header);
    Flow.setSubFlowResponse(response.getBody());
    return HttpBuilder.buildResponse(response);
  }

  /**
   * @description scan DL using idScan API
   * @author Digital Align Team | 11-01-2021
   * @param Map<String object> params
   * @return virtual
   **/
  global virtual HttpBuilder.Response idScan(Map<String, object> params) {
    ContentVersion frontCv = (ContentVersion) params.get('frontContentVersion');
    //header
    Map<String, String> header = new Map<String, String>();
    header.put('Content-Type', 'application/json');
    //request
    IdScanDTO.IdScanRequest requestDTO = new IdScanDTO.IdScanRequest();
    requestDTO.data = EncodingUtil.base64Encode(frontCv.VersionData);
    requestDTO.authKey = HttpBuilder.getApiConstant('IdScanAPIKey');
    frontCv = null;
    params.remove('FrontContentVersion');
    Flow.setSubFlowRequest(requestDTO);
    if (HttpBuilder.isActiveApiSetting(APINames.IdScan)) {
      HttpBuilder.setAPISetting(APINames.IdScan);
    }
    HttpResponse response = HttpBuilder.httpCallOut(json.serialize(requestDTO), header);

    //Temp response passport
    /*HttpResponse response = new HttpResponse();
    response.setStatus('ok');
    response.setStatusCode(200);
    response.setBody(
      '{"ParseImageResult":{"Confidence":100,"DriverLicense":{"Address1":"44533 JAPALA PL","Address2":"","Birthdate":"1976-02-23","CardRevisionDate":"2010-04-16","City":"FREMONT","ClassificationCode":"C","ComplianceType":" ","Country":"United States of America","CountryCode":"USA","DocumentType":"DL","EndorsementCodeDescription":"","EndorsementsCode":"","ExpirationDate":"2025-02-23","EyeColor":"Brown","FirstName":"RAJESH","FullName":"RAJESH NINGAPPA PATIL","Gender":"Male","HAZMATExpDate":null,"HairColor":"Black","Height":"065 IN","IIN":"636014","IssueDate":"2015-02-20","IssuedBy":"CA","JurisdictionCode":"CA","LastName":"PATIL","LicenseNumber":"D2874176","LimitedDurationDocument":"False","MiddleName":"NINGAPPA","NamePrefix":"","NameSuffix":"","OrganDonor":null,"PostalBox":"","PostalCode":"94539-0000","Race":"","RestrictionCode":"","RestrictionCodeDescription":"","VehicleClassCode":"C","VehicleClassCodeDescription":"","Veteran":null,"WeightKG":"68","WeightLBS":"150"},"ErrorMessage":"OK","Reference":"0D1894ED77A6A4682605D773A9CC7FF65A6DBB50","Success":true,"ValidationCode":{"Errors":[],"IsValid":true}}}'
    );
    */
    flow.setSubFlowResponse(response?.getBody());
    if (response.getStatusCode() != 200) {
      throw new CustomException(response.getStatus());
    }
    return IDScanServiceHelper.getinstance().ParseImageResponse(response);
  }

  /**
   * @description parse identity response into applicant record
   * @author Digital Align Team | 11-01-2021
   * @param String  zipcode
   * @return Object
   **/
  public static Object fetchCountyByZipcode(String zipcode) {
    Map<String, Object> result = new Map<String, Object>();
    Map<String, Object> matchingResult = new Map<String, Object>();
    EligibleCounty__c county = IdentityRepository.fetchCountyByZipcode(zipcode);

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
  }

  /**
   * @description To verify the county using Google API
   * @author Digital Align Team | 11-01-2021
   * @param String  zipcode
   * @return Object
   **/

  public static Object verifyCountyUsingGoogleApi(Map<string, Object> params) {
    String eligibleCountyNames = ApplicationConfiguration__c.getInstance().CountyNames__c;
    List<String> eligibleCountyNameList = String.isNotBlank(eligibleCountyNames)
      ? eligibleCountyNames.split(';')
      : new List<String>();
    params.put('eligibleCountyNameList', eligibleCountyNameList);
    string zipcode = (string) params.get('zipcode');
    if (string.isBlank(zipcode) && params != null) {
      throw new CustomException(System.Label.Identity_ZipcodeValueNotSet);
    }
    if (HttpBuilder.isActiveApiSetting(APINames.Geocoding)) {
      HttpBuilder.setAPISetting(APINames.Geocoding);
      HttpBuilder.replaceEndpoint('{APIKey}', HttpBuilder.getApiConstant('GeocodingAPIKey'));
      HttpBuilder.replaceEndpoint('{Pincode}', (string) params.get('zipcode'));
      HttpBuilder.Response response = GeocodingProvider.getInstance().validateCountyUsingGoogleApi(params);
      flow.setSubFlowPassed(response.status);
      flow.setFlowPassed('Completed');
      return response.data;
    } else {
      throw new CustomException(System.Label.Api_RequestedApiIsDisabled);
    }
  }
}
