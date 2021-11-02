/**
 * Copyright (c) 2021 Digital Align
 * @group Constant
 * @author Digital Align Team
 * @reference
 * @description
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class SentiLinkProvider extends AbstractService {
  @TestVisible
  private static SentiLinkProvider serviceInstance;

  public SentiLinkProvider() {
    super(SentiLinkProvider.class);
  }

  /**
   * @description Provides a singleton instance of SentiLinkProvider from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static SentiLinkProvider getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (SentiLinkProvider) getInstance(
        SentiLinkProvider.class
      );
    }
    return serviceInstance;
  }

  /**
   * @description validate applicant against SentLink API
   * @author Digital Align Team | 11-01-2021
   * @param Map<String object> params
   * @return  HttpBuilder.Response
   **/
  global virtual HttpBuilder.Response validateSentiLink(
    Map<String, object> params
  ) {
    Applicant__c applicant = (Applicant__c) params.get('applicant');
    SentiLinkDTO.Request requestDTO = generateSentiLinkDTO(
      applicant,
      new SentiLinkDTO.Request()
    );

    log?.debug('Request : ' + json.serialize(requestDTO, true));

    HttpResponse response = HttpBuilder.httpCallOut(
      json.serialize(requestDTO, true),
      getHeader(params)
    );

    flow.setSubFlowResponse(response?.getBody());
    log?.debug('response : ' + response.getBody());

    if (response.getStatusCode() != 200) {
      throw new CustomException(response.getStatus());
    }

    SentiLinkDTO.Response responseDTO = (SentiLinkDTO.Response) JSON.deserialize(
      response.getBody(),
      SentiLinkDTO.Response.class
    );

    //Create Response File
    FileService.getInstance()
      .createFile(
        new FileDTO(
          'customerScore.txt',
          blob.valueof(response.getBody()),
          applicant.Id,
          'Identity',
          'SentiLink'
        )
      );

    applicant = mapSentiLinkDTO(applicant, responseDTO);
    IdentityRepository.upsertRecord(Applicant);

    return HttpBuilder.buildResponse(
      response.getStatusCode(),
      response.getStatus(),
      applicant
    );
  }

  /**
   * @description Mapping Applicant into sentilink request DTO
   * @author Digital Align Team | 11-01-2021
   * @param Map<String object> params
   * @return virtual
   **/
  global virtual SentiLinkDTO.Request generateSentiLinkDTO(
    Applicant__c applicant,
    SentiLinkDTO.Request requestDTO
  ) {
    SentiLinkDTO.Application application = requestDTO.application;
    application.first_name = applicant.FirstName__c;
    application.last_name = applicant.LastName__c;
    application.user_id = applicant.Id;
    application.application_id = ApexRequest.getApplicationId();
    application.phone = applicant.Phone__c;
    application.email = applicant.Email__c;
    application.dob = DateUtils.formatDateGMT(applicant.Birthdate__c);
    application.ssn = applicant.SSN__c;
    // application.lead_type = leadObj.LeadSource; // UserInfo.Channel__c

    //address mapping
    ContactPointAddress address = applicant.ContactPointAddresses__r.isEmpty()
      ? new ContactPointAddress()
      : applicant.ContactPointAddresses__r[0];
    application.address_line_1 = address.Street;
    application.city = address.City;
    application.state_code = address.State;
    application.zipcode = address.PostalCode;
    application.country_code = address.Country;

    for (
      String scoreName : HttpBuilder.getApiConstant('SentiLinkScoreNames')
        .split(',')
    ) {
      requestDTO.scores.add(new SentiLinkDTO.ReqScores(scoreName));
    }
    for (
      String extraDataType : HttpBuilder.getApiConstant('SentiLinkExtraData')
        .split(',')
    ) {
      requestDTO.extra_data.add(new SentiLinkDTO.ReqExtraData(extraDataType));
    }
    return requestDTO;
  }

  /**
   * @description map sentilink response to applicant
   * @author Digital Align Team | 11-02-2021
   * @param Applicant__c applicant
   * @param SentiLinkDTO.Response responseDTO
   * @return virtual
   **/
  global virtual Applicant__c mapSentiLinkDTO(
    Applicant__c applicant,
    SentiLinkDTO.Response responseDTO
  ) {
    return applicant;
  }

  /**
   * @description set header for sentlink api call
   * @author Digital Align Team | 11-01-2021
   * @param Map<String object> params
   * @return Map<String, String>
   **/
  private Map<String, String> getHeader(Map<String, object> params) {
    Map<String, String> header = new Map<String, String>();
    header.put('Content-Type', 'application/json');
    header.put('Accept', 'application/json');
    header.put(
      'Authorization',
      'Basic ' +
      EncodingUtil.base64Encode(
        Blob.valueOf(
          APIConfigurationService.getAPIConstants('SentiLinkAccount') +
          ':' +
          (APIConfigurationService.getAPIConstants('SentiLinkToken'))
        )
      )
    );
    return header;
  }
}
