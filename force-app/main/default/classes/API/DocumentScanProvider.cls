/**
 * Copyright (c) 2021 Digital Align
 * @group Service
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class DocumentScanProvider extends AbstractService {
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
   * @description scan DL using idScanAnalyzer API
   * @author Digital Align Team | 11-01-2021
   * @param Map<String object> params
   * @return virtual
   **/
  global virtual HttpBuilder.Response idScanAnalyzer(
    Map<String, object> params
  ) {
    ContentVersion cv = (ContentVersion) params.get('frontContentVersion');
    //header
    Map<String, String> header = new Map<String, String>();
    header.put('accept', 'application/json');
    header.put('Content-Type', 'application/json');
    //request
    DocumentScanDTO.Request requestDTO = new DocumentScanDTO.Request();
    requestDTO.file_base64 = EncodingUtil.base64Encode(cv.VersionData);
    requestDTO.apikey = 'rfdNfcbatBLzmdtTHqVaMLphOQQdLNw2';
    requestDTO.authenticate = 'true';
    requestDTO.authenticate_module = '2';
    requestDTO.verify_expiry = 'true';
    requestDTO.dualsidecheck = 'true';
    //remove binary data for heap issue
    cv = null;
    params.remove('FrontContentVersion');

    HttpResponse response = HttpBuilder.httpCallOut(
      json.serialize(requestDTO),
      header
    );

    /* temp response*/
    response = new HttpResponse();
    response.setStatus('ok');
    response.setStatusCode(200);
    response.setBody(
      '{"result":{"documentNumber":"D2874176","firstName":"RAJESH","middleName":"NINGAPPA","lastName":"PATIL","fullName":"RAJESH NINGAPPA PATIL","sex":"M","height":"065 IN","weight":"150","age":45,"dob":"1976/02/23","dob_day":23,"dob_month":2,"dob_year":1976,"expiry":"2020/02/23","expiry_day":23,"expiry_month":2,"expiry_year":2020,"daysToExpiry":-610,"issued":"2015/02/20","issued_day":20,"issued_month":2,"issued_year":2015,"daysFromIssue":2440,"address1":"44533 JAPALA PL","address2":"FREMONT","postcode":"945390000","optionalData":"02/20/2015644C2/BBFD/20","vehicleClass":"C","restrictions":"NONE","endorsement":"NONE","documentType":"D","documentSide":"DUAL","issuerOrg_region_full":"California","issuerOrg_region_abbr":"CA","issuerOrg_full":"United States","issuerOrg_iso2":"US","issuerOrg_iso3":"USA","nationality_full":"United States","nationality_iso2":"US","nationality_iso3":"USA","internalId":"AAMVA","eyeColor":"BRN","hairColor":"BLK"},"confidence":{"documentNumber":1,"firstName":1,"middleName":1,"lastName":1,"fullName":1,"sex":1,"height":1,"weight":0.906,"age":1,"dob":1,"dob_day":1,"dob_month":1,"dob_year":1,"expiry":1,"expiry_day":1,"expiry_month":1,"expiry_year":1,"daysToExpiry":1,"issued":1,"issued_day":1,"issued_month":1,"issued_year":1,"daysFromIssue":1,"address1":1,"address2":1,"postcode":1,"optionalData":1,"vehicleClass":1,"restrictions":1,"endorsement":1,"documentType":1,"documentSide":1,"issuerOrg_region_full":1,"issuerOrg_region_abbr":1,"issuerOrg_full":1,"issuerOrg_iso2":1,"issuerOrg_iso3":1,"nationality_full":1,"nationality_iso2":1,"nationality_iso3":1,"internalId":1,"eyeColor":1,"hairColor":1},"verification":{"passed":false,"result":{"notexpired":false}},"authentication":{"score":0.6,"breakdown":{"data_visibility":{"passed":true},"image_quality":{"passed":true},"feature_referencing":{"passed":true},"exif_check":{"passed":true},"publicity_check":{"passed":true},"text_analysis":{"passed":true},"biometric_analysis":{"passed":true},"security_feature_check":{"passed":true},"recapture_check":{"passed":false,"code":180,"reason":"Recaptured document","severity":"medium"}},"warning":["Recaptured document"]},"matchrate":1,"executionTime":6.810007095336914,"responseID":"5fbf07dbea65f0dbdc5348163666672d","quota":5,"credit":45,"vaultid":"IAGwy0RmDGY6DrK57d4hIzTLNDw9tz2c"}'
    );

    flow.setSubFlowResponse(response?.getBody());
    log?.debug('response : ' + response.getBody());

    if (response.getStatusCode() != 200) {
      throw new CustomException(response.getStatus());
    }

    Map<String, Object> idOldMap = (Map<String, Object>) JSON.deserializeUntyped(
      response.getBody()
    );

    if (idOldMap.ContainsKey('error')) {
      throw new CustomException('Unable to parse the DL');
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
    applicant.Birthdate__c = DateUtils.convertStringToDate1(returnDTO.data.dob);
    identity.Height__c = returnDTO.data.height;
    identity.IssuedRegion__c = returnDTO.data.issuerRegion;
    identity.Weight__c = returnDTO.data.weight;
    identity.Gender__c = returnDTO.data.gender;
    identity.FinServ__DocumentType__c = returnDTO.data.documentType;
    identity.FinServ__DocumentNumber__c = returnDTO.data.documentNumber;
    identity.FinServ__IssuingCountry__c = returnDTO.data.issuerCountry;
    identity.Nationality__c = returnDTO.data.nationality;
    identity.FinServ__ExpirationDate__c = DateUtils.convertStringToDate1(
      returnDTO.data.expiry
    );
    identity.FinServ__IssueDate__c = DateUtils.convertStringToDate1(
      returnDTO.data.issued
    );
    idAddress.Street = returnDTO.data.address1 + ' ' + returnDTO.data.address2;
    idAddress.PostalCode = returnDTO.data.postalCode;

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
}
