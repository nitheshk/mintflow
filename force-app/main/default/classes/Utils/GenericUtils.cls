/**
 * Copyright (c) 2021 Digital Align
 * @group Utils
 * @author Digital Align Team
 * @reference
 * @description This class implement basic function
 * for some generic functionality
 **/
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class GenericUtils {
  /**
   * @description Custom execption by message and binding values
   * @author Digital Align | 05-04-2021
   * @param Object obj
   * @param List<String> values
   **/
  global static void customException(String mesage, list<String> values) {
    throw new CustomException(String.format(mesage, values));
  }

  /**
   * @description fetch login url
   * @author Digital Align Team | 09-13-2021
   * @return String
   **/
  @AuraEnabled(cacheable=true)
  global static String fetchLoginURL() {
    String baseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
    if (UtilsRepository.getUserById(UserInfo.getUserId()).ContactId != null) {
      baseUrl = fetchExperienceURL();
    }
    return baseUrl;
  }

  /**
   * @description fetch community url
   * @author Digital Align Team | 09-13-2021
   * @return String
   **/
  private static String fetchExperienceURL() {
    String baseUrl = Network.getLoginUrl(Network.getNetworkId());
    baseURL = baseURL.replace('/s/login', '');
    baseURL = baseURL.replace('/s/Login', '');
    baseURL = baseURL.replace('/login', '');
    baseURL = baseURL.replace('/Login', '');
    return baseURL;
  }
  /**
   * @description fetch US state name from state abbrv
   * @author Digital Align | 01-03-2022
   * @param string stateCode
   * @return String
   **/
  global static String fetchStateFromStateCode(string stateCode) {
    map<string, string> stateNameMap = new Map<string, string>{
      'AL' => 'Alabama',
      'AK' => 'Alaska',
      'AZ' => 'Arizona',
      'AR' => 'Arkansas',
      'CA' => 'California',
      'CO' => 'Colorado',
      'CT' => 'Connecticut',
      'DE' => 'Delaware',
      'DC' => 'District of Columbia',
      'FL' => 'Florida',
      'GA' => 'Georgia',
      'HI' => 'Hawaii',
      'ID' => 'Idaho',
      'IL' => 'Illinois',
      'IN' => 'Indiana',
      'IA' => 'Iowa',
      'KS' => 'Kansas',
      'KY' => 'Kentucky',
      'LA' => 'Louisiana',
      'ME' => 'Maine',
      'MD' => 'Maryland',
      'MA' => 'Massachusetts',
      'MI' => 'Michigan',
      'MN' => 'Minnesota',
      'MS' => 'Mississippi',
      'MO' => 'Missouri',
      'MT' => 'Montana',
      'NE' => 'Nebraska',
      'NV' => 'Nevada',
      'NH' => 'New Hampshire',
      'NJ' => 'New Jersey',
      'NM' => 'New Mexico',
      'NY' => 'New York',
      'NC' => 'North Carolina',
      'ND' => 'North Dakota',
      'OH' => 'Ohio',
      'OK' => 'Oklahoma',
      'OR' => 'Oregon',
      'PA' => 'Pennsylvania',
      'RI' => 'Rhode Island',
      'SC' => 'South Carolina',
      'SD' => 'South Dakota',
      'TN' => 'Tennessee',
      'TX' => 'Texas',
      'UT' => 'Utah',
      'VT' => 'Vermont',
      'VA' => 'Virginia',
      'WA' => 'Washington',
      'WV' => 'West Virginia',
      'WI' => 'Wisconsin',
      'WY' => 'Wyoming'
    };
    // string stateAbbrv = stateNameMap.get(stateCode.toUpperCase());
    // return stateAbbrv != null ? stateAbbrv : null;
    return stateNameMap.get(stateCode.toUpperCase());
  }
}
