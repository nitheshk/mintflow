/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description PlaidTokenDTO
 **/
@SuppressWarnings('PMD.VariableNamingConventions,PMD.AvoidGlobalModifier')
global with sharing class PlaidTokenDTO extends AbstractDTO {
  /** LinkTokenRequest **/
  global class LinkTokenRequest {
    global String client_id { get; set; }
    global String secret { get; set; }
    global String client_name { get; set; }
    global List<String> country_codes { get; set; }
    global String language { get; set; }
    global User user { get; set; }
    global List<String> products { get; set; }
    global LinkTokenRequest() {
      user = new User();
    }
  }
  global class User {
    global String client_user_id { get; set; }
  }
  //** LinkTokenRequest **/

  /** LinkTokenResponse **/
  global class LinkTokenResponse {
    global Datetime expiration { get; set; }
    global String link_token { get; set; }
    global String request_id { get; set; }
  }
  //** ExchangeTokenRequest **/
  global class ExchangeTokenRequest {
    global String client_id { get; set; }
    global String secret { get; set; }
    global String public_token { get; set; }
  }

  //** RetrieveAuthRequest **/
  global class RetrieveAuthRequest {
    global String client_id { get; set; }
    global String secret { get; set; }
    global String access_token { get; set; }
  }
}
