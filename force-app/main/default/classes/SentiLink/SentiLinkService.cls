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
  global virtual String customerScores(Map<String, Object> params) {
    Map<String, Object> data = params.clone();
    System.debug(' Old data::' + data);
    // SentiLinkDTO.Request requestDTO = new SentiLinkDTO.Request();
    // system.debug(requestDTO);
    Map<String, Object> response = SentiLinkAdapter.invokeAPI(data);
    system.debug('response =' + response);
    return '';
  }
}
