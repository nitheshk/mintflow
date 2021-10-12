/**
 * Copyright (c) 2021 Digital Align
 * @group Controller
 * @author Digital Align Team
 * @reference
 * @description handle generating request and response parsing
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global abstract with sharing class AbstractDTO {
  private Type classType = AbstractDTO.class;
  public AbstractDTO() {
    this.classType = classType;
  }

  /**
   * @description convert request object into json format
   * @author Digital Align | 10-07-2021
   * @param object requestObj
   * @return virtual
   **/
  public virtual String generateRequest(object requestObj) {
    return JSON.serializePretty(requestObj);
  }

  /**
   * @description convert request object into json format and ingnore null fields
   * @author Digital Align | 10-07-2021
   * @param object requestObj
   * @param Boolean suppressNull
   * @return virtual
   **/
  public virtual String generateRequest(
    object requestObj,
    Boolean suppressNull
  ) {
    return JSON.serializePretty(requestObj, suppressNull);
  }

  /**
   * @description convert request json into request object
   * @author Digital Align | 10-07-2021
   * @param String json
   * @return virtual
   **/
  public virtual Object parse(String json) {
    return (Object) System.JSON.deserialize(json, classType);
  }

  public class Request {
  }
  /**
   * @description Parse the request
   */
  global class Response {
  }
}
