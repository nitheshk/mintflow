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

    HttpResponse response = HttpBuilder.httpCallOut(
      json.serialize(requestDTO),
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

    //params.put('responseBody', response.getBody());

    return HttpBuilder.buildResponse(
      response.getStatusCode(),
      response.getStatus(),
      responseDTO
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
    /*
    List<SentiLinkDTO.ReqScores> scores = new List<SentiLinkDTO.ReqScores>();
    SentiLinkDTO.Application application = new SentiLinkDTO.Application();
    List<SentiLinkDTO.ReqExtraData> extra_data = new List<SentiLinkDTO.ReqExtraData>();
    application.first_name = leadObj.FirstName;
    application.last_name = leadObj.LastName;
    application.user_id = leadObj.Id;
    application.address_line_1 = leadObj.Street;
    application.city = leadObj.City;
    application.state_code = leadObj.State;
    application.zipcode = leadObj.PostalCode;
    application.country_code = leadObj.Country;
    application.phone = leadObj.Phone;
    application.email = leadObj.Email;
    application.business_name = leadObj.Company;
    application.lead_type = leadObj.LeadSource;
    application.application_id = 'APP-10848'; // to be replaced with Application ID
    application.dob = leadObj.Birthdate__c.format();
    application.ssn = leadObj.SSN__c;

    for (
      string scoreName : APIConfigurationService.getAPIConstants(
          'SentiLinkScoreNames'
        )
        .split(',')
    ) {
      SentiLinkDTO.ReqScores score = new SentiLinkDTO.ReqScores();
      score.score_name = scoreName;
      scores.add(score);
    }
    for (
      string extraDataType : APIConfigurationService.getAPIConstants(
          'SentiLinkExtraData'
        )
        .split(',')
    ) {
      SentiLinkDTO.ReqExtraData extraData = new SentiLinkDTO.ReqExtraData();
      extraData.type = extraDataType;
      extra_data.add(extraData);
    }
    requestDTO.application = application;
    requestDTO.scores = scores;
    requestDTO.extra_data = extra_data;
    */
    return requestDTO;
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
