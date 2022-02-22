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
  /**
   * @description fetch US state name from state abbrv
   * @author Digital Align | 01-03-2022
   * @param string stateCode
   * @return String
   **/
  global static String fetchCountryFromCountryCode(string countryCode) {
    map<string, string> countryNameMap = new Map<string, string>{
      'AFG' => 'Afghanistan',
      'ALA' => 'Aland Islands',
      'ALB' => 'Albania',
      'DZA' => 'Algeria',
      'AND' => 'Andorra',
      'AGO' => 'Angola',
      'AIA' => 'Anguilla',
      'ATA' => 'Antarctica',
      'ATG' => 'Antigua and Barbuda',
      'ARG' => 'Argentina',
      'ARM' => 'Armenia',
      'ABW' => 'Aruba',
      'AUS' => 'Australia',
      'AUT' => 'Austria',
      'AZE' => 'Azerbaijan',
      'BHS' => 'Bahamas',
      'BHR' => 'Bahrain',
      'BGD' => 'Bangladesh',
      'BRB' => 'Barbados',
      'BLR' => 'Belarus',
      'BEL' => 'Belgium',
      'BLZ' => 'Belize',
      'BEN' => 'Benin',
      'BMU' => 'Bermuda',
      'BTN' => 'Bhutan',
      'BOL' => 'Bolivia, Plurinational State of',
      'BES' => 'Bonaire, Sint Eustatius and Saba',
      'BIH' => 'Bosnia and Herzegovina',
      'BWA' => 'Botswana',
      'BVT' => 'Bouvet Island',
      'BRA' => 'Brazil',
      'IOT' => 'British Indian Ocean Territory',
      'BRN' => 'Brunei Darussalam',
      'BGR' => 'Bulgaria',
      'BFA' => 'Burkina Faso',
      'BDI' => 'Burundi',
      'KHM' => 'Cambodia',
      'CMR' => 'Cameroon',
      'CAN' => 'Canada',
      'CPV' => 'Cape Verde',
      'CYM' => 'Cayman Islands',
      'CAF' => 'Central African Republic',
      'TCD' => 'Chad',
      'CHL' => 'Chile',
      'CHN' => 'China',
      'CXR' => 'Christmas Island',
      'CCK' => 'Cocos (Keeling) Islands',
      'COL' => 'Colombia',
      'COM' => 'Comoros',
      'COG' => 'Congo',
      'COD' => 'Congo, the Democratic Republic of the',
      'COK' => 'Cook Islands',
      'CRI' => 'Costa Rica',
      'CIV' => 'Cote d’Ivoire',
      'HRV' => 'Croatia',
      'CUB' => 'Cuba',
      'CUW' => 'Curaçao',
      'CYP' => 'Cyprus',
      'CZE' => 'Czech Republic',
      'DNK' => 'Denmark',
      'DJI' => 'Djibouti',
      'DMA' => 'Dominica',
      'DOM' => 'Dominican Republic',
      'ECU' => 'Ecuador',
      'EGY' => 'Egypt',
      'SLV' => 'El Salvador',
      'GNQ' => 'Equatorial Guinea',
      'ERI' => 'Eritrea',
      'EST' => 'Estonia',
      'ETH' => 'Ethiopia',
      'FLK' => 'Falkland Islands (Malvinas)',
      'FRO' => 'Faroe Islands',
      'FJI' => 'Fiji',
      'FIN' => 'Finland',
      'FRA' => 'France',
      'GUF' => 'French Guiana',
      'PYF' => 'French Polynesia',
      'ATF' => 'French Southern Territories',
      'GAB' => 'Gabon',
      'GMB' => 'Gambia',
      'GEO' => 'Georgia',
      'DEU' => 'Germany',
      'GHA' => 'Ghana',
      'GIB' => 'Gibraltar',
      'GRC' => 'Greece',
      'GRL' => 'Greenland',
      'GRD' => 'Grenada',
      'GLP' => 'Guadeloupe',
      'GTM' => 'Guatemala',
      'GGY' => 'Guernsey',
      'GIN' => 'Guinea',
      'GNB' => 'Guinea-Bissau',
      'GUY' => 'Guyana',
      'HTI' => 'Haiti',
      'HMD' => 'Heard Island and McDonald Islands',
      'VAT' => 'Holy See (Vatican City State)',
      'HND' => 'Honduras',
      'HUN' => 'Hungary',
      'ISL' => 'Iceland',
      'IND' => 'India',
      'IDN' => 'Indonesia',
      'IRN' => 'Iran, Islamic Republic of',
      'IRQ' => 'Iraq',
      'IRL' => 'Ireland',
      'IMN' => 'Isle of Man',
      'ISR' => 'Israel',
      'ITA' => 'Italy',
      'JAM' => 'Jamaica',
      'JPN' => 'Japan',
      'JEY' => 'Jersey',
      'JOR' => 'Jordan',
      'KAZ' => 'Kazakhstan',
      'KEN' => 'Kenya',
      'KIR' => 'Kiribati',
      'PRK' => 'Korea, Democratic People’s Republic of',
      'KOR' => 'Korea, Republic of',
      'KWT' => 'Kuwait',
      'KGZ' => 'Kyrgyzstan',
      'LAO' => 'Lao People’s Democratic Republic',
      'LVA' => 'Latvia',
      'LBN' => 'Lebanon',
      'LSO' => 'Lesotho',
      'LBR' => 'Liberia',
      'LBY' => 'Libyan Arab Jamahiriya',
      'LIE' => 'Liechtenstein',
      'LTU' => 'Lithuania',
      'LUX' => 'Luxembourg',
      'MAC' => 'Macao',
      'MKD' => 'Macedonia, the former Yugoslav Republic of',
      'MDG' => 'Madagascar',
      'MWI' => 'Malawi',
      'MYS' => 'Malaysia',
      'MDV' => 'Maldives',
      'MLI' => 'Mali',
      'MLT' => 'Malta',
      'MTQ' => 'Martinique',
      'MRT' => 'Mauritania',
      'MUS' => 'Mauritius',
      'MYT' => 'Mayotte',
      'MEX' => 'Mexico',
      'MDA' => 'Moldova, Republic of',
      'MCO' => 'Monaco',
      'MNG' => 'Mongolia',
      'MNE' => 'Montenegro',
      'MSR' => 'Montserrat',
      'MAR' => 'Morocco',
      'MOZ' => 'Mozambique',
      'MMR' => 'Myanmar',
      'NAM' => 'Namibia',
      'NRU' => 'Nauru',
      'NPL' => 'Nepal',
      'NLD' => 'Netherlands',
      'NCL' => 'New Caledonia',
      'NZL' => 'New Zealand',
      'NIC' => 'Nicaragua',
      'NER' => 'Niger',
      'NGA' => 'Nigeria',
      'NIU' => 'Niue',
      'NFK' => 'Norfolk Island',
      'NOR' => 'Norway',
      'OMN' => 'Oman',
      'PAK' => 'Pakistan',
      'PSE' => 'Palestine',
      'PAN' => 'Panama',
      'PNG' => 'Papua New Guinea',
      'PRY' => 'Paraguay',
      'PER' => 'Peru',
      'PHL' => 'Philippines',
      'PCN' => 'Pitcairn',
      'POL' => 'Poland',
      'PRT' => 'Portugal',
      'QAT' => 'Qatar',
      'REU' => 'Reunion',
      'ROU' => 'Romania',
      'RUS' => 'Russian Federation',
      'RWA' => 'Rwanda',
      'BLM' => 'Saint Barthélemy',
      'SHN' => 'Saint Helena, Ascension and Tristan da Cunha',
      'KNA' => 'Saint Kitts and Nevis',
      'LCA' => 'Saint Lucia',
      'MAF' => 'Saint Martin (French part)',
      'SPM' => 'Saint Pierre and Miquelon',
      'VCT' => 'Saint Vincent and the Grenadines',
      'WSM' => 'Samoa',
      'SMR' => 'San Marino',
      'STP' => 'Sao Tome and Principe',
      'SAU' => 'Saudi Arabia',
      'SEN' => 'Senegal',
      'SRB' => 'Serbia',
      'SYC' => 'Seychelles',
      'SLE' => 'Sierra Leone',
      'SGP' => 'Singapore',
      'SXM' => 'Sint Maarten (Dutch part)',
      'SVK' => 'Slovakia',
      'SVN' => 'Slovenia',
      'SLB' => 'Solomon Islands',
      'SOM' => 'Somalia',
      'ZAF' => 'South Africa',
      'SGS' => 'South Georgia and the South Sandwich Islands',
      'SSD' => 'South Sudan',
      'ESP' => 'Spain',
      'LKA' => 'Sri Lanka',
      'SDN' => 'Sudan',
      'SUR' => 'Suriname',
      'SJM' => 'Svalbard and Jan Mayen',
      'SWZ' => 'Swaziland',
      'SWE' => 'Sweden',
      'CHE' => 'Switzerland',
      'SYR' => 'Syrian Arab Republic',
      'TWN' => 'Taiwan',
      'TJK' => 'Tajikistan',
      'TZA' => 'Tanzania, United Republic of',
      'THA' => 'Thailand',
      'TLS' => 'Timor-Leste',
      'TGO' => 'Togo',
      'TKL' => 'Tokelau',
      'TON' => 'Tonga',
      'TTO' => 'Trinidad and Tobago',
      'TUN' => 'Tunisia',
      'TUR' => 'Turkey',
      'TKM' => 'Turkmenistan',
      'TCA' => 'Turks and Caicos Islands',
      'TUV' => 'Tuvalu',
      'UGA' => 'Uganda',
      'UKR' => 'Ukraine',
      'ARE' => 'United Arab Emirates',
      'GBR' => 'United Kingdom',
      'USA' => 'United States',
      'URY' => 'Uruguay',
      'UZB' => 'Uzbekistan',
      'VUT' => 'Vanuatu',
      'VEN' => 'Venezuela, Bolivarian Republic of',
      'VNM' => 'Vietnam',
      'VGB' => 'Virgin Islands, British',
      'WLF' => 'Wallis and Futuna',
      'ESH' => 'Western Sahara',
      'YEM' => 'Yemen',
      'ZMB' => 'Zambia',
      'ZWE' => 'Zimbabwe'
    };
    return countryNameMap.get(countryCode.toUpperCase());
  }
}
