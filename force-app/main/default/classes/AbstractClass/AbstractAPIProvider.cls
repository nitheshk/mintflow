/**
 * Copyright (c) 2021 Digital Align
 * @group Provider
 * @author Digital Align Team
 * @reference
 * @description Abstract class for the API Provider
 **/
public abstract with sharing class AbstractAPIProvider {
  private Type classType = AbstractAPIProvider.class;

  public AbstractAPIProvider(Type classType) {
    this.classType = classType;
  }
  /**
   * @description Build Request for the API calls
   * @author Digital Align | 08-12-2021
   * @param Map<String object> params
   * @param String
   * @return abstract
   **/
  protected abstract String buildRequest(Map<String, object> params);
  //protected abstract String buildHeader(Map<String, object> params);
  public virtual Map<String, Object> executeRequest(
    Map<String, object> params
  ) {
    try {
      String requestBody = buildRequest(params);

      if (String.isBlank(requestBody)) {
        throw new CustomException('API call Failed ---> Empty Request Body');
      }
      HttpResponse response = ExternalAPICallOut.execute(
        requestBody,
        getHeader(params)
      );
      if (response != null && String.isNotBlank(response.getBody())) {
        Object responseObj = response.getBody();
        //Object responseObj = parseResponse(response.getBody());
        return (new Map<String, object>{
          'Status' => response.getStatusCode(),
          'StatusMessage' => response.getStatus(),
          'Data' => responseObj
        });
      } else if (response != null) {
        return (new Map<String, object>{
          'Status' => response.getStatusCode(),
          'StatusMessage' => response.getStatus(),
          'Data' => null
        });
      } else {
        throw new CustomException('API call Failed ---> Empty Response');
      }
    } catch (Exception e) {
      System.debug(e);
      throw e;
    }
  }
  /**
   * @description build header for external api call
   * @param Map<String object> params
   * @return Map<String,String>
   **/
  protected abstract Map<String, String> getHeader(Map<String, object> params);
  /**
   * @description parse the response body
   * @author Digital Align | 10-12-2021
   * @param String reponseBody
   * @param ;
   * @return abstract
   **/
  // protected abstract Object parseResponse(String reponseBody);
}
