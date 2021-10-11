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
    System.debug(' Old data::' + data);
    lead leadObj = (lead) params.get('leadObj');
    SentiLinkDTO.Request requestDTO = new SentiLinkDTO.Request();
    List<SentiLinkDTO.Scores> scores = new List<SentiLinkDTO.Scores>();
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
      SentiLinkDTO.Scores score = new SentiLinkDTO.Scores();
      score.score_name = scoreName;
      scores.add(score);
      system.debug('score in for =' + scores);
    }
    requestDTO.application = application;
    requestDTO.scores = scores;

    system.debug('requestDTO =' + requestDTO);
    data.put('DTO', requestDTO);
    Map<String, Object> response = SentiLinkAdapter.invokeAPI(data);
    system.debug('response =' + response);
    return '';
  }
}
