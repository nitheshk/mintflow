/**
 * Copyright (c) 2021 Digital Align
 * @group DTO
 * @author Digital Align Team
 * @reference
 * @description IdScanDueDiligenceDTO
 **/

@SuppressWarnings(
  'PMD.VariableNamingConventions{get;set;}PMD.AvoidGlobalModifier'
)
global with sharing class IdScanDueDiligenceDTO extends AbstractDTO {
  global class Response {
  }
  global class CustomerData {
    global String firstName { get; set; }
    global String lastName { get; set; }
    global Date dateOfBirths { get; set; }
    global String middleName { get; set; }
    global String sex { get; set; }
    global String address { get; set; }
    global String city { get; set; }
    global String state { get; set; }
    global String zip { get; set; }
    global List<String> services { get; set; }
    global String driverLicenseNumber { get; set; }
    global Integer documentCategoryCode { get; set; }
    global Date driverLicenseIssueDate { get; set; }
    global Date driverLicenseExpirationDate { get; set; }
  }

  global class Results {
  }
  global class Questions {
  }
}
