/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class DocumentScanProvider extends AbstractService {
  @TestVisible
  private static DocumentScanProvider serviceInstance;

  public DocumentScanProvider() {
    super(DocumentScanProvider.class);
  }

  /**
   * @description Provides a singleton instance of DocumentScanProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static DocumentScanProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (DocumentScanProvider) getInstance(
        DocumentScanProvider.class
      );
    }
    return serviceInstance;
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
    DocumentScanDTO.IdScanRequest requestDTO = new DocumentScanDTO.IdScanRequest();
    requestDTO.data = EncodingUtil.base64Encode(frontCv.VersionData);
    requestDTO.authKey = HttpBuilder.getApiConstant('IdScanAnalyzerAPIKey');
    frontCv = null;
    params.remove('FrontContentVersion');
    Flow.setSubFlowRequest(requestDTO);
    // HttpResponse response = HttpBuilder.httpCallOut(
    //   json.serialize(requestDTO),
    //   header
    // );

    //Temp response passport
    HttpResponse response = new HttpResponse();
    response.setStatus('ok');
    response.setStatusCode(200);
    response.setBody(
      '{"ParseImageResult":{"Confidence":100,"DriverLicense":{"Address1":"44533 JAPALA PL","Address2":"","Birthdate":"1976-02-23","CardRevisionDate":"2010-04-16","City":"FREMONT","ClassificationCode":"C","ComplianceType":" ","Country":"United States of America","CountryCode":"USA","DocumentType":"DL","EndorsementCodeDescription":"","EndorsementsCode":"","ExpirationDate":"2025-02-23","EyeColor":"Brown","FirstName":"RAJESH","FullName":"RAJESH NINGAPPA PATIL","Gender":"Male","HAZMATExpDate":null,"HairColor":"Black","Height":"065 IN","IIN":"636014","IssueDate":"2015-02-20","IssuedBy":"CA","JurisdictionCode":"CA","LastName":"PATIL","LicenseNumber":"D2874176","LimitedDurationDocument":"False","MiddleName":"NINGAPPA","NamePrefix":"","NameSuffix":"","OrganDonor":null,"PostalBox":"","PostalCode":"94539-0000","Race":"","RestrictionCode":"","RestrictionCodeDescription":"","VehicleClassCode":"C","VehicleClassCodeDescription":"","Veteran":null,"WeightKG":"68","WeightLBS":"150"},"ErrorMessage":"OK","Reference":"0D1894ED77A6A4682605D773A9CC7FF65A6DBB50","Success":true,"ValidationCode":{"Errors":[],"IsValid":true}}}'
    );
    flow.setSubFlowResponse(response?.getBody());
    if (response.getStatusCode() != 200) {
      throw new CustomException(response.getStatus());
    }
    Map<String, Object> idOldMap = (Map<String, Object>) JSON.deserializeUntyped(
      response.getBody()
    );

    if (
      (string) ((Map<String, Object>) idOldMap.get('ParseImageResult'))
        .get('ErrorMessage') != 'OK'
    ) {
      throw new CustomException(System.Label.Document_UnableToParseTheDl);
    }

    Map<String, Object> result = (Map<String, Object>) ((Map<String, Object>) idOldMap.get(
        'ParseImageResult'
      ))
      .get('DriverLicense');
    Map<String, Object> newMap = new Map<String, Object>();
    newMap.put('documentNumber', result.get('LicenseNumber'));
    newMap.put('firstName', result.get('FirstName'));
    newMap.put('lastName', result.get('LastName'));
    newMap.put('fullName', result.get('FullName'));
    newMap.put('gender', result.get('Gender'));
    newMap.put('height', result.get('Height'));
    newMap.put('weight', result.get('WeightKG'));
    newMap.put('dob', result.get('Birthdate'));
    newMap.put('expiry', result.get('ExpirationDate'));
    newMap.put('issued', result.get('IssueDate'));
    newMap.put('address1', result.get('Address1'));
    newMap.put('city', result.get('City'));
    newMap.put('postalCode', result.get('PostalCode'));
    newMap.put('documentType', result.get('DocumentType'));
    newMap.put('issuerRegion', result.get('IssuedBy'));
    newMap.put(
      'issuerCountry',
      GenericUtils.fetchCountryFromCountryCode(
        (string) result.get('CountryCode')
      )
    );
    newMap.put('state', result.get('IssuedBy'));
    newMap.put('nationality', result.get('CountryCode'));
    system.debug('newMap =' + newMap);
    DocumentScanDTO.Response returnDTO = (DocumentScanDTO.Response) JSON.deserialize(
      JSON.serialize(
        new Map<String, Object>{
          'Data' => newMap,
          'status' => response.getStatusCode()
        }
      ),
      DocumentScanDTO.Response.class
    );

    return HttpBuilder.buildResponse(
      response.getStatusCode(),
      response.getStatus(),
      mapIdentityResponse(new Applicant__c(), returnDTO)
    );
  }

  /**
   * @description scan DL using idScanAnalyzer API
   * @author Digital Align Team | 11-01-2021
   * @param Map<String object> params
   * @return virtual
   **/
  global virtual HttpBuilder.Response idScanAnalyzer(
    Map<String, object> params
  ) {
    ContentVersion frontCv = (ContentVersion) params.get('frontContentVersion');
    ContentVersion backCv = params.containsKey('backContentVersion')
      ? (ContentVersion) params.get('backContentVersion')
      : null;
    //header
    Map<String, String> header = new Map<String, String>();
    header.put('accept', 'application/json');
    header.put('Content-Type', 'application/json');
    //request
    DocumentScanDTO.Request requestDTO = new DocumentScanDTO.Request();
    requestDTO.file_base64 = EncodingUtil.base64Encode(frontCv.VersionData);
    if (backCv != null) {
      requestDTO.file_back_base64 = EncodingUtil.base64Encode(
        backCv?.VersionData
      );
      backCv = null; //remove binary data for heap issue
    }
    requestDTO.apikey = HttpBuilder.getApiConstant('IdScanAnalyzerAPIKey');
    requestDTO.authenticate = 'true';
    requestDTO.authenticate_module = '2';
    requestDTO.verify_expiry = 'true';
    requestDTO.dualsidecheck = 'true';
    //remove binary data for heap issue
    frontCv = null;
    params.remove('FrontContentVersion');

    // HttpResponse response = HttpBuilder.httpCallOut(
    //   json.serialize(requestDTO),
    //   header
    // );
    //#TODO

    /* temp response Driver License*/
    HttpResponse response = new HttpResponse();
    response.setStatus('ok');
    response.setStatusCode(200);
    response.setBody(
      '{"result":{"documentNumber":"D2874176","firstName":"RAJESH","middleName":"NINGAPPA","lastName":"PATIL","fullName":"RAJESH NINGAPPA PATIL","sex":"M","height":"065 IN","weight":"150","age":45,"dob":"1976/02/23","dob_day":23,"dob_month":2,"dob_year":1976,"expiry":"2022/02/23","expiry_day":23,"expiry_month":2,"expiry_year":2020,"daysToExpiry":-610,"issued":"2015/02/20","issued_day":20,"issued_month":2,"issued_year":2015,"daysFromIssue":2440,"address1":"44533 JAPALA PL","address2":"FREMONT","postcode":"945390000","optionalData":"02/20/2015644C2/BBFD/20","vehicleClass":"C","restrictions":"NONE","endorsement":"NONE","documentType":"D","documentSide":"DUAL","issuerOrg_region_full":"California","issuerOrg_region_abbr":"CA","issuerOrg_full":"United States","issuerOrg_iso2":"US","issuerOrg_iso3":"USA","nationality_full":"United States","nationality_iso2":"US","nationality_iso3":"USA","internalId":"AAMVA","eyeColor":"BRN","hairColor":"BLK"},"confidence":{"documentNumber":1,"firstName":1,"middleName":1,"lastName":1,"fullName":1,"sex":1,"height":1,"weight":0.906,"age":1,"dob":1,"dob_day":1,"dob_month":1,"dob_year":1,"expiry":1,"expiry_day":1,"expiry_month":1,"expiry_year":1,"daysToExpiry":1,"issued":1,"issued_day":1,"issued_month":1,"issued_year":1,"daysFromIssue":1,"address1":1,"address2":1,"postcode":1,"optionalData":1,"vehicleClass":1,"restrictions":1,"endorsement":1,"documentType":1,"documentSide":1,"issuerOrg_region_full":1,"issuerOrg_region_abbr":1,"issuerOrg_full":1,"issuerOrg_iso2":1,"issuerOrg_iso3":1,"nationality_full":1,"nationality_iso2":1,"nationality_iso3":1,"internalId":1,"eyeColor":1,"hairColor":1},"verification":{"passed":false,"result":{"notexpired":false}},"authentication":{"score":0.6,"breakdown":{"data_visibility":{"passed":true},"image_quality":{"passed":true},"feature_referencing":{"passed":true},"exif_check":{"passed":true},"publicity_check":{"passed":true},"text_analysis":{"passed":true},"biometric_analysis":{"passed":true},"security_feature_check":{"passed":true},"recapture_check":{"passed":false,"code":180,"reason":"Recaptured document","severity":"medium"}},"warning":["Recaptured document"]},"matchrate":1,"executionTime":6.810007095336914,"responseID":"5fbf07dbea65f0dbdc5348163666672d","quota":5,"credit":45,"vaultid":"IAGwy0RmDGY6DrK57d4hIzTLNDw9tz2c"}'
    );

    // //Temp response identity card
    // HttpResponse response = new HttpResponse();
    // response.setStatus('ok');
    // response.setStatusCode(200);
    // response.setBody(
    //   '{"result":{"documentNumber":"123456789","firstName":"MICHAEL","middleName":"M","lastName":"MOTORIST","fullName":"MICHAEL M MOTORIST","sex":"M","height":"5-09","age":43,"dob":"1978/08/31","dob_day":31,"dob_month":8,"dob_year":1978,"expiry":"2023/08/31","expiry_day":31,"expiry_month":8,"expiry_year":2021,"daysToExpiry":-139,"issued":"2013/08/31","issued_day":31,"issued_month":8,"issued_year":2013,"daysFromIssue":3062,"address1":"2345 ANYWHERE STREET","address2":"YOUR CITY, NY","postcode":"12345","restrictions":"NONE","endorsement":"NONE","documentType":"I","documentSide":"FRONT","issuerOrg_region_full":"New York State","issuerOrg_region_abbr":"NY","issuerOrg_full":"United States","issuerOrg_iso2":"US","issuerOrg_iso3":"USA","nationality_full":"United States","nationality_iso2":"US","nationality_iso3":"USA","eyeColor":"BLU","internalId":"1037"},"confidence":{"documentNumber":0.993,"firstName":0.941,"middleName":0.941,"lastName":0.994,"fullName":0.941,"sex":0.337,"height":0.337,"age":0.576,"dob":0.576,"dob_day":0.576,"dob_month":0.576,"dob_year":0.576,"expiry":0.766,"expiry_day":0.766,"expiry_month":0.766,"expiry_year":0.766,"daysToExpiry":0.766,"issued":0.387,"issued_day":0.387,"issued_month":0.387,"issued_year":0.387,"daysFromIssue":0.387,"address1":0.995,"address2":0.971,"postcode":0.971,"restrictions":0.716,"endorsement":0.79,"documentType":1,"documentSide":1,"issuerOrg_region_full":1,"issuerOrg_region_abbr":1,"issuerOrg_full":1,"issuerOrg_iso2":1,"issuerOrg_iso3":1,"nationality_full":1,"nationality_iso2":1,"nationality_iso3":1,"eyeColor":0.337,"internalId":1},"verification":{"passed":false,"result":{"notexpired":false}},"authentication":{"score":0,"breakdown":{"data_visibility":{"passed":true},"image_quality":{"passed":false,"code":110,"reason":"Image appears to be computer generated","severity":"high"},"feature_referencing":{"passed":true},"exif_check":{"passed":true},"publicity_check":{"passed":false,"code":140,"reason":"This document could be obtained in the public domain","severity":"high"},"text_analysis":{"passed":true},"biometric_analysis":{"passed":true},"security_feature_check":{"passed":false,"code":171,"reason":"Security feature partially missing","severity":"low"},"recapture_check":{"passed":true}},"warning":["Image appears to be computer generated","This document could be obtained in the public domain","Security feature partially missing"]},"vaultid":"bKFSLn4G0MobJqytF94KqoqxNmcrXoJx","matchrate":1,"executionTime":4.230507850646973,"responseID":"65a19944bb858d0c5fac16bc0d466ad7","quota":3,"credit":0}'
    // );

    // //Temp response passport
    // HttpResponse response = new HttpResponse();
    // response.setStatus('ok');
    // response.setStatusCode(200);
    // response.setBody(
    //   '{"result":{"documentNumber":"910239248","personalNumber":"900781200 1296","firstName":"MICHELLE","lastName":"OBAMA","fullName":"MICHELLE OBAMA","sex":"F","age":58,"dob":"1964/01/17","dob_day":17,"dob_month":1,"dob_year":1964,"expiry":"2023/12/05","expiry_day":5,"expiry_month":12,"expiry_year":2018,"daysToExpiry":-1139,"issued":"2013/12/06","issued_day":6,"issued_month":12,"issued_year":2013,"daysFromIssue":2965,"placeOfBirth":"ILLINOIS, U.S.A.","documentType":"P","documentSide":"BIODATA","issueAuthority":"United States","issuerOrg_full":"United States","issuerOrg_iso2":"US","issuerOrg_iso3":"USA","nationality_full":"United States","nationality_iso2":"US","nationality_iso3":"USA","internalId":"22"},"confidence":{"documentNumber":1,"personalNumber":1,"firstName":1,"lastName":1,"fullName":1,"sex":1,"age":1,"dob":1,"dob_day":1,"dob_month":1,"dob_year":1,"expiry":1,"expiry_day":1,"expiry_month":1,"expiry_year":1,"daysToExpiry":1,"issued":0.996,"issued_day":0.996,"issued_month":0.996,"issued_year":0.996,"daysFromIssue":0.996,"placeOfBirth":0.886,"documentType":1,"documentSide":1,"issueAuthority":0.995,"issuerOrg_full":1,"issuerOrg_iso2":1,"issuerOrg_iso3":1,"nationality_full":1,"nationality_iso2":1,"nationality_iso3":1,"internalId":1},"verification":{"passed":false,"result":{"notexpired":false}},"authentication":{"score":0,"breakdown":{"data_visibility":{"passed":true},"image_quality":{"passed":true},"feature_referencing":{"passed":true},"exif_check":{"passed":true},"publicity_check":{"passed":false,"code":140,"reason":"This document could be obtained in the public domain","severity":"high"},"text_analysis":{"passed":true},"biometric_analysis":{"passed":false,"code":161,"reason":"Predicted age of photo is 38, 58 shown on document","severity":"low"},"security_feature_check":{"passed":true},"recapture_check":{"passed":true}},"warning":["This document could be obtained in the public domain","Predicted age of photo is 38, 58 shown on document"]},"vaultid":"LJA8MvQWvlEliLHukTo5bDFoX301j0FL","matchrate":1,"executionTime":5.972119092941284,"responseID":"87303461bb065b7ff3a32c2c406ff305","quota":1,"credit":0}'
    // );

    flow.setSubFlowResponse(response?.getBody());
    log?.debug('response : ' + response.getBody());

    if (response.getStatusCode() != 200) {
      throw new CustomException(response.getStatus());
    }

    Map<String, Object> idOldMap = (Map<String, Object>) JSON.deserializeUntyped(
      response.getBody()
    );

    if (idOldMap.ContainsKey('error')) {
      throw new CustomException(System.Label.Document_UnableToParseTheDl);
    }

    Map<String, Object> result = (Map<String, Object>) idOldMap.get('result');
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
    newMap.put('issuerOrgRegionAbbr', result.get('issuerOrg_region_abbr'));
    newMap.put('issuerOrgIso2', result.get('issuerOrg_iso2'));
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
          'status' => response.getStatusCode()
        }
      ),
      DocumentScanDTO.Response.class
    );

    return HttpBuilder.buildResponse(
      response.getStatusCode(),
      response.getStatus(),
      mapIdentityResponse(new Applicant__c(), returnDTO)
    );
  }

  /**
   * @description parse identity response into applicant record
   * @author Digital Align Team | 11-01-2021
   * @param Applicant__c applicant
   * @param DocumentScanDTO.Response returnDTO
   * @return Applicant__c
   **/
  global virtual Applicant__c mapIdentityResponse(
    Applicant__c applicant,
    DocumentScanDTO.Response returnDTO
  ) {
    FinServ__IdentificationDocument__c identity = new FinServ__IdentificationDocument__c();
    ContactPointAddress idAddress = new ContactPointAddress();

    applicant.FirstName__c = returnDTO.data.firstName;
    applicant.LastName__c = returnDTO.data.lastName;
    applicant.Birthdate__c = date.valueOf(returnDTO.data.dob);
    identity.Height__c = returnDTO.data.height;
    identity.IssuedRegion__c = returnDTO.data.issuerRegion;
    identity.Weight__c = returnDTO.data.weight;
    identity.Gender__c = returnDTO.data.gender;
    identity.DocumentType__c = mapDocumentTypeValue(
      returnDTO.data.documentType
    );
    identity.DocumentNumber__c = returnDTO.data.documentNumber;
    identity.FinServ__IssuingCountry__c = returnDTO.data.issuerCountry;
    identity.Nationality__c = returnDTO.data.country;
    identity.FinServ__ExpirationDate__c = date.valueOf(returnDTO.data.expiry);
    identity.FinServ__IssueDate__c = date.valueOf(returnDTO.data.issued);
    idAddress.Street = returnDTO.data.address1;
    idAddress.City = returnDTO.data.city;
    idAddress.PostalCode = returnDTO.data.postalCode;
    idAddress.StateCode__c = returnDTO.data.state;
    idAddress.Country = returnDTO.data.country;

    SObjectConstructor construct = SObjectConstructor.getInstance(applicant);
    construct.setChildObjects(
      'mflow__ContactPointAddresses__r',
      new List<ContactPointAddress>{ idAddress }
    );
    construct.setChildObjects(
      'mflow__IdentificationDocuments__r',
      new List<finServ__IdentificationDocument__c>{ identity }
    );
    applicant = (Applicant__c) construct.build();
    return applicant;
  }
  global string mapGenderValue(string value) {
    if (value != null) {
      switch on value {
        when 'M' {
          return 'Male';
        }
        when 'F' {
          return 'Female';
        }
        when 'X' {
          return 'Unspecified';
        }
        when else {
          return value;
        }
      }
    }
    return null;
  }
  global string mapDocumentTypeValue(string value) {
    if (value != null) {
      switch on value {
        when 'DL' {
          return 'Drivers License';
        }
        when 'ID' {
          // If Identity card save as state ID
          return 'State Id Card';
        }
        when 'CAC' {
          return 'Military Id';
        }
        when else {
          return 'Other';
        }
      }
    }
    return null;
  }
}
