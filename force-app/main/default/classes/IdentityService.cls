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
    string zipcode = (string) params.get('zipcode');
    if (string.isBlank(zipcode) && params != null) {
      throw new CustomException('Zipcode value not set');
    }
    Flow.initialize(ApexRequest.getApplicationId());
    Flow.setFlow('EligibilityFlow');
    Flow.setSubFlow(APINames.Geocoding.name());
    if (HttpBuilder.isActiveApiSetting(APINames.Geocoding)) {
      HttpBuilder.setAPISetting(APINames.Geocoding);
      HttpBuilder.replaceEndpoint(
        '{APIKey}',
        HttpBuilder.getApiConstant('GeocodingAPIKey')
      );
      HttpBuilder.replaceEndpoint('{Pincode}', (string) params.get('zipcode'));
      HttpBuilder.Response response = (HttpBuilder.Response) GeocodingProvider.getInstance()
        .validateCountyUsingGoogleApi(params);

      if (response.statusCode == 200) {
        flow.setSubFlowPassed(response.status);
        flow.setFlowPassed('Completed');
        return response.data;
      } else {
        flow.setSubFlowFailed(response.status);
        flow.setFlowFailed('Failed');
        throw new CustomException(response.status);
      }
    } else {
      flow.setSubFlowFailed('Requested API is disabled');
      flow.setFlowFailed('Failed');
      throw new CustomException('Requested API is disabled');
    }
  }
  /**
   * @description
   * @author Digital Align | 10-26-2021
   * @param Map<String object> params
   * @return virtual
   **/
  global virtual Object scanDL(Map<String, object> params) {
    dau01__Applicant__c applicant = new dau01__Applicant__c();
    FinServ__IdentificationDocument__c identity = new FinServ__IdentificationDocument__c();
    ContactPointAddress idAddress = new ContactPointAddress();
    dau01.SObjectConstructor construct;
    DocumentScanDTO.Request requestDTO;
    Map<String, object> res;
    string contentDocumentId = (string) params.get('contentDocumentId');
    ContentVersion cv = FileService.getInstance()
      .fetchContentVersionByCD(contentDocumentId, false);
    if (cv != null) {
      requestDTO = new DocumentScanDTO.Request();
      requestDTO.file_base64 = EncodingUtil.base64Encode(cv.VersionData);
      requestDTO.apikey = 'rfdNfcbatBLzmdtTHqVaMLphOQQdLNw2';
      requestDTO.authenticate = 'true';
      requestDTO.authenticate_module = '2';
      requestDTO.verify_expiry = 'true';
      requestDTO.dualsidecheck = 'true';
      // res = DocumentScanProvider.invokeAPI(
      //   new Map<String, Object>{ 'DTO' => requestDTO }
      // );

      //DL
      string resJSON = '{"result":{"documentNumber":"D2874176","firstName":"RAJESH","middleName":"NINGAPPA","lastName":"PATIL","fullName":"RAJESH NINGAPPA PATIL","sex":"M","height":"065 IN","weight":"150","age":45,"dob":"1976/02/23","dob_day":23,"dob_month":2,"dob_year":1976,"expiry":"2020/02/23","expiry_day":23,"expiry_month":2,"expiry_year":2020,"daysToExpiry":-610,"issued":"2015/02/20","issued_day":20,"issued_month":2,"issued_year":2015,"daysFromIssue":2440,"address1":"44533 JAPALA PL","address2":"FREMONT","postcode":"945390000","optionalData":"02/20/2015644C2/BBFD/20","vehicleClass":"C","restrictions":"NONE","endorsement":"NONE","documentType":"D","documentSide":"DUAL","issuerOrg_region_full":"California","issuerOrg_region_abbr":"CA","issuerOrg_full":"United States","issuerOrg_iso2":"US","issuerOrg_iso3":"USA","nationality_full":"United States","nationality_iso2":"US","nationality_iso3":"USA","internalId":"AAMVA","eyeColor":"BRN","hairColor":"BLK"},"confidence":{"documentNumber":1,"firstName":1,"middleName":1,"lastName":1,"fullName":1,"sex":1,"height":1,"weight":0.906,"age":1,"dob":1,"dob_day":1,"dob_month":1,"dob_year":1,"expiry":1,"expiry_day":1,"expiry_month":1,"expiry_year":1,"daysToExpiry":1,"issued":1,"issued_day":1,"issued_month":1,"issued_year":1,"daysFromIssue":1,"address1":1,"address2":1,"postcode":1,"optionalData":1,"vehicleClass":1,"restrictions":1,"endorsement":1,"documentType":1,"documentSide":1,"issuerOrg_region_full":1,"issuerOrg_region_abbr":1,"issuerOrg_full":1,"issuerOrg_iso2":1,"issuerOrg_iso3":1,"nationality_full":1,"nationality_iso2":1,"nationality_iso3":1,"internalId":1,"eyeColor":1,"hairColor":1},"verification":{"passed":false,"result":{"notexpired":false}},"authentication":{"score":0.6,"breakdown":{"data_visibility":{"passed":true},"image_quality":{"passed":true},"feature_referencing":{"passed":true},"exif_check":{"passed":true},"publicity_check":{"passed":true},"text_analysis":{"passed":true},"biometric_analysis":{"passed":true},"security_feature_check":{"passed":true},"recapture_check":{"passed":false,"code":180,"reason":"Recaptured document","severity":"medium"}},"warning":["Recaptured document"]},"matchrate":1,"executionTime":6.810007095336914,"responseID":"5fbf07dbea65f0dbdc5348163666672d","quota":5,"credit":45,"vaultid":"IAGwy0RmDGY6DrK57d4hIzTLNDw9tz2c"}';
      //Passport
      //string resJSON = '{"result":{"documentNumber":"P0000000","firstName":"VZOR","lastName":"SPECIMEN","fullName":"VZOR SPECIMEN","sex":"M","age":9,"dob":"2011/11/11","dob_day":11,"dob_month":11,"dob_year":2011,"expiry":"2015/01/04","expiry_day":4,"expiry_month":1,"expiry_year":2015,"daysToExpiry":-2488,"documentType":"P","documentSide":"BIODATA","issuerOrg_full":"Slovakia","issuerOrg_iso2":"SK","issuerOrg_iso3":"SVK","nationality_full":"Slovakia","nationality_iso2":"SK","nationality_iso3":"SVK","internalId":"MRZ"},"verification":{"passed":false,"result":{"notexpired":false}},"authentication":{"score":0.6,"breakdown":{"data_visibility":{"passed":true},"image_quality":{"passed":true},"feature_referencing":{"passed":true},"exif_check":{"passed":true},"publicity_check":{"passed":true},"text_analysis":{"passed":true},"biometric_analysis":{"passed":true},"security_feature_check":{"passed":true},"recapture_check":{"passed":false,"code":180,"reason":"Recaptured document","severity":"medium"}},"warning":["Recaptured document"]},"vaultid":"65BGYSOmyyANCXbOBA7ETmqNmJonX6WF","matchrate":1,"executionTime":2.3699569702148438,"responseID":"eed35bd0d504c69f5b5d4dca18a1544c","quota":5,"credit":28}';
      res = new Map<String, object>{
        'Status' => 200,
        'StatusMessage' => 'success',
        'Data' => resJSON
      };

      if (res.get('Status') == 200) {
        Map<String, Object> idOldMap = (Map<String, Object>) JSON.deserializeUntyped(
          (string) res.get('Data')
        );
        Map<String, Object> result = (Map<String, Object>) idOldMap.get(
          'result'
        );
        Map<String, Object> authenticatioBreakdown = (Map<String, Object>) ((Map<String, Object>) idOldMap.get(
            'authentication'
          ))
          .get('breakdown');

        Map<String, Object> validation = new Map<String, Object>();
        validation.put(
          'isExpired',
          (Boolean) ((Map<String, Object>) idOldMap.get('verification'))
            .get('passed')
        );
        validation.put(
          'score',
          ((Map<String, Object>) idOldMap.get('authentication')).get('score')
        );
        validation.put(
          'imageQualityPassed',
          (Boolean) ((Map<String, Object>) authenticatioBreakdown.get(
              'image_quality'
            ))
            .get('passed')
        );
        validation.put(
          'securityCheckPassed',
          (Boolean) ((Map<String, Object>) authenticatioBreakdown.get(
              'security_feature_check'
            ))
            .get('passed')
        );

        Map<String, Object> newMap = new Map<String, Object>();
        newMap.put('documentNumber', result.get('documentNumber'));
        newMap.put('firstName', result.get('firstName'));
        newMap.put('lastName', result.get('lastName'));
        newMap.put('fullName', result.get('fullName'));
        newMap.put('gender', result.get('sex'));
        newMap.put('height', result.get('height'));
        newMap.put('weight', result.get('weight'));
        newMap.put('dob', result.get('dob'));
        newMap.put('expiry', result.get('expiry'));
        newMap.put('issued', result.get('issued'));
        newMap.put('address1', result.get('address1'));
        newMap.put('address2', result.get('address2'));
        newMap.put('postalCode', result.get('postcode'));
        newMap.put('documentType', result.get('documentType'));
        newMap.put('issuerRegion', result.get('issuerOrg_region_abbr'));
        newMap.put('issuerCountry', result.get('issuerOrg_full'));
        newMap.put('nationality', result.get('nationality_full'));
        newMap.put('validation', validation);
        DocumentScanDTO.Response returnDTO = (DocumentScanDTO.Response) JSON.deserialize(
          JSON.serialize(
            new Map<String, Object>{
              'Data' => newMap,
              'status' => res.get('Status')
            }
          ),
          DocumentScanDTO.Response.class
        );
        applicant.dau01__FirstName__c = returnDTO.data.firstName;
        applicant.dau01__LastName__c = returnDTO.data.lastName;
        applicant.dau01__Birthdate__c = getDateFromString(returnDTO.data.dob);
        identity.dau01__Height__c = returnDTO.data.height;
        identity.dau01__IssuedRegion__c = returnDTO.data.issuerRegion;
        identity.dau01__Weight__c = returnDTO.data.weight;
        identity.dau01__Gender__c = returnDTO.data.gender;
        identity.FinServ__DocumentType__c = returnDTO.data.documentType;
        identity.FinServ__DocumentNumber__c = returnDTO.data.documentNumber;
        identity.FinServ__IssuingCountry__c = returnDTO.data.issuerCountry;
        identity.dau01__Nationality__c = returnDTO.data.nationality;
        identity.FinServ__ExpirationDate__c = getDateFromString(
          returnDTO.data.expiry
        );
        identity.FinServ__IssueDate__c = getDateFromString(
          returnDTO.data.issued
        );
        idAddress.Street =
          returnDTO.data.address1 +
          ' ' +
          returnDTO.data.address2;
        idAddress.PostalCode = returnDTO.data.postalCode;
        log?.debug(' returnDTO : ' + returnDTO);
        construct = dau01.SObjectConstructor.getInstance(applicant);
        construct.setChildObjects(
          'dau01__ContactPointAddresses__r',
          new List<ContactPointAddress>{ idAddress }
        );
        construct.setChildObjects(
          'dau01__IdentificationDocuments__r',
          new List<finServ__IdentificationDocument__c>{ identity }
        );
        applicant = (dau01__Applicant__c) construct.build();
        log?.debug(' Full Json : ' + Json.Serialize(applicant));
      }
    }
    return construct;
  }
  /**
   * @description
   * @author Digital Align | 10-30-2021
   * @param string datestring
   * @return virtual
   **/
  global virtual Date getDateFromString(string datestring) {
    if (!string.isblank(datestring)) {
      List<string> dateComp = datestring.split('/');
      Date returnDate = date.parse(
        datecomp[1] +
        '/' +
        dateComp[2] +
        '/' +
        dateComp[0]
      );
      return returnDate;
    }
    return null;
  }
}
