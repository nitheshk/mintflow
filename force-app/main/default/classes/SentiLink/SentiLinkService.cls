@SuppressWarnings('PMD.AvoidGlobalModifier')
global virtual with sharing class SentiLinkService extends AbstractService {
  @TestVisible
  private static SentiLinkService serviceInstance;

  public SentiLinkService() {
    super(SentiLinkService.class);
  }

  /**
   * @description Provides a singleton instance of SentiLinkService from which all other class methods can be accessed.
   * @author Digital Align Team | 07-27-2021
   * @return Object  singleton
   **/
  public static SentiLinkService getInstance() {
    if (serviceInstance == null) {
      serviceInstance = (SentiLinkService) getInstance(SentiLinkService.class);
    }
    return serviceInstance;
  }
  /**
   * @description
   * @author Digital Align | 10-08-2021
   * @param Map<String Object> params
   * @return virtual
   **/
  global virtual String customerScores(Map<String, Object> params) {
    Map<String, Object> data = params.clone();
    lead leadObj = (lead) params.get('leadObj');
    SentiLinkDTO.Request requestDTO = new SentiLinkDTO.Request();
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
    system.debug('requestDTO =' + requestDTO);
    data.put('DTO', requestDTO);
    Map<String, Object> response = SentiLinkAdapter.invokeAPI(data);
    system.debug('Status =' + response.get('Status'));
    system.debug('StatusMessage =' + response.get('StatusMessage'));
    system.debug('Data =' + response.get('Data'));
    return '';
  }
}
